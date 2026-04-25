import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/clinical_repository.dart';
import 'clinical_event.dart';
import 'clinical_state.dart';

class ClinicalBloc extends Bloc<ClinicalEvent, ClinicalState> {
  final ClinicalRepository clinicalRepository;

  ClinicalBloc({required this.clinicalRepository}) : super(const ClinicalState()) {
    on<AssessmentAnswered>(_onAssessmentAnswered);
    on<AssessmentSubmitted>(_onAssessmentSubmitted);
    on<SOSRequested>(_onSOSRequested);
    on<QueueStatusRequested>(_onQueueStatusRequested);
    on<QuestionIndexChanged>((event, emit) => emit(state.copyWith(currentQuestionIndex: event.index)));
    on<ResetAssessment>((event, emit) => emit(const ClinicalState()));
  }

  void _onAssessmentAnswered(AssessmentAnswered event, Emitter<ClinicalState> emit) {
    final newAnswers = Map<int, int>.from(state.answers);
    newAnswers[event.questionIndex] = event.score;
    
    int newScore = 0;
    newAnswers.forEach((key, value) => newScore += value);

    final isLastQuestion = event.questionIndex >= 8; // PHQ-9 has 9 questions (index 0-8)
    
    emit(state.copyWith(
      answers: newAnswers,
      totalScore: newScore,
      currentQuestionIndex: isLastQuestion ? event.questionIndex : event.questionIndex + 1,
    ));
  }

  Future<void> _onAssessmentSubmitted(AssessmentSubmitted event, Emitter<ClinicalState> emit) async {
    emit(state.copyWith(status: ClinicalStatus.loading));
    try {
      final Map<String, int> answersMap = {};
      state.answers.forEach((key, value) {
        answersMap['q${key + 1}'] = value;
      });

      final result = await clinicalRepository.submitAssessment(
        totalScore: state.totalScore,
        answers: answersMap,
      );

      emit(state.copyWith(
        status: ClinicalStatus.success,
        riskLevel: result['risk_level'],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClinicalStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSOSRequested(SOSRequested event, Emitter<ClinicalState> emit) async {
    emit(state.copyWith(status: ClinicalStatus.loading));
    try {
      await clinicalRepository.triggerSOS();
      final queue = await clinicalRepository.getQueuePosition();
      
      emit(state.copyWith(
        status: ClinicalStatus.success,
        queuePosition: queue['position'],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClinicalStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onQueueStatusRequested(QueueStatusRequested event, Emitter<ClinicalState> emit) async {
    try {
      final queue = await clinicalRepository.getQueuePosition();
      
      if (queue['status'] == 'ongoing') {
        emit(state.copyWith(
          queuePosition: 0,
          sosRoomData: {
            'url': queue['url'] ?? 'wss://vivaclubs.site',
            'token': queue['livekit_token'],
            'room_name': queue['room_name'],
          },
        ));
      } else {
        emit(state.copyWith(
          queuePosition: queue['position'] ?? 0,
          sosRoomData: null,
        ));
      }
    } catch (e) {
      // Background update failure doesn't necessarily mean state failure
    }
  }
}
