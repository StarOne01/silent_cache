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
        : noteProvider.notes;

    // Responsive layout
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Silent Notes'),
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
        ],
      ),
      body: isWideScreen
          ? Row(
              children: [
                // Left sidebar for folders
                SizedBox(
                  width: 250,
                  child: FolderList(),
                ),
                // Vertical divider
                const VerticalDivider(width: 1, thickness: 1),
                // Right side for notes
                Expanded(
                  child: NoteList(notes: notes),
                ),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FolderList(horizontal: true),
                ),
                const Divider(height: 1, thickness: 1),
                Expanded(
                  child: NoteList(notes: notes),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        child: const Icon(Icons.add),
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
