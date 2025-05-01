import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import '../services/file_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
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
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

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

    // Set initial focus to title if it's a new note with default title
    if (_currentNote.title == 'New Note' ||
        _currentNote.title == 'Untitled Note') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
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

      // Show save confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note saved'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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

  void _promptSaveBeforeExit() {
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
  }

  // Add new method to show export options dialog
  void _showExportOptions() {
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
                'Export Note',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose an export format:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Export as Markdown (.md)'),
                subtitle: const Text('Best for preserving formatting'),
                onTap: () {
                  Navigator.pop(context);
                  _exportNoteAs('markdown');
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined),
                title: const Text('Export as Text (.txt)'),
                subtitle: const Text('Plain text without formatting'),
                onTap: () {
                  Navigator.pop(context);
                  _exportNoteAs('text');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  // Method to export note in different formats
  Future<void> _exportNoteAs(String format) async {
    try {
      // First save any unsaved changes
      if (_isEdited) {
        _saveNote();
      }
      
      // Request storage permissions
      final hasPermission = await FileService.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showSnackBar('Storage permission is required to export notes', isError: true);
        }
        return;
      }
      
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      String filePath;
      
      switch (format) {
        case 'markdown':
          filePath = await noteProvider.exportNoteAsMarkdown(_currentNote);
          break;
        case 'text':
          filePath = await noteProvider.exportNoteAsText(_currentNote);
          break;
        default:
          throw Exception('Unsupported export format');
      }
      
      if (context.mounted) {
        _showExportSuccessDialog(filePath);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar('Error exporting note: ${e.toString()}', isError: true);
      }
    }
  }
  
  // Method to share the current note
  Future<void> _shareNote() async {
    try {
      // First save any unsaved changes
      if (_isEdited) {
        _saveNote();
      }
      
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.shareNote(_currentNote);
    } catch (e) {
      if (context.mounted) {
        _showSnackBar('Error sharing note: ${e.toString()}', isError: true);
      }
    }
  }

  // Method to show a folder picker dialog
  void _showFolderPicker() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final folders = noteProvider.folders.toList();
    
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
                'Move to Folder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    final isSelected = folder == _currentNote.folderPath;
                    
                    return ListTile(
                      leading: Icon(
                        Icons.folder,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(
                        folder == '/' ? 'Root Folder' : folder.split('/').last,
                        style: TextStyle(
                          fontWeight: isSelected 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () {
                        Navigator.pop(context);
                        _moveNoteToFolder(folder == '/' ? null : folder);
                      },
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Method to move note to a different folder
  void _moveNoteToFolder(String? destinationFolder) {
    if (_currentNote.folderPath == destinationFolder) return;
    
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    noteProvider.moveNoteToFolder(_currentNote.id, destinationFolder);
    
    setState(() {
      _currentNote = _currentNote.copyWith(folderPath: destinationFolder);
    });
    
    _showSnackBar('Note moved to ${destinationFolder ?? 'Root Folder'}');
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Colors.red 
            : Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _showExportSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your note has been exported to:'),
            const SizedBox(height: 8),
            Text(
              filePath,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _isMarkdownView ? _buildMarkdownView() : _buildEditView(),
        floatingActionButton: _buildFloatingActionButton(),
        bottomNavigationBar: _buildBottomToolbar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _promptSaveBeforeExit,
      ),
      title: Text(
        _isMarkdownView ? 'Preview' : 'Edit Note',
        style: const TextStyle(
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
          tooltip: _isMarkdownView ? 'Edit Mode' : 'Preview Mode',
          onPressed: () {
            setState(() {
              _isMarkdownView = !_isMarkdownView;
            });
          },
        ),
        IconButton(
          icon: Icon(
            _currentNote.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: _currentNote.isPinned ? primaryColor : null,
          ),
          tooltip: _currentNote.isPinned ? 'Unpin Note' : 'Pin Note',
          onPressed: _togglePin,
        ),
        IconButton(
          icon: Icon(
            _currentNote.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _currentNote.isFavorite
                ? Theme.of(context).colorScheme.error
                : null,
          ),
          tooltip: _currentNote.isFavorite
              ? 'Remove from Favorites'
              : 'Add to Favorites',
          onPressed: _toggleFavorite,
        ),
        _buildMoreOptionsMenu(),
      ],
    );
  }

  Widget _buildMoreOptionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
      onSelected: (value) {
        switch (value) {
          case 'delete':
            _deleteNote();
            break;
          case 'share':
            _shareNote();
            break;
          case 'move':
            _showFolderPicker();
            break;
          case 'export':
            _showExportOptions();
            break;
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
        const PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.file_download),
              SizedBox(width: 8),
              Text('Export'),
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
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_isMarkdownView) return null;

    return FloatingActionButton(
      onPressed: _saveNote,
      backgroundColor: Theme.of(context).colorScheme.primary,
      tooltip: 'Save Note',
      child: const Icon(Icons.save, color: Colors.black),
    );
  }

  Widget? _buildBottomToolbar() {
    if (_isMarkdownView) return null;

    return SafeArea(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToolbarButton('# Heading', () {
              _insertText('# ');
            }),
            _buildToolbarButton('**Bold**', () {
              _wrapSelectedText('**', '**');
            }),
            _buildToolbarButton('*Italic*', () {
              _wrapSelectedText('*', '*');
            }),
            _buildToolbarButton('- List', () {
              _insertText('- ');
            }),
            _buildToolbarButton('[ ] Task', () {
              _insertText('- [ ] ');
            }),
            _buildToolbarButton('Link', () {
              _wrapSelectedText('[', '](url)');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _insertText(String text) {
    if (!_contentFocusNode.hasFocus) {
      _contentFocusNode.requestFocus();
    }

    final currentText = _contentController.text;
    final textSelection = _contentController.selection;
    final newText = currentText.replaceRange(
      textSelection.start,
      textSelection.end,
      text,
    );

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: textSelection.start + text.length,
      ),
    );
  }

  void _wrapSelectedText(String before, String after) {
    if (!_contentFocusNode.hasFocus) {
      _contentFocusNode.requestFocus();
    }

    final currentText = _contentController.text;
    final textSelection = _contentController.selection;

    final selectedText = textSelection.textInside(currentText);

    final newText = currentText.replaceRange(
        textSelection.start, textSelection.end, '$before$selectedText$after');

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: textSelection.start +
            before.length +
            selectedText.length +
            after.length,
      ),
    );
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildContentField(),
            // Add extra space at bottom to account for toolbar
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleDisplay(),
            const SizedBox(height: 16),
            _buildContentMarkdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Material(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Title',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onSubmitted: (_) => _contentFocusNode.requestFocus(),
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return Material(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 300),
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _contentController,
          focusNode: _contentFocusNode,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.5,
          ),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Write your note here...',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleDisplay() {
    return Material(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _titleController.text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildContentMarkdown() {
    return Material(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Markdown(
          data: _contentController.text.isEmpty
              ? '_No content_'
              : _contentController.text,
          styleSheet: _buildMarkdownStyleSheet(),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return MarkdownStyleSheet(
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
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
