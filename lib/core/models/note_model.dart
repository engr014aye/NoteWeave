class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final bool isPinned;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.isPinned = false,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty;

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'is_pinned': isPinned ? 1 : 0,
      'tags': tags.join(','),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    final tagsStr = map['tags'] as String? ?? '';
    final parsedTags = tagsStr.isEmpty
        ? <String>[]
        : tagsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Note(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      tags: parsedTags,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int? ?? 0),
    );
  }
}
