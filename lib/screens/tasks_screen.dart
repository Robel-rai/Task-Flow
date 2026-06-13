import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/task_card.dart';
import '../widgets/task_dialog.dart';
import '../components/tasks/tasks_header.dart';
import '../components/tasks/filter_chip_bar.dart';
import '../components/tasks/list_task_item.dart';
import '../components/tasks/schedule_sidebar.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _gridView = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isCollapsed = AppTheme.isScreenCollapsed(context);

    return Consumer<AppState>(
      builder: (context, state, _) {
        final mainArea = Column(
          children: [
            // Header
            const TasksHeader(),

            // Date Range Display
            if (state.startDateFilter != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Text(
                  state.endDateFilter != null
                      ? "Date: ${DateFormat('MMM dd, yyyy').format(state.startDateFilter!)} - ${DateFormat('MMM dd, yyyy').format(state.endDateFilter!)}"
                      : "Date: ${DateFormat('MMM dd, yyyy').format(state.startDateFilter!)}",
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ),

            // Filters & View Toggle
            FilterChipBar(
              gridView: _gridView,
              onViewChanged: (value) {
                setState(() {
                  _gridView = value;
                });
              },
            ),

            // Tasks Grid/List
            Expanded(
              child: state.tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.task_alt,
                              size: 64,
                              color:
                                  colors.textTertiary.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first task to get started',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _gridView
                      ? _buildGrid(state)
                      : _buildList(state),
            ),
          ],
        );

        if (isCollapsed) {
          return Column(
            children: [
              Expanded(
                flex: 6,
                child: mainArea,
              ),
              Expanded(
                flex: 4,
                child: ScheduleSidebar(tasks: state.tasks),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: mainArea,
              ),
              ScheduleSidebar(tasks: state.tasks),
            ],
          );
        }
      },
    );
  }

  Widget _buildGrid(AppState state) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : (width < 900 ? 2 : 3);
    final childAspectRatio = width < 600 ? 1.4 : 0.80;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: state.tasks.length,
        itemBuilder: (context, index) {
          final task = state.tasks[index];
          return GestureDetector(
            onTap: () => _showEditDialog(context, state, task),
            onLongPress: () => _showDeleteDialog(context, state, task),
            child: TaskCard(task: task),
          );
        },
      ),
    );
  }

  Widget _buildList(AppState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: state.tasks.length,
      itemBuilder: (context, index) {
        final task = state.tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showEditDialog(context, state, task),
            onLongPress: () => _showDeleteDialog(context, state, task),
            child: ListTaskItem(task: task),
          ),
        );
      },
    );
  }

  void _showEditDialog(
      BuildContext context, AppState state, Task task) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (_) => TaskDialog(task: task),
    );
    if (result != null) {
      state.updateTask(result);
    }
  }

  void _showDeleteDialog(
      BuildContext context, AppState state, Task task) async {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && task.id != null) {
      state.deleteTask(task.id!);
    }
  }
}
