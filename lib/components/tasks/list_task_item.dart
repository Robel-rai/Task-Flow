import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class ListTaskItem extends StatelessWidget {
  final Task task;

  const ListTaskItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final catColor = AppTheme.getCategoryColor(task.category);
    final statusColor = AppTheme.getStatusColor(task.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => context.read<AppState>().toggleTaskStatus(task),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.status == 'Completed'
                    ? AppTheme.emerald
                    : Colors.transparent,
                border: Border.all(
                  color: task.status == 'Completed'
                      ? AppTheme.emerald
                      : colors.textTertiary,
                  width: 2,
                ),
              ),
              child: task.status == 'Completed'
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    decoration: task.status == 'Completed'
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      task.description,
                      style:
                          TextStyle(fontSize: 12, color: colors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (task.subtasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: task.subtasks.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final subtask = entry.value;
                        return GestureDetector(
                          onTap: () {
                            context.read<AppState>().toggleSubtaskStatus(task, index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: subtask.isCompleted ? AppTheme.emerald : Colors.transparent,
                                    border: Border.all(
                                      color: subtask.isCompleted ? AppTheme.emerald : colors.textTertiary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: subtask.isCompleted
                                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    subtask.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtask.isCompleted ? colors.textTertiary : colors.textSecondary,
                                      decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task.category,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: catColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            task.formattedTimeFriendly,
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),
          const SizedBox(width: 12),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
