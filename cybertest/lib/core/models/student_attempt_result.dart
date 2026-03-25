class StudentAttemptResult {
  final int attemptId;
  final int studentId;
  final String studentName;
  final DateTime startedAt;
  final DateTime completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final double score;

  StudentAttemptResult({
    required this.attemptId,
    required this.studentId,
    required this.studentName,
    required this.startedAt,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
  });

  factory StudentAttemptResult.fromJson(Map<String, dynamic> json) {
    return StudentAttemptResult(
      attemptId: json['attempt_id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: DateTime.parse(json['completed_at']),
      totalQuestions: json['total_questions'],
      correctAnswers: json['correct_answers'],
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attempt_id': attemptId,
      'student_id': studentId,
      'student_name': studentName,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt.toIso8601String(),
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score': score,
    };
  }
}
