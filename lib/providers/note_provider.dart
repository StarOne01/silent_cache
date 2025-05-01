import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../services/file_service.dart';
import 'package:flutter/material.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  String _currentFolder = '/'; // Root folder by default

  List<Note> get notes => _notes;
  String get currentFolder => _currentFolder;

  // Set current folder and notify listeners
  void setCurrentFolder(String folderPath) {
    _currentFolder = folderPath;
    notifyListeners();
  }

  // Get notes for the current folder
  List<Note> getNotesByFolder(String folderPath) {
    if (folderPath == '/') {
      return _notes; // Return all notes for the root folder
    }
    return _notes.where((note) => note.folderPath == folderPath).toList();
  }

  // Get all folders
  Set<String> get folders {
    Set<String> result = {'/'}; // Root folder is always present
    for (var note in _notes) {
      if (note.folderPath != null && note.folderPath!.isNotEmpty) {
        result.add(note.folderPath!);
      }
    }
    return result;
  }

  // Add note
  void addNote(Note note) {
    _notes.add(note);
    _saveToDisk();
    notifyListeners();
  }

  // Add multiple notes
  void addNotes(List<Note> notes) {
    _notes.addAll(notes);
    _saveToDisk();
    notifyListeners();
  }

  // Update note
  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index >= 0) {
      _notes[index] = updatedNote;
      _saveToDisk();
      notifyListeners();
    }
  }

  // Delete note
  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveToDisk();
    notifyListeners();
  }

  // Toggle pin status
  void togglePin(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index >= 0) {
      _notes[index].isPinned = !_notes[index].isPinned;
      _saveToDisk();
      notifyListeners();
    }
  }

  // Toggle favorite status
  void toggleFavorite(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index >= 0) {
      _notes[index].isFavorite = !_notes[index].isFavorite;
      _saveToDisk();
      notifyListeners();
    }
  }

  // Search notes
  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes;

    final lowerCaseQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(lowerCaseQuery) ||
          note.content.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }

  // Sort notes by date
  void sortNotesByDate({bool ascending = true}) {
    if (ascending) {
      _notes.sort((a, b) => a.dateModified.compareTo(b.dateModified));
    } else {
      _notes.sort((a, b) => b.dateModified.compareTo(a.dateModified));
    }
    notifyListeners();
  }

  // Sort notes by title
  void sortNotesByTitle({bool ascending = true}) {
    if (ascending) {
      _notes.sort((a, b) => a.title.compareTo(b.title));
    } else {
      _notes.sort((a, b) => b.title.compareTo(a.title));
    }
    notifyListeners();
  }

  // Load notes from storage
  Future<void> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString('notes');

      if (notesJson != null) {
        final notesData = json.decode(notesJson) as List<dynamic>;
        _notes = notesData.map((noteJson) => Note.fromJson(noteJson)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
  }

  // Save notes to disk
  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesData = _notes.map((note) => note.toJson()).toList();
      await prefs.setString('notes', json.encode(notesData));
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  // Create a new folder
  void createFolder(String folderPath) {
    // Nothing to do here but notify listeners
    notifyListeners();
  }

  // Delete folder and all notes in it
  void deleteFolder(String folderPath) {
    _notes.removeWhere((note) => note.folderPath == folderPath);
    _saveToDisk();
    notifyListeners();
  }

  // Move note to a different folder
  void moveNoteToFolder(String noteId, String? destinationFolder) {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(folderPath: destinationFolder);
      _saveToDisk();
      notifyListeners();
    }
  }

  // Get all favorite notes
  List<Note> get favoritedNotes {
    return _notes.where((note) => note.isFavorite).toList();
  }

  void addFolder(String folderName) {
    if (!folders.contains(folderName)) {
      _currentFolder = folderName;
      notifyListeners();
    }
  }

  void removeFolder(String folderPath) {
    if (folderPath != '/') {
      // Move all notes from this folder to root
      final notesInFolder =
          _notes.where((note) => note.folderPath == folderPath).toList();
      for (var note in notesInFolder) {
        note = note.copyWith(folderPath: '/');
      }

      // Set current folder to root if we're in the deleted folder
      if (_currentFolder == folderPath) {
        _currentFolder = '/';
      }

      _saveToDisk();
      notifyListeners();
    }
  }

  // Export features
  Future<String> exportNoteAsMarkdown(Note note) async {
    return await FileService.exportNoteAsMarkdown(note);
  }

  Future<String> exportNoteAsText(Note note) async {
    return await FileService.exportNoteAsText(note);
  }

  Future<String> exportAllNotesAsJson() async {
    return await FileService.exportAllNotesAsJson(_notes);
  }

  Future<String> exportNotesAsCSV() async {
    return await FileService.exportNotesAsCSV(_notes);
  }

  Future<String> createBackup() async {
    return await FileService.createBackup(_notes);
  }

  // Import features
  Future<bool> restoreBackup() async {
    try {
      final restoredNotes = await FileService.restoreBackup();
      if (restoredNotes.isNotEmpty) {
        _notes = restoredNotes;
        _saveToDisk();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return false;
    }
  }

  Future<bool> importNotesFromJson() async {
    try {
      final importedNotes = await FileService.importNotesFromJson();
      if (importedNotes.isNotEmpty) {
        _notes.addAll(importedNotes);
        _saveToDisk();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing notes: $e');
      return false;
    }
  }

  Future<bool> importNoteFromFile() async {
    try {
      final note = await FileService.importNoteFromFile();
      if (note != null) {
        addNote(note);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing note: $e');
      return false;
    }
  }

  // Share a note
  Future<void> shareNote(Note note) async {
    await FileService.shareNote(note);
  }
}
