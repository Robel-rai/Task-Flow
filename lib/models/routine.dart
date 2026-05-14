import 'package:flutter/material.dart';

class Routine {
  final int? id;
  final String title;
  final String scheduledTime; // Stored in "HH:mm" format
  final int streak;
  final bool isCompletedToday;
  final DateTime? lastCompletedDate;

  Routine({
    this.id,
    required this.title,
    required this.scheduledTime,
    this.streak = 0,
    this.isCompletedToday = false,
    this.lastCompletedDate,
  });

  /// Derives a broad category based on the hour of the scheduled time.
  String get timeCategory {
    try {
      final hour = int.parse(scheduledTime.split(':')[0]);
      if (hour >= 5 && hour < 12) return 'Morning';
      if (hour >= 12 && hour < 17) return 'Afternoon';
      return 'Evening';
    } catch (_) {
      return 'Anytime';
    }
  }

  /// Parses the scheduled time into a TimeOfDay object.
  TimeOfDay get timeOfDay {
    try {
      final parts = scheduledTime.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'scheduled_time': scheduledTime,
      'streak': streak,
      'is_completed_today': isCompletedToday ? 1 : 0,
      'last_completed_date': lastCompletedDate?.toIso8601String(),
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'] as int?,
      title: map['title'] as String,
      scheduledTime: map['scheduled_time'] as String? ?? '08:00',
      streak: (map['streak'] as int?) ?? 0,
      isCompletedToday: (map['is_completed_today'] as int?) == 1,
      lastCompletedDate: map['last_completed_date'] != null
          ? DateTime.tryParse(map['last_completed_date'] as String)
          : null,
    );
  }

  Routine copyWith({
    int? id,
    String? title,
    String? scheduledTime,
    int? streak,
    bool? isCompletedToday,
    DateTime? lastCompletedDate,
    bool clearLastCompletedDate = false,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      streak: streak ?? this.streak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lastCompletedDate: clearLastCompletedDate
          ? null
          : (lastCompletedDate ?? this.lastCompletedDate),
    );
  }
}
