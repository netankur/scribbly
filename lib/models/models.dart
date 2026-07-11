import 'package:flutter/material.dart';

extension DateTimeFormatting on DateTime {
  String get formatted {
    final now = DateTime.now();
    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(year, month, day))
        .inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[month - 1]} $day';
  }
}

class Note {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  String? folderId;
  List<String> tags;
  bool isPinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.tags = const [],
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'folderId': folderId,
      'tags': tags,
      'isPinned': isPinned,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      folderId: map['folderId'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      isPinned: map['isPinned'] ?? false,
    );
  }
}

class Task {
  String id;
  String title;
  bool isCompleted;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }
}

class AppFolder {
  String id;
  String name;
  String? colorHex;

  AppFolder({
    required this.id,
    required this.name,
    this.colorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
    };
  }

  factory AppFolder.fromMap(Map<String, dynamic> map) {
    return AppFolder(
      id: map['id'],
      name: map['name'],
      colorHex: map['colorHex'],
    );
  }
}

class DrawingPath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawingPath({required this.points, required this.color, required this.strokeWidth});

  Map<String, dynamic> toMap() {
    return {
      'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
    };
  }

  factory DrawingPath.fromMap(Map<String, dynamic> map) {
    return DrawingPath(
      points: (map['points'] as List).map((p) => Offset(p['dx'], p['dy'])).toList(),
      color: Color(map['color']),
      strokeWidth: map['strokeWidth'],
    );
  }
}

class CanvasDrawing {
  String id;
  String title;
  List<DrawingPath> paths;
  DateTime createdAt;
  DateTime updatedAt;
  String? previewImagePath;

  CanvasDrawing({
    required this.id,
    required this.title,
    required this.paths,
    required this.createdAt,
    required this.updatedAt,
    this.previewImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'paths': paths.map((p) => p.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'previewImagePath': previewImagePath,
    };
  }

  factory CanvasDrawing.fromMap(Map<String, dynamic> map) {
    return CanvasDrawing(
      id: map['id'],
      title: map['title'],
      paths: (map['paths'] as List?)?.map((p) => DrawingPath.fromMap(p)).toList() ?? [],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      previewImagePath: map['previewImagePath'],
    );
  }
}
