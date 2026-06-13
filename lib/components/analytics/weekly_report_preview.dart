import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class WeeklyReportPreview extends StatelessWidget {
  final Map<String, dynamic> report;
  const WeeklyReportPreview({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isCollapsed = AppTheme.isScreenCollapsed(context);
    final startDate = report['startDate'] as DateTime?;
    final endDate = report['endDate'] as DateTime?;
    final insights =
        (report['insights'] as List<Map<String, String>>?) ?? [];
    final categories =
        (report['categories'] as Map<String, int>?) ?? {};
    final total = categories.values.fold<int>(0, (a, b) => a + b);

    final catColors = {
      'Development': AppTheme.primary,
      'Design': AppTheme.blue,
      'Research': AppTheme.purple,
      'Marketing': AppTheme.amber,
      'Management': AppTheme.emerald,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('Reporting Preview',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Draft',
                  style: TextStyle(
                      fontSize: 11, color: colors.textTertiary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Header
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WEEKLY REPORT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          startDate != null && endDate != null
                              ? '${DateFormat('MMM dd').format(startDate)} — ${DateFormat('MMM dd, yyyy').format(endDate)}'
                              : 'This Week',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.polyline,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Two columns
              isCollapsed
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Insights
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SUMMARY INSIGHTS',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textTertiary,
                                  letterSpacing: 1),
                            ),
                            const SizedBox(height: 16),
                            if (insights.isEmpty)
                              Text(
                                'Complete some tasks to see insights.',
                                style: TextStyle(
                                    fontSize: 13, color: colors.textTertiary),
                              )
                            else
                              ...insights.map((insight) {
                                IconData ic;
                                Color col;
                                switch (insight['color']) {
                                  case 'green':
                                    ic = Icons.check_circle;
                                    col = AppTheme.emerald;
                                    break;
                                  case 'blue':
                                    ic = Icons.info;
                                    col = AppTheme.primary;
                                    break;
                                  case 'orange':
                                    ic = Icons.warning;
                                    col = AppTheme.orange;
                                    break;
                                  default:
                                    ic = Icons.info;
                                    col = colors.textTertiary;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(ic, size: 16, color: col),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          insight['text'] ?? '',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: colors.textPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Top Categories
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOP CATEGORIES',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textTertiary,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (categories.isEmpty)
                                Text(
                                  'No data yet',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: colors.textTertiary),
                                )
                              else
                                ...categories.entries.take(5).map((entry) {
                                  final pct = total > 0
                                      ? (entry.value / total * 100).round()
                                      : 0;
                                  final color = catColors[entry.key] ??
                                      colors.textTertiary;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(entry.key,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        colors.textPrimary)),
                                            Text('$pct%',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        colors.textPrimary)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: LinearProgressIndicator(
                                            value: pct / 100,
                                            backgroundColor: colors.surfaceVariant,
                                            color: color,
                                            minHeight: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Insights
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SUMMARY INSIGHTS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textTertiary,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (insights.isEmpty)
                                Text(
                                  'Complete some tasks to see insights.',
                                  style: TextStyle(
                                      fontSize: 13, color: colors.textTertiary),
                                )
                              else
                                ...insights.map((insight) {
                                  IconData ic;
                                  Color col;
                                  switch (insight['color']) {
                                    case 'green':
                                      ic = Icons.check_circle;
                                      col = AppTheme.emerald;
                                      break;
                                    case 'blue':
                                      ic = Icons.info;
                                      col = AppTheme.primary;
                                      break;
                                    case 'orange':
                                      ic = Icons.warning;
                                      col = AppTheme.orange;
                                      break;
                                    default:
                                      ic = Icons.info;
                                      col = colors.textTertiary;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(ic, size: 16, color: col),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            insight['text'] ?? '',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: colors.textPrimary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),

                        // Top Categories
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.surfaceVariant.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOP CATEGORIES',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textTertiary,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (categories.isEmpty)
                                  Text(
                                    'No data yet',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: colors.textTertiary),
                                  )
                                else
                                  ...categories.entries.take(5).map((entry) {
                                    final pct = total > 0
                                        ? (entry.value / total * 100).round()
                                        : 0;
                                    final color = catColors[entry.key] ??
                                        colors.textTertiary;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(entry.key,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          colors.textPrimary)),
                                              Text('$pct%',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          colors.textPrimary)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: LinearProgressIndicator(
                                              value: pct / 100,
                                              backgroundColor: colors.surfaceVariant,
                                              color: color,
                                              minHeight: 6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
