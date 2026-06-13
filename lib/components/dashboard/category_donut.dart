import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class CategoryDonut extends StatelessWidget {
  final Map<String, int> data;
  final int total;
  const CategoryDonut({super.key, required this.data, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final chartColors = <Color>[
      AppTheme.primary,
      AppTheme.indigo,
      AppTheme.sky,
      AppTheme.purple,
      AppTheme.amber,
      AppTheme.emerald,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'By category',
            style: TextStyle(fontSize: 13, color: colors.textTertiary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: data.isEmpty
                        ? [
                            PieChartSectionData(
                              value: 1,
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              radius: 30,
                              showTitle: false,
                            ),
                          ]
                        : data.entries.toList().asMap().entries.map((e) {
                            final idx = e.key;
                            final entry = e.value;
                            return PieChartSectionData(
                              value: entry.value.toDouble(),
                              color: chartColors[idx % chartColors.length],
                              radius: 30,
                              showTitle: false,
                            );
                          }).toList(),
                    centerSpaceRadius: 50,
                    sectionsSpace: 2,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.textTertiary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          ...data.entries.toList().asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: chartColors[idx % chartColors.length],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
