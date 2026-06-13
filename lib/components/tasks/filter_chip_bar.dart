import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../widgets/date_range_picker.dart';
import './view_toggle.dart';

class TaskFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function(BuildContext) onTap;

  const TaskFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterChipBar extends StatelessWidget {
  final bool gridView;
  final ValueChanged<bool> onViewChanged;

  const FilterChipBar({
    super.key,
    required this.gridView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isCollapsed = AppTheme.isScreenCollapsed(context);

    return Consumer<AppState>(
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TaskFilterChip(
                        label: state.categoryFilter ?? 'Category',
                        icon: Icons.expand_more,
                        onTap: (ctx) => _showCategoryFilter(ctx, state),
                      ),
                      const SizedBox(width: 12),
                      TaskFilterChip(
                        label: state.statusFilter ?? 'Status',
                        icon: Icons.expand_more,
                        onTap: (ctx) => _showStatusFilter(ctx, state),
                      ),
                      const SizedBox(width: 12),
                      TaskFilterChip(
                        label: state.priorityFilter ?? 'Priority',
                        icon: Icons.expand_more,
                        onTap: (ctx) => _showPriorityFilter(ctx, state),
                      ),
                      const SizedBox(width: 12),
                      // Date Range Filter Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          final DateTimeRange? range = await showCustomDateRangePicker(
                            context,
                            initialStart: state.startDateFilter,
                            initialEnd: state.endDateFilter,
                          );
                          if (range != null) {
                            await state.setDateRangeFilter(range.start, range.end);
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: isCollapsed ? const SizedBox.shrink() : const Text('Date'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12, vertical: 8),
                        ),
                      ),
                      if (state.categoryFilter != null ||
                          state.statusFilter != null ||
                          state.priorityFilter != null ||
                          state.startDateFilter != null) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: state.clearFilters,
                          child: const Text(
                            'Clear filters',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // View toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ViewToggle(
                      icon: Icons.grid_view,
                      active: gridView,
                      onTap: () => onViewChanged(true),
                    ),
                    ViewToggle(
                      icon: Icons.list,
                      active: !gridView,
                      onTap: () => onViewChanged(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryFilter(BuildContext context, AppState state) {
    final customCategories = state.customCategories;
    final List<String> taskDialogCategories = const [
      'General', 'Development', 'Design', 'Research', 'Marketing',
      'Management', 'UI Design', 'Work', 'Study', 'Health'
    ];
    final List<String> allCategories = <String>{
      'All', 
      ...taskDialogCategories,
      ...customCategories,
      '+ Add New Category',
      'Manage Categories'
    }.toList();

    _showFilterMenu(context, allCategories, (v) {
      if (v == '+ Add New Category') {
        _showAddCategoryDialog(context, state);
      } else if (v == 'Manage Categories') {
        _showManageCategoriesDialog(context, state);
      } else {
        state.setCategoryFilter(v == 'All' ? null : v);
      }
    });
  }

  void _showStatusFilter(BuildContext context, AppState state) {
    _showFilterMenu(context, [
      'All', 'Pending', 'In Progress', 'Completed',
    ], (v) => state.setStatusFilter(v == 'All' ? null : v));
  }

  void _showPriorityFilter(BuildContext context, AppState state) {
    _showFilterMenu(context, [
      'All', 'Low', 'Medium', 'High',
    ], (v) => state.setPriorityFilter(v == 'All' ? null : v));
  }

  void _showFilterMenu(
      BuildContext context, List<String> items, ValueChanged<String> onSelect) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height + 4), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(const Offset(0, 4)), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: colors.surfaceVariant,
      constraints: BoxConstraints(minWidth: button.size.width),
      items: items
          .map((e) => PopupMenuItem(
                value: e,
                textStyle: TextStyle(
                  color: (e == '+ Add New Category' || e == 'Manage Categories') ? AppTheme.primary : colors.textPrimary,
                  fontSize: 13,
                  fontWeight: (e == '+ Add New Category' || e == 'Manage Categories') ? FontWeight.w700 : FontWeight.w500,
                ),
                child: e == '+ Add New Category'
                    ? Row(
                        children: [
                          const Icon(Icons.add, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          const Text('Add New Category'),
                        ],
                      )
                    : e == 'Manage Categories'
                        ? Row(
                            children: [
                              const Icon(Icons.settings, size: 16, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              const Text('Manage Categories'),
                            ],
                          )
                        : Text(e),
              ))
          .toList(),
    ).then((value) {
      if (value != null) onSelect(value);
    });
  }

  Future<void> _showAddCategoryDialog(BuildContext context, AppState state) async {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final ctrl = TextEditingController();
    final newCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Add New Category', style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Category name...',
              filled: true,
              fillColor: colors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final txt = ctrl.text.trim();
                Navigator.pop(context, txt.isNotEmpty ? txt : null);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (newCategory != null && context.mounted) {
      await state.addCustomCategory(newCategory);
      state.setCategoryFilter(newCategory);
    }
  }

  void _showManageCategoriesDialog(BuildContext context, AppState state) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            final customCategories = context.watch<AppState>().customCategories;
            
            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Manage Categories', style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              content: SizedBox(
                width: 300,
                height: 300,
                child: customCategories.isEmpty
                    ? Center(
                        child: Text(
                          'No custom categories',
                          style: TextStyle(color: colors.textTertiary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: customCategories.length,
                        itemBuilder: (context, index) {
                          final category = customCategories[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              category,
                              style: TextStyle(color: colors.textPrimary, fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.rose, size: 20),
                              onPressed: () async {
                                await state.removeCustomCategory(category);
                              },
                              tooltip: 'Delete Category',
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
