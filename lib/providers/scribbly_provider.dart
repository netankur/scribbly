import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../models/models.dart';

class ScribblyProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Task> _tasks = [];
  List<AppFolder> _folders = [];
  List<CanvasDrawing> _drawings = [];

  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = const Color(0xFF5E5CE6); // Premium iOS Indigo
  double _fontSizeScale = 1.0;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<Note> get notes => _notes;
  List<Task> get tasks => _tasks;
  List<AppFolder> get folders => _folders;
  List<CanvasDrawing> get drawings => _drawings;
  
  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  double get fontSizeScale => _fontSizeScale;

  ScribblyProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final notesJson = prefs.getString('notes');
    if (notesJson != null) {
      final List<dynamic> decoded = jsonDecode(notesJson);
      _notes = decoded.map((e) => Note.fromMap(e)).toList();
    }

    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((e) => Task.fromMap(e)).toList();
    }

    final foldersJson = prefs.getString('folders');
    if (foldersJson != null) {
      final List<dynamic> decoded = jsonDecode(foldersJson);
      _folders = decoded.map((e) => AppFolder.fromMap(e)).toList();
    }

    final drawingsJson = prefs.getString('drawings');
    if (drawingsJson != null) {
      final List<dynamic> decoded = jsonDecode(drawingsJson);
      _drawings = decoded.map((e) => CanvasDrawing.fromMap(e)).toList();
    }

    final themeStr = prefs.getString('themeMode');
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == themeStr, orElse: () => ThemeMode.system);
    }
    
    final colorVal = prefs.getInt('accentColor');
    if (colorVal != null) {
      _accentColor = Color(colorVal);
    }

    _fontSizeScale = prefs.getDouble('fontSizeScale') ?? 1.0;

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.toString());
    await prefs.setInt('accentColor', _accentColor.toARGB32());
    await prefs.setDouble('fontSizeScale', _fontSizeScale);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('notes', jsonEncode(_notes.map((e) => e.toMap()).toList()));
    await prefs.setString('tasks', jsonEncode(_tasks.map((e) => e.toMap()).toList()));
    await prefs.setString('folders', jsonEncode(_folders.map((e) => e.toMap()).toList()));
    await prefs.setString('drawings', jsonEncode(_drawings.map((e) => e.toMap()).toList()));
  }

  // --- Notes ---
  void addNote(Note note) {
    _notes.add(note);
    _saveData();
    notifyListeners();
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _saveData();
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _saveData();
    notifyListeners();
  }

  // --- Tasks ---
  void addTask(Task task) {
    _tasks.add(task);
    _saveData();
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _saveData();
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveData();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  // --- Folders ---
  void addFolder(AppFolder folder) {
    _folders.add(folder);
    _saveData();
    notifyListeners();
  }

  void deleteFolder(String id) {
    _folders.removeWhere((f) => f.id == id);
    for (var note in _notes) {
      if (note.folderId == id) {
        note.folderId = null;
      }
    }
    _saveData();
    notifyListeners();
  }

  // --- Drawings ---
  void addDrawing(CanvasDrawing drawing) {
    _drawings.add(drawing);
    _saveData();
    notifyListeners();
  }

  void updateDrawing(CanvasDrawing drawing) {
    final index = _drawings.indexWhere((d) => d.id == drawing.id);
    if (index != -1) {
      _drawings[index] = drawing;
      _saveData();
      notifyListeners();
    }
  }

  void deleteDrawing(String id) {
    _drawings.removeWhere((d) => d.id == id);
    _saveData();
    notifyListeners();
  }

  // --- Settings ---
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    _saveSettings();
    notifyListeners();
  }

  void setFontSizeScale(double scale) {
    _fontSizeScale = scale;
    _saveSettings();
    notifyListeners();
  }

  // --- Backup & Restore ---
  Future<String?> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, dynamic> backupData = {
      'notes': prefs.getString('notes') ?? '[]',
      'tasks': prefs.getString('tasks') ?? '[]',
      'folders': prefs.getString('folders') ?? '[]',
      'drawings': prefs.getString('drawings') ?? '[]',
    };

    final jsonString = jsonEncode(backupData);
    final fileName = 'scribbly_backup_${DateTime.now().millisecondsSinceEpoch}.json';

    try {
      final path = await FilePicker.saveFile(
        dialogTitle: 'Save Backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(jsonString)),
      );
      
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<bool> importData() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String contents = await file.readAsString();
        Map<String, dynamic> backupData = jsonDecode(contents);

        final prefs = await SharedPreferences.getInstance();
        if (backupData.containsKey('notes')) {
          await prefs.setString('notes', backupData['notes']);
        }
        if (backupData.containsKey('tasks')) {
          await prefs.setString('tasks', backupData['tasks']);
        }
        if (backupData.containsKey('folders')) {
          await prefs.setString('folders', backupData['folders']);
        }
        if (backupData.containsKey('drawings')) {
          await prefs.setString('drawings', backupData['drawings']);
        }

        // Reload data into memory
        await _loadData();
        return true;
      }
    } catch (e) {
      debugPrint("Import failed: $e");
    }
    return false;
  }
}
