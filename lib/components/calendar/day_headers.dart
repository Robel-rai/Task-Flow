import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DayHeaders extends StatelessWidget {
  final bool startOnMonday;
  const DayHeaders({super.key, this.startOnMonday = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final days = startOnMonday
        ? const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
        : const ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(
                              color: colors.border, width: 0.5)),
                    ),
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.textTertiary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
