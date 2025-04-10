import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<String> _folders = ['/'];
  String _currentFolder = '/';

  List<Note> get notes => _notes
      .where((note) =>
          note.folderPath == _currentFolder ||
          (_currentFolder == '/' && note.folderPath == null))
      .toList();

  List<Note> get allNotes => _notes;
  List<String> get folders => _folders;
  String get currentFolder => _currentFolder;

  void setCurrentFolder(String folder) {
    _currentFolder = folder;
    notifyListeners();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes');
    final foldersJson = prefs.getStringList('folders');

    if (notesJson != null) {
      _notes = notesJson
          .map((noteJson) => Note.fromJson(json.decode(noteJson)))
          .toList();
    }

    if (foldersJson != null) {
      _folders = foldersJson;
    }

    notifyListeners();
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _notes.map((note) => json.encode(note.toJson())).toList();

    await prefs.setStringList('notes', notesJson);
    await prefs.setStringList('folders', _folders);
  }

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
    saveNotes();
  }

  void updateNote(String id, String title, String content) {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex >= 0) {
      _notes[noteIndex] = _notes[noteIndex].copyWith(
        title: title,
        content: content,
      );
      notifyListeners();
      saveNotes();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
    saveNotes();
  }

  void moveNote(String id, String? folderPath) {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex >= 0) {
      _notes[noteIndex] = _notes[noteIndex].copyWith(folderPath: folderPath);
      notifyListeners();
      saveNotes();
    }
  }

  void addFolder(String folderName) {
    if (!_folders.contains(folderName)) {
      _folders.add(folderName);
      notifyListeners();
      saveNotes();
    }
  }

  void removeFolder(String folderName) {
    if (folderName != '/') {
      _folders.remove(folderName);
      // Move all notes from this folder to root
      for (int i = 0; i < _notes.length; i++) {
        if (_notes[i].folderPath == folderName) {
          _notes[i] = _notes[i].copyWith(folderPath: null);
        }
      }
      notifyListeners();
      saveNotes();
    }
  }

  List<Note> searchNotes(String query) {
    if (query.isEmpty) {
      return [];
    }

    return _notes
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
