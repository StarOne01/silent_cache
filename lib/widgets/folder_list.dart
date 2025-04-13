import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import 'dart:ui';

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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    if (horizontal) {
      return Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders.toList()[index];
                  final selected = folder == currentFolder;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                            ? Border.all(color: primaryColor, width: 1.5)
                            : Border.all(
                                color: primaryColor.withOpacity(0.3), width: 1),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                )
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Material(
                            color: selected
                                ? primaryColor.withOpacity(0.15)
                                : theme.colorScheme.surface.withOpacity(0.5),
                            child: InkWell(
                              onTap: () =>
                                  noteProvider.setCurrentFolder(folder),
                              borderRadius: BorderRadius.circular(12),
                              splashColor: primaryColor.withOpacity(0.1),
                              highlightColor: primaryColor.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      color: selected
                                          ? primaryColor
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      folder == '/'
                                          ? 'All Notes'
                                          : folder.split('/').last,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        letterSpacing: 0.3,
                                        color: selected
                                            ? primaryColor
                                            : theme.colorScheme.onSurface
                                                .withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.create_new_folder_outlined,
                  color: primaryColor,
                  size: 20,
                ),
                onPressed: () => _showAddFolderDialog(context),
                tooltip: 'Create new folder',
                splashRadius: 24,
              ),
            ),
          ],
        ),
      );
    }

    // Vertical folder list
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Folders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.create_new_folder_outlined,
                    color: primaryColor,
                    size: 18,
                  ),
                  onPressed: () => _showAddFolderDialog(context),
                  tooltip: 'Create new folder',
                  splashRadius: 20,
                  constraints: const BoxConstraints(
                    minHeight: 36,
                    minWidth: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders.toList()[index];
              final selected = folder == currentFolder;
              final folderName =
                  folder == '/' ? 'All Notes' : folder.split('/').last;

              return Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: selected
                      ? Border.all(color: primaryColor, width: 1)
                      : Border.all(
                          color: primaryColor.withOpacity(0.2), width: 0.5),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.15),
                            blurRadius: 5,
                            spreadRadius: 0,
                          )
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    color: selected
                        ? primaryColor.withOpacity(0.15)
                        : theme.colorScheme.surface.withOpacity(0.4),
                    child: InkWell(
                      onTap: () => noteProvider.setCurrentFolder(folder),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: primaryColor.withOpacity(0.1),
                      highlightColor: primaryColor.withOpacity(0.05),
                      onLongPress: folder != '/'
                          ? () => _showFolderOptions(context, folder)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? primaryColor.withOpacity(0.2)
                                    : theme.colorScheme.surface
                                        .withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? primaryColor.withOpacity(0.5)
                                      : primaryColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.folder,
                                color: selected
                                    ? primaryColor
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              folderName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? primaryColor
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.9),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create New Folder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Folder name',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.folder_open,
                      color: primaryColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: primaryColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          Provider.of<NoteProvider>(context, listen: false)
                              .addFolder(controller.text.trim());
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFolderOptions(BuildContext context, String folder) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Text(
                'Folder Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
              ),
              title: const Text('Delete Folder'),
              subtitle: const Text(
                  'All notes in this folder will be moved to the root folder'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteFolder(context, folder);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteFolder(BuildContext context, String folder) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorColor.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: errorColor.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: errorColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Folder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: errorColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                        children: [
                          const TextSpan(
                              text: 'Are you sure you want to delete '),
                          TextSpan(
                            text: folder.split('/').last,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: '?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All notes in this folder will be moved to the root folder.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<NoteProvider>(context, listen: false)
                            .deleteFolder(folder);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
