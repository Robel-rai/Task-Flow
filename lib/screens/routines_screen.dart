import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../models/routine.dart';
import '../widgets/routine_dialog.dart';
import '../components/routines/routine_group.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isCollapsed = AppTheme.isScreenCollapsed(context);

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
                  Row(
                    children: [
                      if (isCollapsed) ...[
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        'Daily Routines',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
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
                          RoutineGroup(title: 'Morning', icon: Icons.wb_sunny_outlined, routines: morning, color: AppTheme.amber),
                        if (afternoon.isNotEmpty)
                          RoutineGroup(title: 'Afternoon', icon: Icons.wb_cloudy_outlined, routines: afternoon, color: AppTheme.blue),
                        if (evening.isNotEmpty)
                          RoutineGroup(title: 'Evening', icon: Icons.nights_stay_outlined, routines: evening, color: AppTheme.indigo),
                        if (anytime.isNotEmpty)
                          RoutineGroup(title: 'Anytime', icon: Icons.access_time, routines: anytime, color: AppTheme.primary),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
