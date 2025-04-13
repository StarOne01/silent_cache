import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:ui';

class NoteEditorScreen extends StatefulWidget {
  final Note note;

  const NoteEditorScreen({super.key, required this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isMarkdownView = false;
  bool _isEdited = false;
  late Note _currentNote;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: _currentNote.title);
    _contentController = TextEditingController(text: _currentNote.content);

    _titleController.addListener(_markAsEdited);
    _contentController.addListener(_markAsEdited);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _markAsEdited() {
    if (!_isEdited &&
        (_titleController.text != _currentNote.title ||
            _contentController.text != _currentNote.content)) {
      setState(() {
        _isEdited = true;
      });
    }
  }

  void _saveNote() {
    if (_isEdited) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final updatedNote = _currentNote.copyWith(
        title: _titleController.text,
        content: _contentController.text,
      );
      noteProvider.updateNote(updatedNote);
      setState(() {
        _currentNote = updatedNote;
        _isEdited = false;
      });
    }
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => SciFiAlertDialog(
        title: 'Delete Note',
        content:
            'This action cannot be undone. Are you sure you want to delete this note?',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Provider.of<NoteProvider>(context, listen: false)
                  .deleteNote(_currentNote.id);
              Navigator.pop(context); // Go back
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _togglePin() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final updatedNote = _currentNote.copyWith(isPinned: !_currentNote.isPinned);
    noteProvider.updateNote(updatedNote);
    setState(() {
      _currentNote = updatedNote;
    });
  }

  void _toggleFavorite() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final updatedNote =
        _currentNote.copyWith(isFavorite: !_currentNote.isFavorite);
    noteProvider.updateNote(updatedNote);
    setState(() {
      _currentNote = updatedNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).colorScheme.background;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_isEdited) {
                showDialog(
                  context: context,
                  builder: (context) => SciFiAlertDialog(
                    title: 'Save changes?',
                    content:
                        'You have unsaved changes. Do you want to save them before leaving?',
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
                          _saveNote();
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
          title: const Text(
            'Edit Note',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isMarkdownView ? Icons.edit : Icons.preview,
                color: primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _isMarkdownView = !_isMarkdownView;
                });
              },
            ),
            IconButton(
              icon: Icon(
                _currentNote.isPinned
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                color: _currentNote.isPinned ? primaryColor : null,
              ),
              onPressed: _togglePin,
            ),
            IconButton(
              icon: Icon(
                _currentNote.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _currentNote.isFavorite
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
              onPressed: _toggleFavorite,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: primaryColor),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteNote();
                } else if (value == 'share') {
                  // Implement share functionality
                } else if (value == 'move') {
                  // Implement move to folder functionality
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'move',
                  child: Row(
                    children: [
                      Icon(Icons.folder),
                      SizedBox(width: 8),
                      Text('Move to folder'),
                    ],
                  ),
                ),
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
                onPressed: _saveNote,
                backgroundColor: primaryColor,
                child: const Icon(Icons.save, color: Colors.black),
              ),
      ),
    );
  }

  Widget _buildEditView() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).colorScheme.background;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        image: DecorationImage(
          image: const AssetImage('assets/images/grid_pattern.png'),
          fit: BoxFit.cover,
          opacity: 0.03,
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _contentController,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: 'Write your note here...',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkdownView() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        image: DecorationImage(
          image: const AssetImage('assets/images/grid_pattern.png'),
          fit: BoxFit.cover,
          opacity: 0.03,
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                _titleController.text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Markdown(
                  data: _contentController.text,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                    h1: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    code: TextStyle(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      color: primaryColor,
                      fontFamily: 'monospace',
                    ),
                    codeblockPadding: const EdgeInsets.all(12),
                    codeblockDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    tableHead: TextStyle(fontWeight: FontWeight.bold),
                    tableBody: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    horizontalRuleDecoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SciFiAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  const SciFiAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                color:
                    Theme.of(context).colorScheme.background.withOpacity(0.5),
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
                    title,
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
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.background.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
