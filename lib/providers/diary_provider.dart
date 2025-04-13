import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry_model.dart';

class DiaryProvider with ChangeNotifier {
  List<DiaryEntry> _entries = [];
  bool _isLoading = false;

  List<DiaryEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  DiaryProvider() {
    loadEntries();
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('diary_entries') ?? [];

      _entries = entriesJson
          .map((json) => DiaryEntry.fromJson(jsonDecode(json)))
          .toList();

      // Sort by date descending (newest first)
      _entries.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error loading diary entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
          _entries.map((entry) => jsonEncode(entry.toJson())).toList();

      await prefs.setStringList('diary_entries', entriesJson);
    } catch (e) {
      debugPrint('Error saving diary entries: $e');
    }
  }

  Future<void> addEntry(DiaryEntry entry) async {
    _entries.add(entry);

    // Sort by date descending (newest first)
    _entries.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
    await saveEntries();
  }

  Future<void> updateEntry(DiaryEntry updatedEntry) async {
    final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);

    if (index != -1) {
      _entries[index] = updatedEntry;
      notifyListeners();
      await saveEntries();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
    await saveEntries();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _entries.indexWhere((entry) => entry.id == id);

    if (index != -1) {
      final entry = _entries[index];
      _entries[index] = entry.copyWith(isFavorite: !entry.isFavorite);
      notifyListeners();
      await saveEntries();
    }
  }

  List<DiaryEntry> getEntriesByMonth(DateTime month) {
    return _entries
        .where((entry) =>
            entry.date.year == month.year && entry.date.month == month.month)
        .toList();
  }

  List<DiaryEntry> searchEntries(String query) {
    final lowercaseQuery = query.toLowerCase();

    return _entries
        .where((entry) =>
            entry.title.toLowerCase().contains(lowercaseQuery) ||
            entry.content.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
}
