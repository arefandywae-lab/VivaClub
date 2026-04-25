import 'package:equatable/equatable.dart';

abstract class ClinicalEvent extends Equatable {
  const ClinicalEvent();

  @override
  List<Object?> get props => [];
}

class AssessmentAnswered extends ClinicalEvent {
  final int questionIndex;
  final int score;

  const AssessmentAnswered({required this.questionIndex, required this.score});

  @override
  List<Object?> get props => [questionIndex, score];
}

class AssessmentSubmitted extends ClinicalEvent {
  const AssessmentSubmitted();
}

class SOSRequested extends ClinicalEvent {
  const SOSRequested();
}

class QueueStatusRequested extends ClinicalEvent {
  const QueueStatusRequested();
}

class QuestionIndexChanged extends ClinicalEvent {
  final int index;
  const QuestionIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class ResetAssessment extends ClinicalEvent {
  const ResetAssessment();
}
