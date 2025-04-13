import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskList extends StatelessWidget {
  final List<Task>? tasks;
  final bool showCategory;
  final Function(Task)? onTaskTap;

  const TaskList({
    super.key,
    this.tasks,
    this.showCategory = true,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final displayTasks = tasks ?? taskProvider.tasks;

    if (displayTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create a new task',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: displayTasks.length,
      itemBuilder: (context, index) {
        final task = displayTasks[index];
        return TaskCard(
          task: task,
          showCategory: showCategory,
          onTaskTap: onTaskTap,
        );
      },
    );
  }
}

class TaskCard extends StatefulWidget {
  final Task task;
  final bool showCategory;
  final Function(Task)? onTaskTap;

  const TaskCard({
    super.key,
    required this.task,
    this.showCategory = true,
    this.onTaskTap,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Get priority color based on priority value
  Color _getPriorityColor(BuildContext context, int priority) {
    switch (priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  // Get due date status color
  Color _getDueDateColor(BuildContext context, DateTime? dueDate) {
    if (dueDate == null) return Colors.grey;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay.isBefore(today)) {
      return Colors.red; // Overdue
    } else if (dueDay == today) {
      return Colors.orange; // Due today
    } else if (dueDay.difference(today).inDays <= 2) {
      return Colors.amber; // Due soon
    } else {
      return Colors.green; // Due later
    }
  }

  // Format due date
  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay == today) {
      return 'Today';
    } else if (dueDay == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: () {
          if (widget.onTaskTap != null) {
            widget.onTaskTap!(task);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () {
                      taskProvider.toggleTaskCompletion(task.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? _getPriorityColor(context, task.priority)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: task.isCompleted
                              ? _getPriorityColor(context, task.priority)
                              : Theme.of(context).dividerColor,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Task content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task title
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isCompleted
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Task metadata
                        Row(
                          children: [
                            // Due date
                            if (task.dueDate != null) ...[
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: _getDueDateColor(context, task.dueDate),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDueDate(task.dueDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      _getDueDateColor(context, task.dueDate),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            // Category
                            if (widget.showCategory &&
                                task.category != null &&
                                task.category!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.category!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            // Last modified time
                            Text(
                              timeago.format(task.dateCreated),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Priority indicator
                  Container(
                    width: 4,
                    height: task.description != null ? 60 : 40,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(context, task.priority),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
