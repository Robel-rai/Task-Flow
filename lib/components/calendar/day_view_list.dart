import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../theme/app_colors.dart';
import './day_detail_panel.dart'; // Import DayTaskCard

class DayViewList extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;
  final void Function(int oldIndex, int newIndex) onReorder;

  const DayViewList({
    super.key,
    required this.date,
    required this.tasks,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(date);
    
    final sortedTasks = tasks.toList();
    sortedTasks.sort((a, b) => (a.scheduledDate ?? DateTime.now()).compareTo(b.scheduledDate ?? DateTime.now()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: Text(
            dateStr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedTasks.length,
            onReorder: onReorder,
            proxyDecorator: (child, index, animation) {
              return Material(
                color: Colors.transparent,
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final task = sortedTasks[index];
              return Container(
                key: ValueKey(task.id),
                margin: const EdgeInsets.only(bottom: 12),
                child: DayTaskCard(task: task),
              );
            },
          ),
        ),
      ],
    );
  }
}
