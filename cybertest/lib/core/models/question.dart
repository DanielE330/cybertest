import 'answer.dart';

enum QuestionType { 
  multipleChoice, 
  multipleAnswer, 
  shortAnswer, 
  essay 
}

extension QuestionTypeExtension on QuestionType {
  String get apiValue {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'single';
      case QuestionType.multipleAnswer:
        return 'multiple';
      case QuestionType.shortAnswer:
        return 'single';
      case QuestionType.essay:
        return 'single';
    }
  }

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Одиночный выбор';
      case QuestionType.multipleAnswer:
        return 'Множественный выбор';
      case QuestionType.shortAnswer:
        return 'Короткий ответ';
      case QuestionType.essay:
        return 'Развернутый ответ';
    }
  }
}

QuestionType questionTypeFromString(String value) {
  switch (value) {
    case 'single':
    case 'multiple_choice':
      return QuestionType.multipleChoice;
    case 'multiple':
    case 'multiple_answer':
      return QuestionType.multipleAnswer;
    case 'short_answer':
      return QuestionType.shortAnswer;
    case 'essay':
      return QuestionType.essay;
    default:
      return QuestionType.multipleChoice;
  }
}

class Question {
  final int? id;
  final String text;
  final QuestionType type;
  final int questionOrder;
  final List<Answer>? answers;

  Question({
    this.id,
    required this.text,
    required this.type,
    required this.questionOrder,
    this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: questionTypeFromString(json['type']),
      questionOrder: json['question_order'],
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => Answer.fromJson(a)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.apiValue,
      'question_order': questionOrder,
      'answers': answers?.map((a) => a.toJson()).toList(),
    };
  }
}