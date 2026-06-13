import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class DeadlineItem extends StatelessWidget {
  final Task task;
  const DeadlineItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isUrgent = task.priority == 'High';
    final color = isUrgent ? AppTheme.rose : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.scheduledDate != null)
                  Text(
                    _formatDate(task.scheduledDate!),
                    style: TextStyle(
                        fontSize: 10, color: colors.textTertiary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class TodayTaskItem extends StatelessWidget {
  final Task task;
  const TodayTaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isActive = task.isTimerRunning;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary.withValues(alpha: 0.1)
            : colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? AppTheme.primary : colors.textPrimary,
            ),
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Timer running...',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScheduleSidebar extends StatelessWidget {
  final List<Task> tasks;
  const ScheduleSidebar({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isCollapsed = AppTheme.isScreenCollapsed(context);
    final todayTasks = tasks
        .where((t) =>
            t.scheduledDate != null &&
            _isSameDay(t.scheduledDate!, DateTime.now()))
        .toList();
    final upcomingDeadlines = tasks
        .where((t) =>
            t.scheduledDate != null &&
            t.scheduledDate!.isAfter(DateTime.now()) &&
            t.status != 'Completed')
        .take(3)
        .toList();

    return Container(
      width: isCollapsed ? double.infinity : 320,
      decoration: BoxDecoration(
        color: colors.background,
        border: isCollapsed
            ? Border(top: BorderSide(color: colors.border))
            : Border(left: BorderSide(color: colors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upcoming Deadlines
                  Text(
                    'UPCOMING DEADLINES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.textTertiary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (upcomingDeadlines.isEmpty)
                    Text(
                      'No upcoming deadlines',
                      style: TextStyle(
                          fontSize: 13, color: colors.textTertiary),
                    )
                  else
                    ...upcomingDeadlines.map((t) => DeadlineItem(task: t)),
                  const SizedBox(height: 24),
                  Divider(color: colors.border),
                  const SizedBox(height: 16),
                  // Today's tasks
                  Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.textTertiary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (todayTasks.isEmpty)
                    Text(
                      'No tasks scheduled for today',
                      style: TextStyle(
                          fontSize: 13, color: colors.textTertiary),
                    )
                  else
                    ...todayTasks.map((t) => TodayTaskItem(task: t)),
                ],
              ),
            ),
          ),
          // Weekly report card
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 28, color: AppTheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Weekly Report Ready!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your productivity insights',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AppState>().setNavIndex(3);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('View Detailed Stats'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
