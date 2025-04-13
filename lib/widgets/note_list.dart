import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/note_model.dart';
import '../screens/note_editor_screen.dart';
import 'dart:ui';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  final bool showFolderName;

  const NoteList({
    super.key,
    required this.notes,
    this.showFolderName = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return SciFiNoteCard(
          note: note,
          showFolderName: showFolderName,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    NoteEditorScreen(note: note),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = const Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                      position: offsetAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
        );
      },
    );
  }
}

class SciFiNoteCard extends StatefulWidget {
  final Note note;
  final bool showFolderName;
  final VoidCallback onTap;

  const SciFiNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.showFolderName = false,
  });

  @override
  State<SciFiNoteCard> createState() => _SciFiNoteCardState();
}

class _SciFiNoteCardState extends State<SciFiNoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final preview = note.content.trim().isEmpty
        ? 'No content'
        : note.content.length > 100
            ? '${note.content.substring(0, 100)}...'
            : note.content;

    return FadeTransition(
      opacity: _animation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: note.isPinned
                      ? primaryColor
                      : primaryColor.withOpacity(0.3),
                  width: note.isPinned ? 1.5 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  splashColor: primaryColor.withOpacity(0.1),
                  highlightColor: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                note.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (note.isPinned)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.push_pin,
                                  color: primaryColor,
                                  size: 16,
                                ),
                              ),
                            if (note.isFavorite)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.favorite,
                                    color: theme.colorScheme.error,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            preview,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.showFolderName &&
                                note.folderPath != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.folder,
                                        size: 12, color: primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      note.folderPath!.split('/').last,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryColor.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.background
                                    .withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeago.format(note.dateModified),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
