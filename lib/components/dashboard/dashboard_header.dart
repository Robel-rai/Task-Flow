import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../database/database.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../widgets/task_dialog.dart';
import '../../services/notification_service.dart';
import '../common/header_icon_button.dart';
import '../common/notification_menu.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isCollapsed = AppTheme.isScreenCollapsed(context);

    return Consumer<AppState>(
      builder: (context, state, _) {
        return Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: 0.5),
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (isCollapsed) ...[
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        'Activity Overview',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCollapsed)
                    Container(
                      width: 256,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Autocomplete<Task>(
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Task>.empty();
                          }
                          final allTasks = await AppDatabase.getAllTasks(
                            searchQuery: textEditingValue.text,
                          );
                          if (allTasks.isEmpty) {
                            return [
                              Task(
                                id: -1,
                                title: 'Add "${textEditingValue.text}"',
                              ),
                            ];
                          }
                          return allTasks.take(3);
                        },
                        displayStringForOption: (Task option) => option.title,
                        onSelected: (Task selection) async {
                          // Clear focus
                          FocusScope.of(context).unfocus();

                          if (selection.id == -1) {
                            // Create mode - extract title from "Add '...'"
                            final query = selection.title
                                .replaceFirst('Add "', '')
                                .replaceFirst('"', '');

                            final result = await showDialog<Task>(
                              context: context,
                              builder: (_) => TaskDialog(
                                task: Task(title: query),
                              ),
                            );
                            if (result != null && context.mounted) {
                              context.read<AppState>().createTask(result);
                            }
                            return;
                          }

                          // Go to tasks screen
                          state.setNavIndex(1);
                          // Set search query to match so it filters there too
                          state.setSearchQuery(selection.title);

                          // Open task dialog on next frame to allow navigation
                          WidgetsBinding.instance.addPostFrameCallback((
                            _,
                          ) async {
                            final result = await showDialog<Task>(
                              context: context,
                              builder: (_) => TaskDialog(task: selection),
                            );
                            if (result != null && context.mounted) {
                              context.read<AppState>().updateTask(result);
                            }
                          });
                        },
                        fieldViewBuilder: (
                          context,
                          controller,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onSubmitted: (value) {
                              state.setSearchQuery(value);
                              state.setNavIndex(1);
                            },
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Search activities...',
                              prefixIcon: Icon(
                                Icons.search,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                right: 12,
                              ),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              borderRadius: BorderRadius.circular(10),
                              color: colors.surface,
                              child: Container(
                                width: 256,
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: colors.border),
                                ),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final Task option = options.elementAt(
                                      index,
                                    );
                                    final isNewTask = option.id == -1;

                                    return InkWell(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          border: isNewTask
                                              ? Border(
                                                  top: BorderSide(
                                                    color: colors.border,
                                                  ),
                                                )
                                              : null,
                                          color: isNewTask
                                              ? AppTheme.primary
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            if (isNewTask) ...[
                                              const Icon(
                                                Icons.add_circle_outline,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Expanded(
                                              child: Text(
                                                option.title,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isNewTask
                                                      ? Colors.white
                                                      : colors.textPrimary,
                                                  fontWeight: isNewTask
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (!isCollapsed) const SizedBox(width: 12),
                  // Notification bell
                  HeaderIconButton(
                    icon: Icons.notifications_outlined,
                    badge: state.notificationTasks.isNotEmpty,
                    onTap: (buttonContext) {
                      if (state.notificationTasks.isEmpty) {
                        NotificationService.showDailySummary(buttonContext);
                      } else {
                        showNotificationPopup(buttonContext, state);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
