import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';

class FolderList extends StatelessWidget {
  final bool horizontal;

  const FolderList({
    super.key,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final folders = noteProvider.folders;
    final currentFolder = noteProvider.currentFolder;

    if (horizontal) {
      return SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  final selected = folder == currentFolder;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(folder),
                      selected: selected,
                      selectedColor: const Color(0xFF7A6BFF).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF7A6BFF),
                      labelStyle: TextStyle(
                        color:
                            selected ? const Color(0xFF7A6BFF) : Colors.white70,
                      ),
                      side: const BorderSide(color: Color(0xFF333340)),
                      backgroundColor: const Color(0xFF1C1C22),
                      onSelected: (_) {
                        noteProvider.setCurrentFolder(folder);
                      },
                    ),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              onPressed: () => _showAddFolderDialog(context),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Folders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.create_new_folder),
                onPressed: () => _showAddFolderDialog(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              final selected = folder == currentFolder;

              return ListTile(
                leading: Icon(
                  Icons.folder,
                  color: selected ? const Color(0xFF7A6BFF) : Colors.white54,
                ),
                title: Text(
                  folder,
                  style: TextStyle(
                    color: selected ? const Color(0xFF7A6BFF) : Colors.white,
                  ),
                ),
                selected: selected,
                selectedTileColor: const Color(0xFF7A6BFF).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: () {
                  noteProvider.setCurrentFolder(folder);
                },
                onLongPress: folder != '/'
                    ? () => _showFolderOptions(context, folder)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C22),
        title: const Text(
          'Add Folder',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF333340)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF7A6BFF)),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<NoteProvider>(context, listen: false)
                    .addFolder(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Color(0xFF7A6BFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showFolderOptions(BuildContext context, String folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Folder'),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteFolder(context, folder);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFolder(BuildContext context, String folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
            'Are you sure you want to delete "$folder"? All notes will be moved to the root folder.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<NoteProvider>(context, listen: false)
                  .removeFolder(folder);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
