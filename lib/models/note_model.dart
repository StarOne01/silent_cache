import 'package:uuid/uuid.dart';

class Note {
  final String id;
  String title;
  String content;
  final DateTime dateCreated;
  DateTime dateModified;
  bool isPinned;
  bool isFavorite;
  String? folderPath;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? dateCreated,
    DateTime? dateModified,
    this.isPinned = false,
    this.isFavorite = false,
    this.folderPath,
  })  : id = id ?? const Uuid().v4(),
        dateCreated = dateCreated ?? DateTime.now(),
        dateModified = dateModified ?? DateTime.now();

  // Convert Note to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'folderPath': folderPath,
    };
  }

  // Create a Note from JSON data
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateModified: DateTime.parse(json['dateModified']),
      isPinned: json['isPinned'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      folderPath: json['folderPath'],
    );
  }

  // Create a copy of this note with optional changes
  Note copyWith({
    String? title,
    String? content,
    bool? isPinned,
    bool? isFavorite,
    String? folderPath,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateCreated: dateCreated,
      dateModified: DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      folderPath: folderPath ?? this.folderPath,
    );
  }
}
