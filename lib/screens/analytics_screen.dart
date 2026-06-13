import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../services/reporting_service.dart';
import '../theme/app_theme.dart';
import '../components/analytics/analytics_header.dart';
import '../components/analytics/stat_card.dart';
import '../components/analytics/category_radar.dart';
import '../components/analytics/focus_time_chart.dart';
import '../components/analytics/export_section.dart';
import '../components/analytics/weekly_report_preview.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _productivityScore = 0;
  int _streak = 0;
  int _maxStreak = 0;
  double _avgCompletionTime = 0;
  Map<int, double> _focusTimePerDay = {};
  double _dailyAvgFocusHours = 0;
  Map<int, double> _monthlyFocusTimePerDay = {};
  double _monthlyAvgFocusHours = 0;
  bool _isWeeklyFocusView = true;
  Map<String, double> _categoryPerformance = {};
  Map<String, dynamic> _weeklyReport = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final results = await Future.wait([
      AnalyticsService.getProductivityScore(),
      AnalyticsService.getDailyStreak(),
      AnalyticsService.getMaxStreak(),
      AnalyticsService.getAvgCompletionTimeMinutes(),
      AnalyticsService.getFocusTimePerDayThisWeek(),
      AnalyticsService.getDailyAvgFocusHours(),
      AnalyticsService.getCategoryPerformance(),
      ReportingService.generateWeeklyReport(),
      AnalyticsService.getFocusTimePerDayThisMonth(),
      AnalyticsService.getMonthlyAvgFocusHours(),
    ]);

    setState(() {
      _productivityScore = results[0] as int;
      _streak = results[1] as int;
      _maxStreak = results[2] as int;
      _avgCompletionTime = results[3] as double;
      _focusTimePerDay = results[4] as Map<int, double>;
      _dailyAvgFocusHours = results[5] as double;
      _categoryPerformance = results[6] as Map<String, double>;
      _weeklyReport = results[7] as Map<String, dynamic>;
      _monthlyFocusTimePerDay = results[8] as Map<int, double>;
      _monthlyAvgFocusHours = results[9] as double;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCollapsed = AppTheme.isScreenCollapsed(context);

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    return Column(
      children: [
        // Header
        const AnalyticsHeader(),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stats Cards
                if (isCollapsed) ...[
                  StatCard(
                    label: 'Daily Productivity Score',
                    value: '$_productivityScore',
                    icon: Icons.speed,
                    iconColor: AppTheme.primary,
                    change: '+${(_productivityScore * 0.05).round()}%',
                    changeUp: true,
                    subtitle: "Versus last week's average",
                  ),
                  const SizedBox(height: 16),
                  StatCard(
                    label: 'Current Streak',
                    value: '$_streak days',
                    icon: Icons.local_fire_department,
                    iconColor: AppTheme.orange,
                    change: _streak > 0 ? '+$_streak' : '0',
                    changeUp: _streak > 0,
                    subtitle: 'Personal record: $_maxStreak days',
                  ),
                  const SizedBox(height: 16),
                  StatCard(
                    label: 'Avg. Completion Time',
                    value: '${_avgCompletionTime.round()}m',
                    icon: Icons.timer,
                    iconColor: AppTheme.blue,
                    change: _avgCompletionTime > 0
                        ? '${_avgCompletionTime.round()}m'
                        : '0m',
                    changeUp: false,
                    subtitle: 'Per task average',
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Daily Productivity Score',
                          value: '$_productivityScore',
                          icon: Icons.speed,
                          iconColor: AppTheme.primary,
                          change: '+${(_productivityScore * 0.05).round()}%',
                          changeUp: true,
                          subtitle: "Versus last week's average",
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: StatCard(
                          label: 'Current Streak',
                          value: '$_streak days',
                          icon: Icons.local_fire_department,
                          iconColor: AppTheme.orange,
                          change: _streak > 0 ? '+$_streak' : '0',
                          changeUp: _streak > 0,
                          subtitle: 'Personal record: $_maxStreak days',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: StatCard(
                          label: 'Avg. Completion Time',
                          value: '${_avgCompletionTime.round()}m',
                          icon: Icons.timer,
                          iconColor: AppTheme.blue,
                          change: _avgCompletionTime > 0
                              ? '${_avgCompletionTime.round()}m'
                              : '0m',
                          changeUp: false,
                          subtitle: 'Per task average',
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),

                // Charts Row
                if (isCollapsed) ...[
                  CategoryRadar(data: _categoryPerformance),
                  const SizedBox(height: 24),
                  FocusTimeChart(
                    data: _isWeeklyFocusView ? _focusTimePerDay : _monthlyFocusTimePerDay,
                    avgHours: _isWeeklyFocusView ? _dailyAvgFocusHours : _monthlyAvgFocusHours,
                    isWeekly: _isWeeklyFocusView,
                    onToggle: () {
                      setState(() {
                        _isWeeklyFocusView = !_isWeeklyFocusView;
                      });
                    },
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Radar Chart / Category Performance
                      Expanded(child: CategoryRadar(data: _categoryPerformance)),
                      const SizedBox(width: 32),
                      // Focus Time Line Chart
                      Expanded(
                        child: FocusTimeChart(
                          data: _isWeeklyFocusView ? _focusTimePerDay : _monthlyFocusTimePerDay,
                          avgHours: _isWeeklyFocusView ? _dailyAvgFocusHours : _monthlyAvgFocusHours,
                          isWeekly: _isWeeklyFocusView,
                          onToggle: () {
                            setState(() {
                              _isWeeklyFocusView = !_isWeeklyFocusView;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),

                // Export & Report Section
                if (isCollapsed) ...[
                  const ExportSection(),
                  const SizedBox(height: 24),
                  WeeklyReportPreview(report: _weeklyReport),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Export Options
                      const SizedBox(
                        width: 300,
                        child: ExportSection(),
                      ),
                      const SizedBox(width: 32),
                      // Weekly Report Preview
                      Expanded(child: WeeklyReportPreview(report: _weeklyReport)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
