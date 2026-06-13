import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/app_state.dart';
import '../../services/reporting_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class ExportItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color downloadColor;
  final VoidCallback onDownload;

  const ExportItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.downloadColor,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: colors.textTertiary)),
                ],
              ),
            ],
          ),
          Material(
            color: downloadColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onDownload,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.download, size: 20, color: downloadColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExportSection extends StatelessWidget {
  const ExportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('Export Summary',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              ExportItem(
                icon: Icons.upload_file,
                iconColor: AppTheme.blue,
                title: 'Import Raw Task Data',
                subtitle: 'CSV Spreadsheet',
                downloadColor: AppTheme.blue,
                onDownload: () async {
                  final tasks = await ReportingService.importTasksFromCSV();
                  if (context.mounted && tasks != null) {
                    final appState = context.read<AppState>();
                    final newTasks = await appState.syncTasksFromCSV(tasks);
                    
                    if (!context.mounted) return;
                    if (newTasks.isNotEmpty) {
                      _showNewTasksDialog(context, newTasks, appState);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All tasks synced successfully!')),
                      );
                    }
                  }
                },
              ),
              Divider(color: colors.border, height: 1),
              ExportItem(
                icon: Icons.table_chart,
                iconColor: AppTheme.emerald,
                title: 'Export Activity Data',
                subtitle: 'CSV Spreadsheet',
                downloadColor: AppTheme.emerald,
                onDownload: () async {
                  final path = await ReportingService.exportTasksToCSV();
                  if (context.mounted && path != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exported to $path')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showNewTasksDialog(
      BuildContext context, List<Task> newTasks, AppState appState) async {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text('New Tasks Detected',
              style: TextStyle(color: colors.textPrimary)),
          content: Text(
              'Found ${newTasks.length} new tasks in the CSV that do not exist locally. Do you want to sync them and create new entries?',
              style: TextStyle(color: colors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      for (var task in newTasks) {
        await appState.createTask(task);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New tasks synced successfully!')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Existing tasks updated. New tasks were ignored.')),
        );
      }
    }
  }
}
