import 'question.dart';

class Test {
  final int? id;
  final String name;
  final String description;
  final String accessCode;
  final int? teacherId;
  final List<Question>? questions;

  Test({
    this.id,
    required this.name,
    required this.description,
    required this.accessCode,
    this.teacherId,
    this.questions,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      accessCode: json['access_code'] ?? '',
      teacherId: json['teacher_id'],
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => Question.fromJson(q)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'access_code': accessCode,
      'teacher_id': teacherId,
      'questions': questions?.map((q) => q.toJson()).toList(),
    };
  }
}
