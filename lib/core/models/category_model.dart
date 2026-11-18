import 'package:flutter/material.dart';

class NoteCategory {
  final String id;
  final String name;
  final int colorValue;
  final String iconName;
  final bool isCustom;
  final DateTime createdAt;

  NoteCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconName,
    this.isCustom = false,
    required this.createdAt,
  });

  Color get color => Color(colorValue);

  NoteCategory copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? iconName,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return NoteCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_value': colorValue,
      'icon_name': iconName,
      'is_custom': isCustom ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NoteCategory.fromMap(Map<String, dynamic> map) {
    return NoteCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      colorValue: map['color_value'] as int? ?? 0xFF3B5BFD,
      iconName: map['icon_name'] as String? ?? 'folder',
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
    );
  }
}
