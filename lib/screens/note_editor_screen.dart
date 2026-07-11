import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/models.dart';
import '../providers/scribbly_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<String> _tags;
  String? _folderId;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController = TextEditingController(text: widget.existingNote?.content ?? '');
    _tags = List.from(widget.existingNote?.tags ?? []);
    _folderId = widget.existingNote?.folderId;
    _isPinned = widget.existingNote?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final provider = context.read<ScribblyProvider>();
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    if (widget.existingNote == null) {
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.isEmpty ? 'Untitled Note' : title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        folderId: _folderId,
        tags: _tags,
        isPinned: _isPinned,
      );
      provider.addNote(newNote);
    } else {
      final updatedNote = Note(
        id: widget.existingNote!.id,
        title: title.isEmpty ? 'Untitled Note' : title,
        content: content,
        createdAt: widget.existingNote!.createdAt,
        updatedAt: DateTime.now(),
        folderId: _folderId,
        tags: _tags,
        isPinned: _isPinned,
      );
      provider.updateNote(updatedNote);
    }

    Navigator.pop(context);
  }

  void _deleteNote() {
    if (widget.existingNote != null) {
      context.read<ScribblyProvider>().deleteNote(widget.existingNote!.id);
    }
    Navigator.pop(context);
  }

  void _showDeleteConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteNote();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCategorizeDialog() {
    final tagsController = TextEditingController(text: _tags.join(', '));
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final provider = context.read<ScribblyProvider>();


            return CupertinoAlertDialog(
              title: const Text('Categorize Note'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: tagsController,
                    placeholder: 'Tags (e.g. work, ideas, urgent)',
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (provider.notes.expand((n) => n.tags).toSet().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Existing Tags:', style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: provider.notes.expand((n) => n.tags).toSet().map((tag) {
                          return GestureDetector(
                            onTap: () {
                              final current = tagsController.text.trim();
                              if (current.isEmpty) {
                                tagsController.text = tag;
                              } else if (!current.split(',').map((e) => e.trim()).contains(tag)) {
                                tagsController.text = '$current, $tag';
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? CupertinoColors.systemGrey5.darkColor : CupertinoColors.systemGrey5.color,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(tag, style: const TextStyle(fontSize: 12, color: CupertinoColors.label)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    final newTags = tagsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    setState(() {
                      _tags = newTags;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Export Failed'),
          content: const Text('Cannot export an empty note.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
      return;
    }
    
    final fileName = title.isEmpty ? 'Untitled_Note' : title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Export Note'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final textToExport = '$title\n\n$content';
              await FilePicker.saveFile(
                dialogTitle: 'Save Note as TXT',
                fileName: '$fileName.txt',
                type: FileType.custom,
                allowedExtensions: ['txt'],
                bytes: Uint8List.fromList(utf8.encode(textToExport)),
              );
            },
            child: const Text('Export as TXT'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final pdf = pw.Document();
              pdf.addPage(
                pw.MultiPage(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    return [
                      if (title.isNotEmpty)
                        pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      if (title.isNotEmpty) pw.SizedBox(height: 16),
                      pw.Text(content, style: const pw.TextStyle(fontSize: 12)),
                      if (_tags.isNotEmpty) pw.SizedBox(height: 24),
                      if (_tags.isNotEmpty)
                        pw.Text('Tags: ${_tags.join(', ')}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    ];
                  },
                ),
              );
              final bytes = await pdf.save();
              await FilePicker.saveFile(
                dialogTitle: 'Save Note as PDF',
                fileName: '$fileName.pdf',
                type: FileType.custom,
                allowedExtensions: ['pdf'],
                bytes: bytes,
              );
            },
            child: const Text('Export as PDF'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: (isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemGroupedBackground).withValues(alpha: 0.8),
        border: null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() { _isPinned = !_isPinned; });
              },
              child: Icon(_isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showCategorizeDialog,
              child: const Icon(CupertinoIcons.tag),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _exportNote,
              child: const Icon(CupertinoIcons.share),
            ),
            if (widget.existingNote != null) ...[
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _showDeleteConfirmation,
                child: const Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed),
              ),
            ],
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveNote,
              child: const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeGreen),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CupertinoColors.activeOrange.withValues(alpha: 0.3)),
                      ),
                      child: Text('#$tag', style: const TextStyle(fontSize: 12, color: CupertinoColors.activeOrange)),
                    )),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'Title',
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(), // No border
                style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
                placeholderStyle: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.placeholderText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CupertinoTextField(
                  controller: _contentController,
                  placeholder: 'Start typing...',
                  padding: EdgeInsets.zero,
                  decoration: const BoxDecoration(), // No border
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                  placeholderStyle: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: CupertinoColors.placeholderText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
