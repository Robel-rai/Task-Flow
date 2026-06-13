import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database.dart';
import '../models/task.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/task_dialog.dart';
import '../components/calendar/calendar_header.dart';
import '../components/calendar/day_headers.dart';
import '../components/calendar/calendar_grid.dart';
import '../components/calendar/day_detail_panel.dart';
import '../components/calendar/week_view_grid.dart';
import '../components/calendar/day_view_list.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<String, List<Task>> _monthTasks = {};
  CalendarViewMode _viewMode = CalendarViewMode.month;

  @override
  void initState() {
    super.initState();
    _loadMonthTasks();
  }

  Future<void> _loadMonthTasks() async {
    final state = context.read<AppState>();
    final month = state.viewingMonth;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59);
    final tasks = await AppDatabase.getTasksInRange(start, end);
    final map = <String, List<Task>>{};
    for (final t in tasks) {
      if (t.scheduledDate != null) {
        final key = DateFormat('yyyy-MM-dd').format(t.scheduledDate!);
        map.putIfAbsent(key, () => []);
        map[key]!.add(t);
      }
    }
    setState(() => _monthTasks = map);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isCollapsed = AppTheme.isScreenCollapsed(context);

    return Consumer<AppState>(
      builder: (context, state, _) {
        final month = state.viewingMonth;

        final headerArea = CalendarHeader(
          viewMode: _viewMode,
          onViewModeChanged: (mode) {
            setState(() {
              _viewMode = mode;
            });
          },
          onRefreshTasks: _loadMonthTasks,
        );

        final mainGrid = Column(
          children: [
            headerArea,
            // Calendar Grid
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: _buildCurrentView(month, state),
              ),
            ),
          ],
        );

        if (isCollapsed) {
          return Column(
            children: [
              Expanded(
                flex: 6,
                child: mainGrid,
              ),
              Expanded(
                flex: 4,
                child: DayDetailPanel(
                  date: state.selectedCalendarDate,
                  tasks: state.selectedDayTasks,
                  onAddTask: () => _addTaskForDate(context, state),
                  onReorder: state.reorderDayTasks,
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: mainGrid,
              ),
              DayDetailPanel(
                date: state.selectedCalendarDate,
                tasks: state.selectedDayTasks,
                onAddTask: () => _addTaskForDate(context, state),
                onReorder: state.reorderDayTasks,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildCurrentView(DateTime month, AppState state) {
    switch (_viewMode) {
      case CalendarViewMode.month:
        return Column(
          children: [
            const DayHeaders(startOnMonday: false),
            Expanded(
              child: CalendarGrid(
                month: month,
                monthTasks: _monthTasks,
                selectedDate: state.selectedCalendarDate,
                onDateSelected: (date) async {
                  await state.selectCalendarDate(date);
                },
                onTaskDropped: (taskId, newDate) async {
                  await state.rescheduleTask(taskId, newDate);
                  await _loadMonthTasks();
                },
              ),
            ),
          ],
        );
      case CalendarViewMode.week:
        return Column(
          children: [
            const DayHeaders(startOnMonday: true),
            Expanded(
              child: WeekViewGrid(
                month: month,
                monthTasks: _monthTasks,
                selectedDate: state.selectedCalendarDate,
                onDateSelected: (date) async {
                  await state.selectCalendarDate(date);
                },
                onTaskDropped: (taskId, newDate) async {
                  await state.rescheduleTask(taskId, newDate);
                  await _loadMonthTasks();
                },
              ),
            ),
          ],
        );
      case CalendarViewMode.day:
        return DayViewList(
          date: state.selectedCalendarDate,
          tasks: state.selectedDayTasks,
          onReorder: state.reorderDayTasks,
        );
    }
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
    if (result != null) {
      await state.createTask(result);
      await _loadMonthTasks();
      await state.selectCalendarDate(state.selectedCalendarDate);
    }
  }
}
