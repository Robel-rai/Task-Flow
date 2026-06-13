import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class CategoryDetailsDialog extends StatelessWidget {
  final Map<String, double> data;
  const CategoryDetailsDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    
    // Sort data by value descending for the list
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category Performance Details',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Detailed breakdown of completion rates',
                        style: TextStyle(
                            fontSize: 13, color: colors.textTertiary)),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.textTertiary),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radar Chart
                Expanded(
                  flex: 5,
                  child: data.length < 3
                      ? SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              'Need at least 3 categories for radar chart',
                              style: TextStyle(color: colors.textTertiary),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 350,
                          child: RadarChart(
                            RadarChartData(
                              dataSets: [
                                RadarDataSet(
                                  fillColor: AppTheme.primary.withValues(alpha: 0.2),
                                  borderColor: AppTheme.primary,
                                  borderWidth: 2,
                                  dataEntries: data.values
                                      .map((v) => RadarEntry(value: v))
                                      .toList(),
                                ),
                              ],
                              radarBorderData: BorderSide(
                                color: colors.border.withValues(alpha: 0.5),
                              ),
                              tickBorderData: BorderSide(
                                color: colors.border.withValues(alpha: 0.3),
                              ),
                              gridBorderData: BorderSide(
                                color: colors.border.withValues(alpha: 0.3),
                              ),
                              radarBackgroundColor: Colors.transparent,
                              tickCount: 5,
                              ticksTextStyle: TextStyle(
                                  fontSize: 10, color: colors.textTertiary),
                              titleTextStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textSecondary),
                              getTitle: (index, _) {
                                final keys = data.keys.toList();
                                return RadarChartTitle(
                                  text: index < keys.length ? keys[index] : '',
                                );
                              },
                              titlePositionPercentageOffset: 0.2,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 48),
                // Data List
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clean Rates',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary)),
                      const SizedBox(height: 24),
                      ...sortedEntries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12, height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.getCategoryColor(e.key),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(e.key,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: colors.textPrimary,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Text('${e.value.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryRadar extends StatelessWidget {
  final Map<String, double> data;
  const CategoryRadar({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category Performance',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Completion rate per category',
                      style: TextStyle(
                          fontSize: 13, color: colors.textTertiary)),
                ],
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CategoryDetailsDialog(data: data),
                  );
                },
                child: const Text('Full Details',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (data.isEmpty || data.length < 3)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar, size: 48,
                        color: AppTheme.primary.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      data.isEmpty
                          ? 'No category data yet'
                          : 'Need at least 3 categories for radar chart',
                      style: TextStyle(color: colors.textTertiary),
                    ),
                    if (data.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...data.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${e.key}: ${e.value.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: colors.textPrimary)),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 256,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppTheme.primary.withValues(alpha: 0.2),
                      borderColor: AppTheme.primary,
                      borderWidth: 2,
                      dataEntries: data.values
                          .map((v) => RadarEntry(value: v))
                          .toList(),
                    ),
                  ],
                  radarBorderData: BorderSide(
                    color: colors.border.withValues(alpha: 0.5),
                  ),
                  tickBorderData: BorderSide(
                    color: colors.border.withValues(alpha: 0.3),
                  ),
                  gridBorderData: BorderSide(
                    color: colors.border.withValues(alpha: 0.3),
                  ),
                  radarBackgroundColor: Colors.transparent,
                  tickCount: 4,
                  ticksTextStyle: TextStyle(
                      fontSize: 8, color: colors.textTertiary),
                  titleTextStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                  getTitle: (index, _) {
                    final keys = data.keys.toList();
                    return RadarChartTitle(
                      text: index < keys.length ? keys[index] : '',
                    );
                  },
                  titlePositionPercentageOffset: 0.15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
