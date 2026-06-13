import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class WeekTaskCard extends StatelessWidget {
  final Task task;
  final String timeStr;
  const WeekTaskCard({super.key, required this.task, required this.timeStr});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final catColor = AppTheme.getCategoryColor(task.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: catColor.withValues(alpha: 0.15),
        border: Border(left: BorderSide(color: catColor, width: 3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (timeStr.isNotEmpty)
            Text(timeStr, style: TextStyle(fontSize: 9, color: colors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(task.title, style: TextStyle(fontSize: 11, color: colors.textPrimary, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class WeekViewGrid extends StatelessWidget {
  final DateTime month;
  final Map<String, List<Task>> monthTasks;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Function(int taskId, DateTime newDate) onTaskDropped;

  const WeekViewGrid({
    super.key,
    required this.month,
    required this.monthTasks,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onTaskDropped,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    int currentWeekday = selectedDate.weekday; // 1 = Monday, 7 = Sunday
    DateTime startOfWeek = selectedDate.subtract(Duration(days: currentWeekday - 1));

    return Row(
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        
        final tasks = (monthTasks[dateStr] ?? []).toList();
        tasks.sort((a, b) => (a.scheduledDate ?? DateTime.now()).compareTo(b.scheduledDate ?? DateTime.now()));

        final now = DateTime.now();
        final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
        final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;

        return Expanded(
          child: DragTarget<int>(
            onAcceptWithDetails: (details) {
              onTaskDropped(details.data, date);
            },
            builder: (context, candidateData, rejectedData) {
              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primary.withValues(alpha: 0.1) 
                        : (candidateData.isNotEmpty ? AppTheme.primary.withValues(alpha: 0.05) : Colors.transparent),
                    border: Border(right: BorderSide(color: colors.border, width: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                          border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
                        ),
                        child: Text(
                          '${date.day}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday ? AppTheme.primary : colors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: tasks.length,
                          itemBuilder: (context, taskIndex) {
                            final t = tasks[taskIndex];
                            final timeStr = t.scheduledDate != null ? DateFormat('HH:mm').format(t.scheduledDate!) : '';
                            return Draggable<int>(
                              data: t.id,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: 150,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getCategoryColor(t.category),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(t.title, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: WeekTaskCard(task: t, timeStr: timeStr),
                              ),
                              child: WeekTaskCard(task: t, timeStr: timeStr),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
