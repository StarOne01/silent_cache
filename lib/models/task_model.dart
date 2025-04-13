import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dateCreated;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? category;
  final int priority; // 0 = low, 1 = medium, 2 = high

  Task({
    String? id,
    required this.title,
    this.description,
    DateTime? dateCreated,
    this.dueDate,
    this.isCompleted = false,
    this.category,
    this.priority = 1,
  })  : id = id ?? const Uuid().v4(),
        dateCreated = dateCreated ?? DateTime.now();

  // Create a copy of the task with updated fields
  Task copyWith({
    String? title,
    String? description,
    DateTime? dateCreated,
    DateTime? dueDate,
    bool? isCompleted,
    String? category,
    int? priority,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateCreated: dateCreated ?? this.dateCreated,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }

  // Convert Task to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
      'priority': priority,
    };
  }

  // Create Task from JSON map
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      category: json['category'],
      priority: json['priority'] ?? 1,
    );
  }
}
