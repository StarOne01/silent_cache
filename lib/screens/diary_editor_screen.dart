import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/diary_entry_model.dart';
import '../providers/diary_provider.dart';

class DiaryEditorScreen extends StatefulWidget {
  final DiaryEntry entry;

  const DiaryEditorScreen({super.key, required this.entry});

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DiaryEntry _currentEntry;
  bool _isMarkdownView = false;
  bool _isEdited = false;
  String? _selectedMood;
  final List<String> _moods = ['Happy', 'Good', 'Neutral', 'Sad', 'Awful'];
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
    _titleController = TextEditingController(text: _currentEntry.title);
    _contentController = TextEditingController(text: _currentEntry.content);
    _selectedMood = _currentEntry.mood;
    _selectedDate = _currentEntry.date;

    _titleController.addListener(_markAsEdited);
    _contentController.addListener(_markAsEdited);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _markAsEdited() {
    if (!_isEdited) {
      setState(() {
        _isEdited = true;
      });
    }
  }

  void _saveEntry() {
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

    final updatedEntry = _currentEntry.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text,
      mood: _selectedMood,
      date: _selectedDate,
    );

    if (diaryProvider.entries.any((entry) => entry.id == updatedEntry.id)) {
      diaryProvider.updateEntry(updatedEntry);
    } else {
      diaryProvider.addEntry(updatedEntry);
    }

    _currentEntry = updatedEntry;
    setState(() {
      _isEdited = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Diary entry saved'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleFavorite() {
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
    diaryProvider.toggleFavorite(_currentEntry.id);
    setState(() {
      _currentEntry = _currentEntry.copyWith(
        isFavorite: !_currentEntry.isFavorite,
      );
    });
  }

  void _deleteEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content:
            const Text('Are you sure you want to delete this diary entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              final diaryProvider =
                  Provider.of<DiaryProvider>(context, listen: false);
              diaryProvider.deleteEntry(_currentEntry.id);
              Navigator.pop(context); // Go back to diary list
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _markAsEdited();
      });
    }
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
                        _saveEntry();
                        Navigator.pop(context); // Go back after saving
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
        title: const Text('Edit Diary Entry'),
        actions: [
          IconButton(
            icon: Icon(
              _isMarkdownView ? Icons.edit : Icons.preview,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _isMarkdownView = !_isMarkdownView;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _currentEntry.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _currentEntry.isFavorite
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            onPressed: _toggleFavorite,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteEntry();
              } else if (value == 'share') {
                // Implement share functionality
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isMarkdownView ? _buildMarkdownView() : _buildEditView(),
      floatingActionButton: _isMarkdownView
          ? null
          : FloatingActionButton(
              onPressed: _saveEntry,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.save),
            ),
    );
  }

  Widget _buildEditView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Entry Title',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _showDatePicker,
                tooltip: 'Change date',
              ),
            ],
          ),
          Text(
            DateFormat('EEEE, MMMM d, y').format(_selectedDate),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _buildMoodSelector(),
          const Divider(),
          Expanded(
            child: TextField(
              controller: _contentController,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Write your diary entry here...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Wrap(
      spacing: 8,
      children: [
        const Text('How are you feeling today?'),
        ..._moods.map((mood) => ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getMoodIcon(mood),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(mood),
                ],
              ),
              selected: _selectedMood == mood,
              onSelected: (selected) {
                setState(() {
                  _selectedMood = selected ? mood : null;
                  _markAsEdited();
                });
              },
            )),
      ],
    );
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'good':
        return Icons.sentiment_satisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'awful':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.emoji_emotions;
    }
  }

  Widget _buildMarkdownView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleController.text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d, y').format(_selectedDate),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (_selectedMood != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getMoodIcon(_selectedMood!),
                  size: 16,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _selectedMood!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
          const Divider(),
          Expanded(
            child: Markdown(
              data: _contentController.text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                h1: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                h2: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                h3: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                blockquote: TextStyle(
                  fontSize: 16,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                code: TextStyle(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  fontFamily: 'monospace',
                ),
                codeblockPadding: const EdgeInsets.all(8),
                codeblockDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
