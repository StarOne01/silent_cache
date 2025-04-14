import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';

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
