import 'dart:convert';

class Post {
  final int? id;
  final String title;
  final String content;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.imagePaths,
    required this.createdAt,
    required this.updatedAt,
  });

  Post copyWith({
    int? id,
    String? title,
    String? content,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert Post to Map for SQLite operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePaths': jsonEncode(imagePaths),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Post from Map (from SQLite)
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imagePaths: List<String>.from(jsonDecode(map['imagePaths'])),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Helper for checking if post has any images
  bool hasImages() {
    return imagePaths.isNotEmpty;
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, content: $content, imagePaths: $imagePaths, created: $createdAt, updated: $updatedAt)';
  }
}
