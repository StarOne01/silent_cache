import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note note;

  const NoteEditorScreen({
    super.key,
    required this.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    Provider.of<NoteProvider>(context, listen: false).updateNote(
      widget.note.id,
      _titleController.text,
      _contentController.text,
    );
    Navigator.pop(context);
  }

  void _togglePreviewMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15151B), // Darker Obsidian background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _saveNote,
        ),
        title: TextField(
          controller: _titleController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Note title',
            hintStyle: TextStyle(color: Colors.white38),
          ),
          onChanged: (value) {
            setState(() {
              widget.note.title = value;
              widget.note.updatedAt = DateTime.now();
            });
            _saveNote();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPreviewMode ? Icons.edit : Icons.remove_red_eye,
              color: const Color(0xFF7A6BFF),
            ),
            onPressed: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
            },
            tooltip: _isPreviewMode ? 'Edit' : 'Preview',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF7A6BFF)),
            onSelected: (value) {
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1C1C22),
                    title: const Text(
                      'Delete Note',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this note?',
                      style: TextStyle(color: Colors.white70),
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
                          Provider.of<NoteProvider>(context, listen: false)
                              .deleteNote(widget.note.id);
                          Navigator.pop(context); // Close the dialog
                          Navigator.pop(context); // Go back to the home screen
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Color(0xFF7A6BFF)),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isPreviewMode
          ? Markdown(
              data: _contentController.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: Colors.white70, fontSize: 16),
                h1: const TextStyle(color: Color(0xFF7A6BFF), fontSize: 24),
                h2: const TextStyle(color: Color(0xFF7A6BFF), fontSize: 22),
                h3: const TextStyle(color: Color(0xFF7A6BFF), fontSize: 20),
                h4: const TextStyle(color: Color(0xFF7A6BFF), fontSize: 18),
                h5: const TextStyle(color: Color(0xFF7A6BFF), fontSize: 16),
                h6: const TextStyle(color: Color(0xFF7A6BFF), fontSize: 14),
                em: const TextStyle(
                    color: Colors.white70, fontStyle: FontStyle.italic),
                strong: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                blockquote: const TextStyle(color: Colors.white60),
                blockquoteDecoration: BoxDecoration(
                  color: const Color(0xFF1C1C22),
                  borderRadius: BorderRadius.circular(4),
                  border: const Border(
                    left: BorderSide(
                      color: Color(0xFF7A6BFF),
                      width: 4,
                    ),
                  ),
                ),
                code: const TextStyle(
                  backgroundColor: Color(0xFF272730),
                  color: Color(0xFF7A6BFF),
                ),
                codeblockDecoration: BoxDecoration(
                  color: const Color(0xFF272730),
                  borderRadius: BorderRadius.circular(4),
                ),
                a: const TextStyle(color: Color(0xFF7A6BFF)),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white70),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start writing...',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
              ),
            ),
      bottomNavigationBar: !_isPreviewMode
          ? BottomAppBar(
              color: const Color(0xFF1C1C22),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => _insertMarkdown('# '),
                      child: const Text(
                        'H1',
                        style: TextStyle(
                          color: Color(0xFF7A6BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _insertMarkdown('## '),
                      child: const Text(
                        'H2',
                        style: TextStyle(
                          color: Color(0xFF7A6BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                    IconButton(
                      icon: const Text(
                        '**B**',
                        style: TextStyle(
                          color: Color(0xFF7A6BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _insertMarkdown('**', '**'),
                      tooltip: 'Bold',
                    ),
                    IconButton(
                      icon: const Text(
                        '*I*',
                        style: TextStyle(
                          color: Color(0xFF7A6BFF),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      onPressed: () => _insertMarkdown('*', '*'),
                      tooltip: 'Italic',
                    ),
                    IconButton(
                      icon: const Text(
                        '~~S~~',
                        style: TextStyle(
                          color: Color(0xFF7A6BFF),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      onPressed: () => _insertMarkdown('~~', '~~'),
                      tooltip: 'Strikethrough',
                    ),
                    IconButton(
                      icon: const Icon(Icons.code, color: Color(0xFF7A6BFF)),
                      onPressed: () => _insertMarkdown('`', '`'),
                      tooltip: 'Inline Code',
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_list_bulleted,
                          color: Color(0xFF7A6BFF)),
                      onPressed: () => _insertMarkdown('- '),
                      tooltip: 'Bullet List',
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_list_numbered,
                          color: Color(0xFF7A6BFF)),
                      onPressed: () => _insertMarkdown('1. '),
                      tooltip: 'Numbered List',
                    ),
                    IconButton(
                      icon: const Icon(Icons.link, color: Color(0xFF7A6BFF)),
                      onPressed: () => _insertMarkdown('[', '](url)'),
                      tooltip: 'Link',
                    ),
                    IconButton(
                      icon: const Icon(Icons.image, color: Color(0xFF7A6BFF)),
                      onPressed: () => _insertMarkdown('![alt text](', ')'),
                      tooltip: 'Image',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _insertMarkdown(String prefix, [String? suffix]) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    final beforeText = text.substring(0, selection.start);
    final selectedText = text.substring(selection.start, selection.end);
    final afterText = text.substring(selection.end);

    final newText = suffix == null
        ? beforeText + prefix + selectedText + afterText
        : beforeText + prefix + selectedText + suffix + afterText;

    _contentController.value = _contentController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset +
            prefix.length +
            selectedText.length +
            (suffix?.length ?? 0),
      ),
    );
  }
}
