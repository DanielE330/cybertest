class TestResult {
  final int attemptId;
  final int totalQuestions;
  final int correctAnswers;
  final double score;

  TestResult({
    required this.attemptId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      attemptId: json['attempt_id'] ?? 0,
      totalQuestions: json['total_questions'],
      correctAnswers: json['correct_answers'],
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attempt_id': attemptId,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score': score,
    };
  }
}