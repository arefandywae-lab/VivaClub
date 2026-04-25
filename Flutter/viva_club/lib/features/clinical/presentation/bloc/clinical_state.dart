import 'package:equatable/equatable.dart';

enum ClinicalStatus { initial, loading, success, failure }

class ClinicalState extends Equatable {
  final ClinicalStatus status;
  final Map<int, int> answers;
  final int currentQuestionIndex;
  final int totalScore;
  final String? riskLevel;
  final int queuePosition;
  final Map<String, dynamic>? sosRoomData;
  final String? errorMessage;

  const ClinicalState({
    this.status = ClinicalStatus.initial,
    this.answers = const {},
    this.currentQuestionIndex = 0,
    this.totalScore = 0,
    this.riskLevel,
    this.queuePosition = 0,
    this.sosRoomData,
    this.errorMessage,
  });

  ClinicalState copyWith({
    ClinicalStatus? status,
    Map<int, int>? answers,
    int? currentQuestionIndex,
    int? totalScore,
    String? riskLevel,
    int? queuePosition,
    Map<String, dynamic>? sosRoomData,
    String? errorMessage,
  }) {
    return ClinicalState(
      status: status ?? this.status,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalScore: totalScore ?? this.totalScore,
      riskLevel: riskLevel ?? this.riskLevel,
      queuePosition: queuePosition ?? this.queuePosition,
      sosRoomData: sosRoomData ?? this.sosRoomData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        answers,
        currentQuestionIndex,
        totalScore,
        riskLevel,
        queuePosition,
        sosRoomData,
        errorMessage,
      ];
}
