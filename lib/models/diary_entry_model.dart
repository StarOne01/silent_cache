import 'package:uuid/uuid.dart';

class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final bool isFavorite;
  final String? mood;

  DiaryEntry({
    String? id,
    required this.title,
    required this.content,
    DateTime? date,
    this.isFavorite = false,
    this.mood,
  })  : this.id = id ?? const Uuid().v4(),
        this.date = date ?? DateTime.now();

  DiaryEntry copyWith({
    String? title,
    String? content,
    DateTime? date,
    bool? isFavorite,
    String? mood,
  }) {
    return DiaryEntry(
      id: this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      isFavorite: isFavorite ?? this.isFavorite,
      mood: mood ?? this.mood,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'isFavorite': isFavorite,
      'mood': mood,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      isFavorite: json['isFavorite'] ?? false,
      mood: json['mood'],
    );
  }
}
