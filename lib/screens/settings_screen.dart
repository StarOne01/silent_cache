import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../services/file_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Sorting'),
          _buildSortOption(
            context,
            'Date Created (Newest First)',
            Icons.calendar_today,
            () => _sortNotes(context, 'date', false),
          ),
          _buildSortOption(
            context,
            'Date Created (Oldest First)',
            Icons.calendar_today_outlined,
            () => _sortNotes(context, 'date', true),
          ),
          _buildSortOption(
            context,
            'Title (A to Z)',
            Icons.title,
            () => _sortNotes(context, 'title', true),
          ),
          _buildSortOption(
            context,
            'Title (Z to A)',
            Icons.title_outlined,
            () => _sortNotes(context, 'title', false),
          ),
          
          _buildSectionHeader(context, 'Data Management'),
          // Import options
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showImportOptions(context),
          ),
          // Export options
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showExportOptions(context),
          ),
          // Backup and restore
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showBackupOptions(context),
          ),
          
          _buildSectionHeader(context, 'Appearance'),
          // You can add theme settings here
          
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Silent Cache'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _sortNotes(BuildContext context, String sortBy, bool ascending) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    if (sortBy == 'date') {
      noteProvider.sortNotesByDate(ascending: ascending);
    } else if (sortBy == 'title') {
      noteProvider.sortNotesByTitle(ascending: ascending);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notes sorted by $sortBy'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showImportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Import Notes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose an option to import notes:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: const Text('Import Markdown/Text File'),
                subtitle: const Text('Import a single note from .md or .txt file'),
                onTap: () async {
                  Navigator.pop(context);
                  await _importSingleNote(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.data_object),
                title: const Text('Import JSON'),
                subtitle: const Text('Import multiple notes from a JSON file'),
                onTap: () async {
                  Navigator.pop(context);
                  await _importNotesFromJson(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showExportOptions(BuildContext context) {
    final selectedNote = Provider.of<NoteProvider>(context, listen: false).notes.isNotEmpty
        ? Provider.of<NoteProvider>(context, listen: false).notes.first
        : null;
        
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Export Notes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose an export format:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.dataset),
                title: const Text('Export All Notes (JSON)'),
                subtitle: const Text('Export all notes as a JSON file'),
                onTap: () async {
                  Navigator.pop(context);
                  await _exportAllNotesAsJson(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Export All Notes (CSV)'),
                subtitle: const Text('Export all notes as a CSV file'),
                onTap: () async {
                  Navigator.pop(context);
                  await _exportNotesAsCsv(context);
                },
              ),
              if (selectedNote != null) ...[
                const Divider(),
                const Text(
                  'Export Current Note:',
                  style: TextStyle(fontSize: 16),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Export as Markdown (.md)'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _exportCurrentNoteAsMarkdown(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.text_snippet_outlined),
                  title: const Text('Export as Text (.txt)'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _exportCurrentNoteAsText(context);
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showBackupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Backup & Restore',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Create Backup'),
                subtitle: const Text('Save all your notes and settings'),
                onTap: () async {
                  Navigator.pop(context);
                  await _createBackup(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Restore from Backup'),
                subtitle: const Text('Restore notes from a previous backup'),
                onTap: () async {
                  Navigator.pop(context);
                  await _restoreBackup(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _importSingleNote(BuildContext context) async {
    try {
      final hasPermission = await FileService.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission is required', isError: true);
        }
        return;
      }

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final success = await noteProvider.importNoteFromFile();
      
      if (context.mounted) {
        if (success) {
          _showSnackBar(context, 'Note imported successfully');
        } else {
          _showSnackBar(context, 'Failed to import note', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _importNotesFromJson(BuildContext context) async {
    try {
      final hasPermission = await FileService.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission is required', isError: true);
        }
        return;
      }

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final success = await noteProvider.importNotesFromJson();
      
      if (context.mounted) {
        if (success) {
          _showSnackBar(context, 'Notes imported successfully');
        } else {
          _showSnackBar(context, 'Failed to import notes', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _exportAllNotesAsJson(BuildContext context) async {
    try {
      final hasPermission = await FileService.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission is required', isError: true);
        }
        return;
      }

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final filePath = await noteProvider.exportAllNotesAsJson();
      
      if (context.mounted) {
        _showExportSuccessDialog(context, filePath);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _exportNotesAsCsv(BuildContext context) async {
    try {
      final hasPermission = await FileService.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission is required', isError: true);
        }
        return;
      }

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final filePath = await noteProvider.exportNotesAsCSV();
      
      if (context.mounted) {
        _showExportSuccessDialog(context, filePath);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _exportCurrentNoteAsMarkdown(BuildContext context) async {
    try {
      final hasPermission = await FileService.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission is required', isError: true);
        }
        return;
      }

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      if (noteProvider.notes.isEmpty) {
        if (context.mounted) {
          _showSnackBar(context, 'No note selected', isError: true);
        }
        return;
      }

      final filePath = await noteProvider.exportNoteAsMarkdown(noteProvider.notes.first);
      
      if (context.mounted) {
        _showExportSuccessDialog(context, filePath);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _exportCurrentNoteAsText(BuildContext context) async {
    try {
      final hasPermission = await FileService.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission is required', isError: true);
        }
        return;
      }

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      if (noteProvider.notes.isEmpty) {
        if (context.mounted) {
          _showSnackBar(context, 'No note selected', isError: true);
        }
        return;
      }

      final filePath = await noteProvider.exportNoteAsText(noteProvider.notes.first);
      
      if (context.mounted) {
        _showExportSuccessDialog(context, filePath);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _createBackup(BuildContext context) async {
    try {
      final hasPermission = await FileService.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission is required', isError: true);
        }
        return;
      }

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final filePath = await noteProvider.createBackup();
      
      if (context.mounted) {
        _showExportSuccessDialog(context, filePath, isBackup: true);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    try {
      final hasPermission = await FileService.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showSnackBar(context, 'Storage permission is required', isError: true);
        }
        return;
      }

      // Confirm before restoring
      final shouldRestore = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore from Backup'),
          content: const Text(
            'This will replace all your current notes with the backup data. This cannot be undone. Are you sure you want to continue?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (shouldRestore != true) return;

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final success = await noteProvider.restoreBackup();
      
      if (context.mounted) {
        if (success) {
          _showSnackBar(context, 'Backup restored successfully');
        } else {
          _showSnackBar(context, 'Failed to restore backup', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  void _showExportSuccessDialog(BuildContext context, String filePath, {bool isBackup = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBackup ? 'Backup Created' : 'Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isBackup 
              ? 'Your backup has been saved to:' 
              : 'Your file has been exported to:'
            ),
            const SizedBox(height: 8),
            Text(
              filePath,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('You can find this file in your device storage.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              final directory = await getExternalStorageDirectory();
              if (directory != null) {
                final uri = Uri.file(directory.path);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Show in Folder'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Silent Cache'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'A minimalist, secure note-taking application built with Flutter, inspired by Obsidian\'s dark theme and functionality.'),
            SizedBox(height: 16),
            Text('Version: 0.1.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
