import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note_model.dart';

class FileService {
  // Export a single note as a markdown file
  static Future<String> exportNoteAsMarkdown(Note note) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Could not access external storage");
      }

      final fileName = "${note.title.replaceAll(RegExp(r'[^\w\s]+'), '_')}.md";
      final file = File('${directory.path}/exports/$fileName');

      // Create the exports directory if it doesn't exist
      await Directory('${directory.path}/exports').create(recursive: true);

      // Create the file contents
      final content = "# ${note.title}\n\n${note.content}";
      await file.writeAsString(content);

      return file.path;
    } catch (e) {
      debugPrint('Error exporting note: $e');
      throw Exception("Failed to export note: $e");
    }
  }

  // Export a single note as a plain text file
  static Future<String> exportNoteAsText(Note note) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Could not access external storage");
      }

      final fileName = "${note.title.replaceAll(RegExp(r'[^\w\s]+'), '_')}.txt";
      final file = File('${directory.path}/exports/$fileName');

      // Create the exports directory if it doesn't exist
      await Directory('${directory.path}/exports').create(recursive: true);

      // Create the file contents
      final content = "${note.title}\n\n${note.content}";
      await file.writeAsString(content);

      return file.path;
    } catch (e) {
      debugPrint('Error exporting note: $e');
      throw Exception("Failed to export note: $e");
    }
  }

  // Export all notes as a JSON file
  static Future<String> exportAllNotesAsJson(List<Note> notes) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Could not access external storage");
      }

      final fileName = "notes_export_${DateTime.now().millisecondsSinceEpoch}.json";
      final file = File('${directory.path}/exports/$fileName');

      // Create the exports directory if it doesn't exist
      await Directory('${directory.path}/exports').create(recursive: true);

      // Convert notes to JSON
      final List<Map<String, dynamic>> jsonList = notes.map((note) => note.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      debugPrint('Error exporting notes as JSON: $e');
      throw Exception("Failed to export notes: $e");
    }
  }

  // Export all notes as a CSV file
  static Future<String> exportNotesAsCSV(List<Note> notes) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Could not access external storage");
      }

      final fileName = "notes_export_${DateTime.now().millisecondsSinceEpoch}.csv";
      final file = File('${directory.path}/exports/$fileName');

      // Create the exports directory if it doesn't exist
      await Directory('${directory.path}/exports').create(recursive: true);

      // Convert notes to CSV format
      List<List<dynamic>> rows = [];
      
      // Add header row
      rows.add(['ID', 'Title', 'Content', 'Created Date', 'Modified Date', 'Is Pinned', 'Is Favorite', 'Folder Path']);
      
      // Add data rows
      for (var note in notes) {
        rows.add([
          note.id,
          note.title,
          note.content,
          note.dateCreated.toIso8601String(),
          note.dateModified.toIso8601String(),
          note.isPinned ? 'Yes' : 'No',
          note.isFavorite ? 'Yes' : 'No',
          note.folderPath ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv);

      return file.path;
    } catch (e) {
      debugPrint('Error exporting notes as CSV: $e');
      throw Exception("Failed to export notes as CSV: $e");
    }
  }

  // Create a full backup of the app data (notes, folders, etc.)
  static Future<String> createBackup(List<Note> notes) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Could not access external storage");
      }

      // Create a temp directory for backup files
      final tempDir = await getTemporaryDirectory();
      final backupTempDir = Directory('${tempDir.path}/backup_temp');
      if (await backupTempDir.exists()) {
        await backupTempDir.delete(recursive: true);
      }
      await backupTempDir.create();

      // Create JSON file with all notes
      final notesJson = notes.map((note) => note.toJson()).toList();
      final notesFile = File('${backupTempDir.path}/notes.json');
      await notesFile.writeAsString(jsonEncode(notesJson));

      // Create backup metadata file
      final metadataFile = File('${backupTempDir.path}/metadata.json');
      await metadataFile.writeAsString(jsonEncode({
        'appVersion': '0.1.0',
        'backupDate': DateTime.now().toIso8601String(),
        'noteCount': notes.length,
      }));

      // Create the backup file (zip archive)
      final backupFileName = "silent_cache_backup_${DateTime.now().millisecondsSinceEpoch}.zip";
      final backupFilePath = '${directory.path}/$backupFileName';
      final backupFile = File(backupFilePath);
      
      // Ensure the file doesn't exist
      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      // Create the zip archive
      await ZipFile.createFromDirectory(
        sourceDir: backupTempDir,
        zipFile: backupFile,
      );

      // Clean up
      await backupTempDir.delete(recursive: true);

      return backupFilePath;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      throw Exception("Failed to create backup: $e");
    }
  }

  // Restore from a backup file
  static Future<List<Note>> restoreBackup() async {
    try {
      // Let user pick a backup file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.isEmpty) {
        throw Exception("No backup file selected");
      }

      final backupFilePath = result.files.first.path!;
      final backupFile = File(backupFilePath);

      // Create a temp directory for extraction
      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory('${tempDir.path}/restore_temp');
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create();

      // Extract the zip file
      await ZipFile.extractToDirectory(
        zipFile: backupFile,
        destinationDir: extractDir,
      );

      // Read the notes from the backup
      final notesFile = File('${extractDir.path}/notes.json');
      if (!await notesFile.exists()) {
        throw Exception("Invalid backup file: no notes found");
      }

      final notesJsonString = await notesFile.readAsString();
      final notesJsonList = jsonDecode(notesJsonString) as List<dynamic>;
      final restoredNotes = notesJsonList
          .map((json) => Note.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // Clean up
      await extractDir.delete(recursive: true);

      return restoredNotes;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      throw Exception("Failed to restore backup: $e");
    }
  }

  // Import notes from a JSON file
  static Future<List<Note>> importNotesFromJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        throw Exception("No file selected");
      }

      final filePath = result.files.first.path!;
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;

      return jsonList
          .map((json) => Note.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error importing notes: $e');
      throw Exception("Failed to import notes: $e");
    }
  }

  // Import a single note from markdown or text file
  static Future<Note?> importNoteFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'txt'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final filePath = result.files.first.path!;
      final file = File(filePath);
      final content = await file.readAsString();
      
      final fileName = result.files.first.name;
      String title = fileName;
      
      // Remove file extension
      if (title.contains('.')) {
        title = title.substring(0, title.lastIndexOf('.'));
      }

      // For markdown files, try to extract the title from the content
      if (fileName.endsWith('.md')) {
        final lines = content.split('\n');
        if (lines.isNotEmpty && lines[0].startsWith('# ')) {
          title = lines[0].substring(2).trim();
          // Remove the title from content
          final contentWithoutTitle = lines.sublist(1).join('\n').trim();
          return Note(
            title: title,
            content: contentWithoutTitle,
          );
        }
      }

      return Note(
        title: title,
        content: content,
      );
    } catch (e) {
      debugPrint('Error importing note from file: $e');
      throw Exception("Failed to import note from file: $e");
    }
  }

  // Share a note with other apps
  static Future<void> shareNote(Note note) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${note.title.replaceAll(RegExp(r'[^\w\s]+'), '_')}.md');
      
      // Create markdown content
      final content = "# ${note.title}\n\n${note.content}";
      await file.writeAsString(content);
      
      await Share.shareFiles([file.path], text: 'Check out my note: ${note.title}');
    } catch (e) {
      debugPrint('Error sharing note: $e');
      throw Exception("Failed to share note: $e");
    }
  }

  // Request storage permissions
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}