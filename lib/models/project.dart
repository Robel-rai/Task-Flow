import 'dart:ui';
import '../theme/app_theme.dart';

class Project {
  final int? id;
  final String title;
  final String description;
  final String color;
  final String status; // Pending, Completed
  final DateTime createdAt;

  Project({
    this.id,
    required this.title,
    this.description = '',
    this.color = 'primary', // Store color key like 'primary', 'blue', 'amber', 'rose', 'emerald'
    this.status = 'Pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'color': color,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      color: (map['color'] as String?) ?? 'primary',
      status: (map['status'] as String?) ?? 'Pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Project copyWith({
    int? id,
    String? title,
    String? description,
    String? color,
    String? status,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Helper to convert string key to Color
  Color get displayColor {
    switch (color) {
      case 'blue':
        return AppTheme.blue;
      case 'amber':
        return AppTheme.amber;
      case 'rose':
        return AppTheme.rose;
      case 'emerald':
        return AppTheme.emerald;
      case 'indigo':
        return AppTheme.indigo;
      default:
        return AppTheme.primary;
    }
  }
}
