import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note_model.dart';
import 'note_editor_screen.dart';
import '../widgets/folder_list.dart';
import '../widgets/note_list.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteProvider(),
      child: const Scaffold(
        body: NotesView(),
      ),
    );
  }
}

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String searchQuery = '';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<NoteProvider>(context, listen: false).loadNotes();
    });
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
      isSearching = query.isNotEmpty;
    });
  }

  void _createNewNote() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final newNote = Note(
      title: 'New Note',
      content: '',
      folderPath:
          noteProvider.currentFolder == '/' ? null : noteProvider.currentFolder,
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
    final noteProvider = Provider.of<NoteProvider>(context);
    final notes = isSearching
        ? noteProvider.searchNotes(searchQuery)
        : noteProvider.getNotesByFolder(noteProvider.currentFolder);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          noteProvider.currentFolder == '/'
              ? 'All Notes'
              : noteProvider.currentFolder.split('/').last,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(noteProvider),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchBar(
              onSearch: _handleSearch,
              hint: 'Search notes...',
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: FolderList(horizontal: true),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes yet',
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
                          'Create a new note to get started',
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
                : NoteList(notes: notes),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort Notes By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date Created (Newest First)'),
              onTap: () {
                noteProvider.sortNotesByDate(ascending: false);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Date Created (Oldest First)'),
              onTap: () {
                noteProvider.sortNotesByDate(ascending: true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Title (A to Z)'),
              onTap: () {
                noteProvider.sortNotesByTitle(ascending: true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.title_outlined),
              title: const Text('Title (Z to A)'),
              onTap: () {
                noteProvider.sortNotesByTitle(ascending: false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NoteSearchDelegate extends SearchDelegate<String> {
  final NoteProvider noteProvider;

  NoteSearchDelegate(this.noteProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchResults = noteProvider.searchNotes(query);

    return NoteList(notes: searchResults);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    final suggestions = noteProvider.searchNotes(query);

    return NoteList(notes: suggestions);
  }
}
