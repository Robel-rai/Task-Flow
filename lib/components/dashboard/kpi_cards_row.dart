import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/kpi_card.dart';

class KpiCardsRow extends StatelessWidget {
  const KpiCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = WidgetsBinding.instance.platformDispatcher.displays.isNotEmpty
        ? (WidgetsBinding.instance.platformDispatcher.displays.first.size.width /
            WidgetsBinding.instance.platformDispatcher.displays.first.devicePixelRatio)
        : 1920.0;
    final isNarrow = MediaQuery.of(context).size.width <= screenWidth * 0.5;

    return Consumer<AppState>(
      builder: (context, state, _) {
        if (isNarrow) {
          return Column(
            children: [
              KpiCard(
                label: 'Total Tasks',
                value: '${state.totalTasks}',
                icon: Icons.assignment,
                iconColor: AppTheme.blue,
                badge: state.totalTasks > 0 ? '+${state.totalTasks}' : null,
              ),
              const SizedBox(height: 16),
              KpiCard(
                label: 'Hours Logged',
                value: state.hoursLogged.toStringAsFixed(1),
                icon: Icons.schedule,
                iconColor: AppTheme.purple,
              ),
              const SizedBox(height: 16),
              KpiCard(
                label: 'Efficiency',
                value: '${state.efficiencyRate.round()}%',
                icon: Icons.bolt,
                iconColor: AppTheme.emerald,
                badge: state.efficiencyRate > 0 ? '${state.efficiencyRate.round()}%' : null,
              ),
              const SizedBox(height: 16),
              KpiCard(
                label: 'Pending',
                value: '${state.pendingTasks}',
                icon: Icons.pending_actions,
                iconColor: AppTheme.amber,
                badge: 'Active',
                badgeColor: AppTheme.textTertiary,
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Total Tasks',
                  value: '${state.totalTasks}',
                  icon: Icons.assignment,
                  iconColor: AppTheme.blue,
                  badge: state.totalTasks > 0 ? '+${state.totalTasks}' : null,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: KpiCard(
                  label: 'Hours Logged',
                  value: state.hoursLogged.toStringAsFixed(1),
                  icon: Icons.schedule,
                  iconColor: AppTheme.purple,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: KpiCard(
                  label: 'Efficiency',
                  value: '${state.efficiencyRate.round()}%',
                  icon: Icons.bolt,
                  iconColor: AppTheme.emerald,
                  badge: state.efficiencyRate > 0 ? '${state.efficiencyRate.round()}%' : null,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: KpiCard(
                  label: 'Pending',
                  value: '${state.pendingTasks}',
                  icon: Icons.pending_actions,
                  iconColor: AppTheme.amber,
                  badge: 'Active',
                  badgeColor: AppTheme.textTertiary,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
