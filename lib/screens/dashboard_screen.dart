import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/notification_service.dart';
import '../components/dashboard/dashboard_header.dart';
import '../components/dashboard/kpi_cards_row.dart';
import '../components/dashboard/weekly_bar_chart.dart';
import '../components/dashboard/category_donut.dart';
import '../components/dashboard/recent_tasks_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Check reminders after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.checkUnfinishedTasks(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = WidgetsBinding.instance.platformDispatcher.displays.isNotEmpty
        ? (WidgetsBinding.instance.platformDispatcher.displays.first.size.width /
            WidgetsBinding.instance.platformDispatcher.displays.first.devicePixelRatio)
        : 1920.0;
    final isNarrow = MediaQuery.of(context).size.width <= screenWidth * 0.5;

    return Consumer<AppState>(
      builder: (context, state, _) {
        return Column(
          children: [
            // Header
            const DashboardHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Cards
                    const KpiCardsRow(),
                    const SizedBox(height: 32),

                    // Charts row
                    if (isNarrow) ...[
                      WeeklyBarChart(data: state.weeklyCompletionCounts),
                      const SizedBox(height: 24),
                      CategoryDonut(
                        data: state.categoryDistribution,
                        total: state.totalTasks,
                      ),
                    ] else ...[
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: WeeklyBarChart(data: state.weeklyCompletionCounts),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: CategoryDonut(
                                data: state.categoryDistribution,
                                total: state.totalTasks,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Recent Tasks Table
                    RecentTasksTable(tasks: state.recentTasks),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
