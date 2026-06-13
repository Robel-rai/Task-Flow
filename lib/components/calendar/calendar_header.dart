import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../widgets/task_dialog.dart';

enum CalendarViewMode { month, week, day }

class CalendarHeader extends StatelessWidget {
  final CalendarViewMode viewMode;
  final ValueChanged<CalendarViewMode> onViewModeChanged;
  final VoidCallback onRefreshTasks;

  const CalendarHeader({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onRefreshTasks,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isCollapsed = AppTheme.isScreenCollapsed(context);

    return Consumer<AppState>(
      builder: (context, state, _) {
        final month = state.viewingMonth;
        final monthName = DateFormat('MMM yyyy').format(month);

        if (isCollapsed) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: colors.background,
              border: Border(
                bottom: BorderSide(color: colors.border),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          monthName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left,
                                size: 20, color: colors.textSecondary),
                            onPressed: () {
                              state.setViewingMonth(DateTime(
                                  month.year, month.month - 1));
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                onRefreshTasks,
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                          TextButton(
                            onPressed: () {
                              state.setViewingMonth(DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month));
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                onRefreshTasks,
                              );
                            },
                            child: Text(
                              'TODAY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right,
                                size: 20, color: colors.textSecondary),
                            onPressed: () {
                              state.setViewingMonth(DateTime(
                                  month.year, month.month + 1));
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                onRefreshTasks,
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View toggles
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _viewBtn('Month', CalendarViewMode.month, colors),
                          _viewBtn('Week', CalendarViewMode.week, colors),
                          _viewBtn('Day', CalendarViewMode.day, colors),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _addTaskForDate(context, state),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        elevation: 4,
                        shadowColor:
                            AppTheme.primary.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: colors.background,
              border: Border(
                bottom: BorderSide(color: colors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      monthName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left,
                                size: 20, color: colors.textSecondary),
                            onPressed: () {
                              state.setViewingMonth(DateTime(
                                  month.year, month.month - 1));
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                onRefreshTasks,
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                          TextButton(
                            onPressed: () {
                              state.setViewingMonth(DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month));
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                onRefreshTasks,
                              );
                            },
                            child: Text(
                              'TODAY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right,
                                size: 20, color: colors.textSecondary),
                            onPressed: () {
                              state.setViewingMonth(DateTime(
                                  month.year, month.month + 1));
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                onRefreshTasks,
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // View toggles
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _viewBtn('Month', CalendarViewMode.month, colors),
                          _viewBtn('Week', CalendarViewMode.week, colors),
                          _viewBtn('Day', CalendarViewMode.day, colors),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _addTaskForDate(context, state),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        elevation: 4,
                        shadowColor:
                            AppTheme.primary.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _viewBtn(String label, CalendarViewMode mode, AppThemeColors colors) {
    final active = viewMode == mode;
    return InkWell(
      onTap: () => onViewModeChanged(mode),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? colors.textPrimary : colors.textTertiary,
          ),
        ),
      ),
    );
  }

  void _addTaskForDate(BuildContext context, AppState state) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (_) => TaskDialog(
        task: Task(
          title: '',
          scheduledDate: state.selectedCalendarDate,
        ),
      ),
    );
    if (result != null && context.mounted) {
      await state.createTask(result);
      onRefreshTasks();
      await state.selectCalendarDate(state.selectedCalendarDate);
    }
  }
}
