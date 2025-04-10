import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../screens/note_editor_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoteList extends StatefulWidget {
  final List<Note> notes;

  const NoteList({
    super.key,
    required this.notes,
  });

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    if (widget.notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 80, color: Color(0xFF333340)),
            SizedBox(height: 16),
            Text(
              'No notes in this folder',
              style: TextStyle(
                color: Color(0xFF7A6BFF),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                  color: const Color(0xFF7A6BFF),
                ),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                tooltip: _isGridView ? 'List View' : 'Grid View',
              ),
            ],
          ),
        ),
        Expanded(
          child: _isGridView ? _buildGridView() : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        final note = widget.notes[index];

        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        final note = widget.notes[index];

        return ListTile(
          title: Text(
            note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            _getPreviewText(note.content),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white60),
          ),
          trailing: Text(
            timeago.format(note.updatedAt),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A6BFF),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteEditorScreen(note: note),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      color: const Color(0xFF1C1C22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: const Color(0xFF333340).withOpacity(0.5),
          width: 1,
        ),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(note: note),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  _getPreviewText(note.content),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timeago.format(note.updatedAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7A6BFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPreviewText(String content) {
    // Remove markdown syntax for preview
    String preview = content
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'\*\*|\*|~~|`'), '')
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '')
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '')
        .replaceAll(RegExp(r'\n{2,}'), '\n');

    return preview;
  }
}
