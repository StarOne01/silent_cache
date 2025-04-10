import 'package:uuid/uuid.dart';

class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  bool isFavorite;
  String? folderPath;
  List<String> tags;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isFavorite = false,
    this.tags = const [],
    this.folderPath,
  })  : this.id = id ?? Uuid().v4(),
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? tags,
    String? folderPath,
  }) {
    return Note(
      id: this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      folderPath: folderPath ?? this.folderPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isFavorite': isFavorite,
      'tags': tags,
      'folderPath': folderPath,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isFavorite: map['isFavorite'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      folderPath: map['folderPath'],
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) => Note.fromMap(json);

  @override
  String toString() {
    return 'Note(id: $id, title: $title, folderPath: $folderPath)';
  }
}
