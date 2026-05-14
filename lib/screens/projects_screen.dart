import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/project_dialog.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final projects = state.projects;

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
                  Text(
                    'Projects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<Project>(
                        context: context,
                        builder: (_) => const ProjectDialog(),
                      );
                      if (result != null && context.mounted) {
                        context.read<AppState>().createProject(result);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Project'),
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
              child: projects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 64, color: colors.border),
                          const SizedBox(height: 16),
                          Text(
                            'No Projects Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Group related tasks into a single project space.',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(32),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        final projectTasks = state.tasks.where((t) => t.projectId == project.id).toList();
                        return _ProjectCard(project: project, tasks: projectTasks);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final List<Task> tasks;

  const _ProjectCard({required this.project, required this.tasks});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final state = context.read<AppState>();

    final totalTasks = widget.tasks.length;
    final completedTasks = widget.tasks.where((t) => t.status == 'Completed').length;
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final isProjectCompleted = widget.project.status == 'Completed';

    final projectColor = widget.project.displayColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header / Summary
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isProjectCompleted ? AppTheme.emerald.withValues(alpha: 0.1) : projectColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isProjectCompleted ? Icons.check_circle : Icons.folder,
                      color: isProjectCompleted ? AppTheme.emerald : projectColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.project.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                                decoration: isProjectCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: colors.textSecondary, size: 20),
                              color: colors.surfaceVariant,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final result = await showDialog<Project>(
                                    context: context,
                                    builder: (_) => ProjectDialog(project: widget.project),
                                  );
                                  if (result != null && context.mounted) {
                                    state.updateProject(result);
                                  }
                                } else if (value == 'delete') {
                                  state.deleteProject(widget.project.id!);
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
                        if (widget.project.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.project.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        
                        // Progress Bar
                        Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    height: 6,
                                    width: MediaQuery.of(context).size.width * 0.5 * progress, // Approximation for UI, better to use LayoutBuilder
                                    decoration: BoxDecoration(
                                      color: isProjectCompleted ? AppTheme.emerald : projectColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$completedTasks / $totalTasks',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Task List
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Container(
                    decoration: BoxDecoration(
                      color: colors.background,
                      border: Border(top: BorderSide(color: colors.border)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: widget.tasks.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'No tasks in this project yet.',
                              style: TextStyle(color: colors.textTertiary),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.tasks.map((task) {
                              final isTaskCompleted = task.status == 'Completed';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () => state.toggleTaskStatus(task),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isTaskCompleted ? AppTheme.emerald : Colors.transparent,
                                          border: Border.all(
                                            color: isTaskCompleted ? AppTheme.emerald : colors.textTertiary,
                                            width: 2,
                                          ),
                                        ),
                                        child: isTaskCompleted
                                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isTaskCompleted ? colors.textSecondary : colors.textPrimary,
                                          decoration: isTaskCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
