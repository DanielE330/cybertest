class TestAttempt {
  final int id;
  final int testId;
  final int? studentId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<AttemptAnswer>? answers;

  TestAttempt({
    required this.id,
    required this.testId,
    this.studentId,
    this.startedAt,
    this.completedAt,
    this.answers,
  });

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
    return TestAttempt(
      id: json['id'],
      testId: json['test_id'],
      studentId: json['student_id'],
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => AttemptAnswer.fromJson(a)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_id': testId,
      'student_id': studentId,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'answers': answers?.map((a) => a.toJson()).toList(),
    };
  }
}

class AttemptAnswer {
  final int questionId;
  final int answerId;

  AttemptAnswer({
    required this.questionId,
    required this.answerId,
  });

  factory AttemptAnswer.fromJson(Map<String, dynamic> json) {
    return AttemptAnswer(
      questionId: json['question_id'],
      answerId: json['answer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer_id': answerId,
    };
  }
}