import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../models/routine.dart';
import '../widgets/routine_dialog.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final routines = state.routines;

        // Group routines
        final morning = routines.where((r) => r.timeCategory == 'Morning').toList();
        final afternoon = routines.where((r) => r.timeCategory == 'Afternoon').toList();
        final evening = routines.where((r) => r.timeCategory == 'Evening').toList();
        final anytime = routines.where((r) => r.timeCategory == 'Anytime').toList();

        return Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: colors.background.withValues(alpha: 0.5),
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Routines',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: 	FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<Routine>(
                        context: context,
                        builder: (_) => const RoutineDialog(),
                      );
                      if (result != null && context.mounted) {
                        context.read<AppState>().createRoutine(result);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Routine'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      elevation: 4,
                      shadowColor: AppTheme.primary.withValues(alpha: 0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: routines.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.repeat, size: 64, color: colors.border),
                          const SizedBox(height: 16),
                          Text(
                            'No Routines Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Build healthy habits by tracking them daily.',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(32),
                      children: [
                        if (morning.isNotEmpty)
                          _RoutineGroup(title: 'Morning', icon: Icons.wb_sunny_outlined, routines: morning, color: AppTheme.amber),
                        if (afternoon.isNotEmpty)
                          _RoutineGroup(title: 'Afternoon', icon: Icons.wb_cloudy_outlined, routines: afternoon, color: AppTheme.blue),
                        if (evening.isNotEmpty)
                          _RoutineGroup(title: 'Evening', icon: Icons.nights_stay_outlined, routines: evening, color: AppTheme.indigo),
                        if (anytime.isNotEmpty)
                          _RoutineGroup(title: 'Anytime', icon: Icons.access_time, routines: anytime, color: AppTheme.primary),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _RoutineGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Routine> routines;
  final Color color;

  const _RoutineGroup({
    required this.title,
    required this.icon,
    required this.routines,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${routines.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...routines.map((routine) => _RoutineCard(routine: routine)),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine routine;

  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final state = context.read<AppState>();
    final isCompleted = routine.isCompletedToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? colors.surfaceVariant.withValues(alpha: 0.3) : colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? AppTheme.emerald.withValues(alpha: 0.3) : colors.border,
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          InkWell(
            onTap: () => state.toggleRoutineCompletion(routine),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppTheme.emerald : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppTheme.emerald : colors.textTertiary,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // Title & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? colors.textSecondary : colors.textPrimary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: colors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      routine.timeOfDay.format(context),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Streak Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: routine.streak > 0 
                  ? AppTheme.amber.withValues(alpha: 0.15) 
                  : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🔥',
                  style: TextStyle(
                    fontSize: 14,
                    color: routine.streak == 0 ? Colors.grey : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${routine.streak}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: routine.streak > 0 ? AppTheme.amber : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),

          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colors.textSecondary),
            color: colors.surfaceVariant,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await showDialog<Routine>(
                  context: context,
                  builder: (_) => RoutineDialog(routine: routine),
                );
                if (result != null && context.mounted) {
                  state.updateRoutine(result);
                }
              } else if (value == 'delete') {
                state.deleteRoutine(routine.id!);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: colors.textPrimary),
                    const SizedBox(width: 12),
                    Text('Edit', style: TextStyle(color: colors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 18, color: AppTheme.rose),
                    const SizedBox(width: 12),
                    const Text('Delete', style: TextStyle(color: AppTheme.rose)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
