import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note_model.dart';
import 'note_editor_screen.dart';
import 'settings_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  @override
  void initState() {
    super.initState();
    // We'll load the notes in the build method instead
  }

  void _createNewDiaryEntry() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final newNote = Note(
      title: 'Diary Entry - ${DateTime.now().toString().substring(0, 10)}',
      content: '',
      folderPath: '/Diary',
    );

    noteProvider.addNote(newNote);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: newNote),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the existing provider that's established in main.dart
    final noteProvider = Provider.of<NoteProvider>(context);

    // Create a diary folder if it doesn't exist
    if (!noteProvider.folders.contains('/Diary')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        noteProvider.addFolder('/Diary');
        noteProvider.setCurrentFolder('/Diary');
      });
    }

    final diaryEntries = noteProvider.notes
        .where((note) => note.folderPath == '/Diary')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // TODO: Implement calendar view for diary entries
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: diaryEntries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No diary entries yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new entry to start your diary',
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
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: diaryEntries.length,
              itemBuilder: (context, index) {
                final entry = diaryEntries[index];
                return _buildDiaryEntryCard(entry);
              },
            ),
      // Removed the floating action button
    );
  }

  Widget _buildDiaryEntryCard(Note entry) {
    final preview = entry.content.isEmpty
        ? 'No content'
        : entry.content.length > 100
            ? '${entry.content.substring(0, 100)}...'
            : entry.content;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(note: entry),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                preview,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(entry.dateModified),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
