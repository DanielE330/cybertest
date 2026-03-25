class Answer {
  final int? id;
  final String text;
  final bool isCorrect;

  Answer({
    this.id,
    required this.text,
    this.isCorrect = false,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_correct': isCorrect,
    };
  }
}