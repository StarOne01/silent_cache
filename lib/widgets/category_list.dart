import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class CategoryList extends StatelessWidget {
  final bool horizontal;

  const CategoryList({
    super.key,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final categories = taskProvider.categories;
    final currentCategory = taskProvider.currentCategory;

    if (horizontal) {
      return SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories.toList()[index];
                  final selected = category == currentCategory;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: selected,
                      selectedColor: const Color(0xFF7A6BFF).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF7A6BFF),
                      onSelected: (isSelected) {
                        taskProvider.setCurrentCategory(category);
                      },
                    ),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddCategoryDialog(context),
              splashRadius: 24,
            ),
          ],
        ),
      );
    } else {
      // Vertical list with more options
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddCategoryDialog(context),
                  splashRadius: 24,
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories.toList()[index];
              final selected = category == currentCategory;

              return ListTile(
                leading: Icon(
                  category == 'All' ? Icons.list : Icons.folder,
                  color: selected ? const Color(0xFF7A6BFF) : null,
                ),
                title: Text(
                  category,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF7A6BFF)
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: category != 'All'
                    ? IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () =>
                            _showCategoryOptions(context, category),
                        splashRadius: 24,
                      )
                    : null,
                selected: selected,
                onTap: () {
                  taskProvider.setCurrentCategory(category);
                },
              );
            },
          ),
        ],
      );
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
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
                Provider.of<TaskProvider>(context, listen: false)
                    .addCategory(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCategoryOptions(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Category'),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteCategory(context, category);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "$category"? Tasks in this category will be moved to "All".'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .deleteCategory(category);
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
  }
}
