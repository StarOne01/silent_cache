import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskEditorScreen extends StatefulWidget {
  final Task task;

  const TaskEditorScreen({super.key, required this.task});

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isEdited = false;
  late Task _currentTask;
  DateTime? _dueDate;
  String? _selectedCategory;
  int _priority = 1;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _titleController = TextEditingController(text: _currentTask.title);
    _descriptionController =
        TextEditingController(text: _currentTask.description ?? '');
    _dueDate = _currentTask.dueDate;
    _selectedCategory = _currentTask.category;
    _priority = _currentTask.priority;

    _titleController.addListener(_markAsEdited);
    _descriptionController.addListener(_markAsEdited);
  }

  void _markAsEdited() {
    if (!_isEdited) {
      setState(() {
        _isEdited = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final updatedTask = Task(
      id: _currentTask.id,
      title: _titleController.text.trim().isEmpty
          ? 'Untitled Task'
          : _titleController.text,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text,
      dateCreated: _currentTask.dateCreated,
      dueDate: _dueDate,
      isCompleted: _currentTask.isCompleted,
      category: _selectedCategory,
      priority: _priority,
    );

    // Check if this is a new task or an update
    if (taskProvider.tasks.any((task) => task.id == updatedTask.id)) {
      taskProvider.updateTask(updatedTask);
    } else {
      taskProvider.addTask(updatedTask);
    }

    // Reset edit flag
    setState(() {
      _isEdited = false;
      _currentTask = updatedTask;
    });

    // Show a success message
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task saved')),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
        _markAsEdited();
      });
    }
  }

  void _showCategoryPicker() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final categories =
        taskProvider.categories.where((cat) => cat != 'All').toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('None'),
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                    _markAsEdited();
                  });
                  Navigator.pop(context);
                },
              ),
              ...categories.map(
                (category) => ListTile(
                  title: Text(category),
                  selected: category == _selectedCategory,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _markAsEdited();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Category'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddCategoryDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final taskProvider =
                    Provider.of<TaskProvider>(context, listen: false);
                taskProvider.addCategory(controller.text.trim());
                setState(() {
                  _selectedCategory = controller.text.trim();
                  _markAsEdited();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Widget to select priority
  Widget _buildPrioritySelector() {
    return Row(
      children: [
        const Text('Priority:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 16),
        _buildPriorityButton('Low', 0),
        const SizedBox(width: 8),
        _buildPriorityButton('Medium', 1),
        const SizedBox(width: 8),
        _buildPriorityButton('High', 2),
      ],
    );
  }

  Widget _buildPriorityButton(String label, int value) {
    final isSelected = _priority == value;

    Color getColor() {
      switch (value) {
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

    return InkWell(
      onTap: () {
        setState(() {
          _priority = value;
          _markAsEdited();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? getColor().withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? getColor() : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? getColor()
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isEdited) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Save changes?'),
                  content: const Text(
                      'You have unsaved changes. Do you want to save them before leaving?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back without saving
                      },
                      child: const Text('Discard'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _saveTask().then((_) {
                          Navigator.pop(context); // Go back after saving
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Edit Task'),
        actions: [
          // Delete button
          if (_currentTask.id.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text(
                        'Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Provider.of<TaskProvider>(context, listen: false)
                              .deleteTask(_currentTask.id);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          // Toggle completion
          IconButton(
            icon: Icon(
              _currentTask.isCompleted
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: _currentTask.isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () {
              final taskProvider =
                  Provider.of<TaskProvider>(context, listen: false);
              taskProvider.toggleTaskCompletion(_currentTask.id);
              setState(() {
                _currentTask = Task(
                  id: _currentTask.id,
                  title: _currentTask.title,
                  description: _currentTask.description,
                  dateCreated: _currentTask.dateCreated,
                  dueDate: _currentTask.dueDate,
                  isCompleted: !_currentTask.isCompleted,
                  category: _currentTask.category,
                  priority: _currentTask.priority,
                );
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                decoration: _currentTask.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
              decoration: const InputDecoration(
                hintText: 'Task Title',
                border: InputBorder.none,
              ),
            ),

            const Divider(),

            // Due date selector
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Due Date'),
              subtitle: Text(
                _dueDate == null
                    ? 'No due date'
                    : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
              ),
              onTap: _selectDueDate,
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                          _markAsEdited();
                        });
                      },
                    )
                  : null,
            ),

            // Category selector
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Category'),
              subtitle: Text(_selectedCategory ?? 'None'),
              onTap: _showCategoryPicker,
            ),

            // Priority selector
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildPrioritySelector(),
            ),

            const Divider(),

            // Task description
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: _descriptionController,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  decoration: _currentTask.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Add details...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Save Task'),
        ),
      ),
    );
  }
}
