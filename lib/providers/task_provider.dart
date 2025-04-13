import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String _currentCategory = 'All';

  List<Task> get tasks => _tasks;
  String get currentCategory => _currentCategory;

  // Set current category and notify listeners
  void setCurrentCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  // Get all categories
  Set<String> get categories {
    Set<String> result = {'All'};
    for (var task in _tasks) {
      if (task.category != null && task.category!.isNotEmpty) {
        result.add(task.category!);
      }
    }
    return result;
  }

  // Add task
  void addTask(Task task) {
    _tasks.add(task);
    _saveToDisk();
    notifyListeners();
  }

  // Update task
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index >= 0) {
      _tasks[index] = updatedTask;
      _saveToDisk();
      notifyListeners();
    }
  }

  // Delete task
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _saveToDisk();
    notifyListeners();
  }

  // Toggle task completion
  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index >= 0) {
      _tasks[index] =
          _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      _saveToDisk();
      notifyListeners();
    }
  }

  // Search tasks
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;

    final lowerCaseQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowerCaseQuery) ||
          (task.description?.toLowerCase().contains(lowerCaseQuery) ?? false);
    }).toList();
  }

  // Filter tasks by category
  List<Task> getTasksByCategory(String category) {
    if (category == 'All') {
      return _tasks;
    }
    return _tasks.where((task) => task.category == category).toList();
  }

  // Get completed tasks
  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  // Get incomplete tasks
  List<Task> get incompleteTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  // Get tasks due today
  List<Task> get tasksForToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate =
          DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return dueDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get tasks due this week
  List<Task> get tasksForThisWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(const Duration(days: 7));

    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate =
          DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return dueDate.isAfter(today.subtract(const Duration(days: 1))) &&
          dueDate.isBefore(endOfWeek);
    }).toList();
  }

  // Sort tasks by priority
  List<Task> getTasksSortedByPriority() {
    final sortedTasks = List<Task>.from(_tasks);
    sortedTasks.sort((a, b) => b.priority.compareTo(a.priority));
    return sortedTasks;
  }

  // Sort tasks by due date
  List<Task> getTasksSortedByDueDate() {
    final sortedTasks = List<Task>.from(_tasks);
    sortedTasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return sortedTasks;
  }

  // Load tasks from storage
  Future<void> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('tasks');

      if (tasksJson != null) {
        final tasksData = json.decode(tasksJson) as List<dynamic>;
        _tasks = tasksData.map((taskJson) => Task.fromJson(taskJson)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  // Save tasks to disk
  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksData = _tasks.map((task) => task.toJson()).toList();
      await prefs.setString('tasks', json.encode(tasksData));
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  void addCategory(String categoryName) {
    if (categoryName.isNotEmpty && !categories.contains(categoryName)) {
      _currentCategory = categoryName;
      notifyListeners();
    }
  }

  void deleteCategory(String category) {
    if (category != 'All') {
      // Update all tasks in this category to have no category
      for (int i = 0; i < _tasks.length; i++) {
        if (_tasks[i].category == category) {
          _tasks[i] = _tasks[i].copyWith(category: null);
        }
      }

      // Set current category to All if we're in the deleted category
      if (_currentCategory == category) {
        _currentCategory = 'All';
      }

      _saveToDisk();
      notifyListeners();
    }
  }
}
