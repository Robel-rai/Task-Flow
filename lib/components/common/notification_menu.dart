import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../widgets/task_dialog.dart';

/// Shows a notification popup menu anchored to [context] with the list of
/// running-timer tasks from [state].  Selecting a task opens [TaskDialog].
void showNotificationPopup(BuildContext context, AppState state) {
  if (state.notificationTasks.isEmpty) return;

  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
  final colors = Theme.of(context).extension<AppThemeColors>()!;

  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(
        Offset(button.size.width - 300, button.size.height + 8),
        ancestor: overlay,
      ),
      button.localToGlobal(
        button.size.bottomRight(const Offset(0, 8)),
        ancestor: overlay,
      ),
    ),
    Offset.zero & overlay.size,
  );

  showMenu<Task>(
    context: context,
    position: position,
    color: colors.surfaceVariant,
    constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
    items: state.notificationTasks.map((task) {
      final elapsed = task.timeSpentSeconds +
          (task.timerStartedAt != null
              ? DateTime.now().difference(task.timerStartedAt!).inSeconds
              : 0);
      final isAlert = elapsed >= 7200;

      return PopupMenuItem<Task>(
        value: task,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isAlert ? Icons.warning_amber_rounded : Icons.timer,
              color: isAlert ? AppTheme.rose : AppTheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAlert ? 'Running for over 2 hours!' : 'Timer running',
                    style: TextStyle(
                      color: isAlert ? AppTheme.rose : colors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList(),
  ).then((selectedTask) {
    if (selectedTask != null && context.mounted) {
      _openTaskDialog(context, state, selectedTask);
    }
  });
}

Future<void> _openTaskDialog(
    BuildContext context, AppState state, Task task) async {
  final result = await showDialog<Task>(
    context: context,
    builder: (_) => TaskDialog(task: task),
  );
  if (result != null && context.mounted) {
    context.read<AppState>().updateTask(result);
  }
}
