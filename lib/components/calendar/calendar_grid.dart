import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class TaskPill extends StatelessWidget {
  final String title;
  final Color color;
  const TaskPill({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border(left: BorderSide(color: color, width: 2)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_indicator, size: 10, color: colors.textTertiary),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<String, List<Task>> monthTasks;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Function(int taskId, DateTime newDate) onTaskDropped;

  const CalendarGrid({
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
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startOffset = firstDay.weekday % 7; // Sunday = 0
    final totalDays = lastDay.day;
    final totalCells = ((startOffset + totalDays + 6) ~/ 7) * 7;

    final today = DateTime.now();
    final taskColors = [
      AppTheme.emerald,
      AppTheme.primary,
      AppTheme.amber,
      AppTheme.indigo,
      AppTheme.rose,
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNum = index - startOffset + 1;
        final isCurrentMonth = dayNum >= 1 && dayNum <= totalDays;
        final date = DateTime(month.year, month.month, dayNum);
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final tasks = monthTasks[dateStr] ?? [];
        final isToday = isCurrentMonth &&
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isSelected = isCurrentMonth &&
            date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;

        return DragTarget<int>(
          onAcceptWithDetails: (details) {
            if (isCurrentMonth) {
              onTaskDropped(details.data, date);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTap: isCurrentMonth ? () => onDateSelected(date) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : candidateData.isNotEmpty
                          ? AppTheme.primary.withValues(alpha: 0.1)
                          : !isCurrentMonth
                              ? colors.surface.withValues(alpha: 0.2)
                              : null,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : colors.border.withValues(alpha: 0.5),
                    width: isSelected ? 2 : 0.5,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCurrentMonth ? '$dayNum' : '',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? AppTheme.primary
                            : isCurrentMonth
                                ? colors.textPrimary
                                : colors.textTertiary,
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const pillHeight = 19.0;
                          const moreHeight = 14.0;
                          final availableHeight = constraints.maxHeight - 2;
                          int maxVisible = (availableHeight / pillHeight).floor();
                          if (maxVisible < 0) maxVisible = 0;
                          final hasMore = tasks.length > maxVisible;
                          if (hasMore && maxVisible > 0) {
                            maxVisible = ((availableHeight - moreHeight) / pillHeight).floor();
                            if (maxVisible < 0) maxVisible = 0;
                          }
                          final visibleTasks = tasks.take(maxVisible).toList();
                          final remaining = tasks.length - visibleTasks.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 2),
                              ...visibleTasks.asMap().entries.map((entry) {
                                final t = entry.value;
                                final color =
                                    taskColors[entry.key % taskColors.length];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 1),
                                  child: Draggable<int>(
                                    data: t.id,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          t.title,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: TaskPill(title: t.title, color: color),
                                    ),
                                    child: TaskPill(title: t.title, color: color),
                                  ),
                                );
                              }),
                              if (remaining > 0)
                                Text(
                                  '+$remaining more',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: colors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
