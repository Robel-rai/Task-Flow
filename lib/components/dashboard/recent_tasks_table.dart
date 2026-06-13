import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../widgets/task_dialog.dart';

class RecentTasksTable extends StatelessWidget {
  final List tasks;
  const RecentTasksTable({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<dynamic>(
                      context: context,
                      builder: (_) => const TaskDialog(),
                    );
                    if (result != null && context.mounted) {
                      context.read<AppState>().createTask(result);
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _tableHeader('Task Name', flex: 3, colors: colors),
                _tableHeader('Category', flex: 2, colors: colors),
                _tableHeader('Duration', flex: 1, colors: colors),
                _tableHeader('Status', flex: 1, colors: colors),
                _tableHeader(
                  'Date',
                  flex: 1,
                  alignment: CrossAxisAlignment.end,
                  colors: colors,
                ),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          // Rows
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No tasks yet. Create your first task!',
                style: TextStyle(color: colors.textTertiary),
              ),
            )
          else
            ...tasks.map((t) => TaskRow(task: t)),
        ],
      ),
    );
  }

  Widget _tableHeader(
    String text, {
    int flex = 1,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
    required AppThemeColors colors,
  }) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment == CrossAxisAlignment.end
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: colors.textTertiary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class TaskRow extends StatelessWidget {
  final dynamic task;
  const TaskRow({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final catColor = AppTheme.getCategoryColor(task.category);
    final statusColor = AppTheme.getStatusColor(task.status);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // Task Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.code, size: 16, color: catColor),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Category
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                task.category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: catColor,
                ),
              ),
            ),
          ),
          // Duration
          Expanded(
            flex: 1,
            child: Text(
              task.formattedTimeFriendly,
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  task.status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          // Date
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${months[task.createdAt.month - 1]} ${task.createdAt.day}, ${task.createdAt.year}',
                style: TextStyle(fontSize: 13, color: colors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
