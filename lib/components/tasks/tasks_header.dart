import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../widgets/task_dialog.dart';
import '../common/notification_menu.dart';

class TasksHeader extends StatefulWidget {
  const TasksHeader({super.key});

  @override
  State<TasksHeader> createState() => _TasksHeaderState();
}

class _TasksHeaderState extends State<TasksHeader> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<AppState>().searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isCollapsed = AppTheme.isScreenCollapsed(context);

    return Consumer<AppState>(
      builder: (context, state, _) {
        // Sync controller with state if updated externally (like from Dashboard)
        if (_searchController.text != state.searchQuery) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_searchController.text != state.searchQuery) {
              _searchController.value = _searchController.value.copyWith(
                text: state.searchQuery,
                selection: TextSelection.collapsed(offset: state.searchQuery.length),
              );
            }
          });
        }

        return Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(
              bottom: BorderSide(color: colors.border),
            ),
          ),
          child: Row(
            children: [
              if (isCollapsed) ...[
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              // Search
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    onChanged: state.setSearchQuery,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                        fontSize: 13, color: colors.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search tasks...',
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: colors.textSecondary),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      filled: true,
                      fillColor: colors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.only(right: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Builder(
                builder: (btnContext) => IconButton(
                  onPressed: () => showNotificationPopup(btnContext, state),
                  icon: Badge(
                    isLabelVisible: state.notificationTasks.isNotEmpty,
                    smallSize: 8,
                    backgroundColor: AppTheme.rose,
                    child: Icon(Icons.notifications_outlined, color: colors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<Task>(
                    context: context,
                    builder: (_) => const TaskDialog(),
                  );
                  if (result != null && context.mounted) {
                    state.createTask(result);
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: isCollapsed ? const SizedBox.shrink() : const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 12 : 16, vertical: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
