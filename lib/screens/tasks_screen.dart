import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scribbly_provider.dart';
import '../models/models.dart';
import '../widgets/glass_container.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? CupertinoColors.systemBackground.darkColor : CupertinoColors.secondarySystemBackground;

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: bgColor.withValues(alpha: 0.8),
            largeTitle: Text('Tasks', style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
            border: null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTaskInput(context),
                  const SizedBox(height: 24),
                  _buildTaskList(context),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInput(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: _taskController,
            placeholder: 'Add a new task...',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? CupertinoColors.secondarySystemGroupedBackground.darkColor
                  : CupertinoColors.systemBackground.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CupertinoColors.systemGrey5),
            ),
            onSubmitted: (_) => _addTask(),
          ),
        ),
        const SizedBox(width: 12),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _addTask,
          child: const Icon(CupertinoIcons.add_circled_solid, size: 40, color: CupertinoColors.activeBlue),
        ),
      ],
    );
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _taskController.text.trim(),
    );

    context.read<ScribblyProvider>().addTask(newTask);
    _taskController.clear();
  }

  Widget _buildTaskList(BuildContext context) {
    return Consumer<ScribblyProvider>(
      builder: (context, provider, child) {
        final tasks = provider.tasks;

        if (tasks.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('All done! No tasks remaining.'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardColor = isDark
                ? CupertinoColors.secondarySystemGroupedBackground.darkColor
                : CupertinoColors.systemBackground.color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GlassContainer(
                color: cardColor,
                opacity: isDark ? 0.4 : 0.7,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => provider.toggleTaskCompletion(task.id),
                      child: Icon(
                        task.isCompleted ? CupertinoIcons.checkmark_alt_circle_fill : CupertinoIcons.circle,
                        color: task.isCompleted ? CupertinoColors.activeGreen : CupertinoColors.systemGrey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? CupertinoColors.systemGrey : CupertinoColors.label.resolveFrom(context),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed, size: 20),
                      onPressed: () {
                        provider.deleteTask(task.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
