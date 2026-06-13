import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/routine.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../widgets/routine_dialog.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;

  const RoutineCard({
    super.key,
    required this.routine,
  });

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
