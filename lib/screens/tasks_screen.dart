import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/category_list.dart';
import '../widgets/search_bar.dart';
import '../widgets/task_list.dart';
import 'task_editor_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String searchQuery = '';
  bool isSearching = false;
  String viewMode = 'all'; // all, today, week, completed

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadTasks();
    });
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
      isSearching = query.isNotEmpty;
    });
  }

  List<Task> _getFilteredTasks(TaskProvider taskProvider) {
    List<Task> filteredTasks;

    // First apply category filter
    if (taskProvider.currentCategory == 'All') {
      filteredTasks = List.from(taskProvider.tasks);
    } else {
      filteredTasks =
          taskProvider.getTasksByCategory(taskProvider.currentCategory);
    }

    // Then apply view mode filter
    switch (viewMode) {
      case 'today':
        filteredTasks = filteredTasks.where((task) {
          if (task.dueDate == null) return false;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final dueDate = DateTime(
              task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          return dueDate.isAtSameMomentAs(today);
        }).toList();
        break;
      case 'week':
        filteredTasks = filteredTasks.where((task) {
          if (task.dueDate == null) return false;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final endOfWeek = today.add(const Duration(days: 7));
          final dueDate = DateTime(
              task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          return dueDate.isAfter(today.subtract(const Duration(days: 1))) &&
              dueDate.isBefore(endOfWeek);
        }).toList();
        break;
      case 'completed':
        filteredTasks =
            filteredTasks.where((task) => task.isCompleted).toList();
        break;
      default: // 'all'
        // No further filtering needed
        break;
    }

    // Finally apply search filter if needed
    if (isSearching) {
      final lowerCaseQuery = searchQuery.toLowerCase();
      filteredTasks = filteredTasks.where((task) {
        return task.title.toLowerCase().contains(lowerCaseQuery) ||
            (task.description?.toLowerCase().contains(lowerCaseQuery) ?? false);
      }).toList();
    }

    return filteredTasks;
  }

  void _showSortOptions(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Due Date (Earliest first)'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                Provider.of<TaskProvider>(context, listen: false)
                    .getTasksSortedByDueDate();
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.low_priority),
            title: const Text('Priority (Highest first)'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                Provider.of<TaskProvider>(context, listen: false)
                    .getTasksSortedByPriority();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildToggleOption('All', 'all'),
          _buildToggleOption('Today', 'today'),
          _buildToggleOption('Week', 'week'),
          _buildToggleOption('Done', 'completed'),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, String value) {
    final isSelected = viewMode == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            viewMode = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = _getFilteredTasks(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          taskProvider.currentCategory == 'All'
              ? 'Tasks'
              : taskProvider.currentCategory,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchBar(
              onSearch: _handleSearch,
              hint: 'Search tasks...',
            ),
          ),
          _buildViewToggle(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CategoryList(horizontal: true),
          ),
          Expanded(
            child: filteredTasks.isEmpty && !isSearching
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create a new task',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredTasks.isEmpty && isSearching
                    ? Center(
                        child: Text(
                          'No tasks matching "$searchQuery"',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      )
                    : TaskList(
                        tasks: filteredTasks,
                        onTaskTap: (task) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskEditorScreen(task: task),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskEditorScreen(
                task: Task(
                  title: '',
                  category: taskProvider.currentCategory == 'All'
                      ? null
                      : taskProvider.currentCategory,
                ),
              ),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
