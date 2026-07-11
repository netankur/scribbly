import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/scribbly_provider.dart';
import '../widgets/glass_container.dart';

enum DrawingTool { pen, brush, eraser }

class CanvasEditorScreen extends StatefulWidget {
  final CanvasDrawing? existingDrawing;

  const CanvasEditorScreen({super.key, this.existingDrawing});

  @override
  State<CanvasEditorScreen> createState() => _CanvasEditorScreenState();
}

class _CanvasEditorScreenState extends State<CanvasEditorScreen> {
  List<DrawingPath> _paths = [];
  DrawingPath? _currentPath;
  Color _selectedColor = const Color(0xFF006a60);
  DrawingTool _selectedTool = DrawingTool.pen;
  double _strokeWidth = 4.0;
  final GlobalKey _globalKey = GlobalKey();

  Color _canvasBackgroundColor = const Color(0xFFFFFFFF);
  final List<Color> _pageBgColors = [
    const Color(0xFFFFFFFF), // White
    const Color(0xFFF7F7F7), // Off-white
    const Color(0xFFFFF9C4), // Soft Yellow
    const Color(0xFFE0F2F1), // Mint
    const Color(0xFF1C1C1E), // Dark Slate
    const Color(0xFF000000), // Black
  ];

  final List<Color> _colors = [
    const Color(0xFF006a60),
    const Color(0xFF24389c),
    const Color(0xFFba1a1a),
    const Color(0xFFd84315),
    const Color(0xFF2e7d32),
    const Color(0xFF6a1b9a),
    CupertinoColors.black,
    const Color(0xFFE5E5EA), // Light grey instead of pure white to be visible on white canvas
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingDrawing != null) {
      _paths = List.from(widget.existingDrawing!.paths);
      if (widget.existingDrawing!.backgroundColorValue != null) {
        _canvasBackgroundColor = Color(widget.existingDrawing!.backgroundColorValue!);
      }
    }
    _updateToolSettings();
  }

  void _updateToolSettings() {
    switch (_selectedTool) {
      case DrawingTool.pen:
        _strokeWidth = 4.0;
        break;
      case DrawingTool.brush:
        _strokeWidth = 16.0;
        break;
      case DrawingTool.eraser:
        _strokeWidth = 20.0;
        break;
    }
  }

  Color get _activeColor {
    if (_selectedTool == DrawingTool.eraser) {
      return _canvasBackgroundColor; // Background color
    }
    if (_selectedTool == DrawingTool.brush) {
      return _selectedColor.withValues(alpha: 0.5);
    }
    return _selectedColor;
  }

  void _onPanStart(DragStartDetails details) {
    RenderBox renderBox = _globalKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _currentPath = DrawingPath(
        points: [localPosition],
        color: _activeColor,
        strokeWidth: _strokeWidth,
      );
      _paths.add(_currentPath!);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox renderBox = _globalKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _currentPath?.points.add(localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _currentPath = null;
  }

  Future<void> _saveToGallery() async {
    final status = await Permission.storage.request();
    if (status.isDenied && Platform.isAndroid) {
      await Permission.photos.request();
    }

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(buffer, name: "scribbly_${DateTime.now().millisecondsSinceEpoch}");
      
      if (mounted) {
        _showSuccessDialog('Saved to Gallery!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error saving image');
      }
    }
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDrawing() async {
    // Generate preview
    String? previewPath;
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 0.5); 
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(buffer);
      previewPath = file.path;
    } catch (e) {
      debugPrint("Failed to generate preview: $e");
    }

    if (!mounted) return;
    
    final provider = context.read<ScribblyProvider>();
    if (widget.existingDrawing == null) {
      final newDrawing = CanvasDrawing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Canvas ${provider.drawings.length + 1}',
        paths: _paths,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        previewImagePath: previewPath,
        backgroundColorValue: _canvasBackgroundColor.toARGB32(),
      );
      provider.addDrawing(newDrawing);
    } else {
      final updatedDrawing = CanvasDrawing(
        id: widget.existingDrawing!.id,
        title: widget.existingDrawing!.title,
        paths: _paths,
        createdAt: widget.existingDrawing!.createdAt,
        updatedAt: DateTime.now(),
        previewImagePath: previewPath ?? widget.existingDrawing!.previewImagePath,
        backgroundColorValue: _canvasBackgroundColor.toARGB32(),
      );
      provider.updateDrawing(updatedDrawing);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showBgColorPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Page Color'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _pageBgColors.map((color) => GestureDetector(
                onTap: () {
                  setState(() {
                    _canvasBackgroundColor = color;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _canvasBackgroundColor == color 
                          ? CupertinoColors.activeBlue 
                          : CupertinoColors.systemGrey4,
                      width: _canvasBackgroundColor == color ? 3 : 1,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: _canvasBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Canvas'),
        backgroundColor: (isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemGroupedBackground).withValues(alpha: 0.8),
        border: null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showBgColorPicker,
              child: const Icon(CupertinoIcons.circle_righthalf_fill),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveToGallery,
              child: const Icon(CupertinoIcons.down_arrow),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveDrawing,
              child: const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeGreen),
            ),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Canvas Layer
            Positioned.fill(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    color: _canvasBackgroundColor,
                    child: CustomPaint(
                      painter: _SmoothDrawingPainter(_paths),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
            
            // Floating Toolbar Layer
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GlassContainer(
                    blur: 20,
                    opacity: 0.85,
                    borderRadius: BorderRadius.circular(30),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tools
                                _buildToolIcon(CupertinoIcons.pencil, DrawingTool.pen, 'Pen'),
                                const SizedBox(width: 12),
                                _buildToolIcon(CupertinoIcons.paintbrush, DrawingTool.brush, 'Brush'),
                                const SizedBox(width: 12),
                                _buildToolIcon(CupertinoIcons.clear_fill, DrawingTool.eraser, 'Eraser'),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  width: 1,
                                  height: 24,
                                  color: CupertinoColors.separator.resolveFrom(context),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _paths.isNotEmpty ? () {
                                    setState(() { _paths.removeLast(); });
                                  } : null,
                                  child: Icon(
                                    CupertinoIcons.arrow_counterclockwise, 
                                    color: _paths.isNotEmpty ? CupertinoColors.label.resolveFrom(context) : CupertinoColors.systemGrey,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() { _paths.clear(); });
                                  },
                                  child: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed),
                                ),
                                
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  width: 1,
                                  height: 24,
                                  color: CupertinoColors.separator.resolveFrom(context),
                                ),
                                
                                // Colors
                                ..._colors.map((color) => _buildColorButton(color)),
                              ],
                            ),
                          ),
                        ),
                        
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: 1,
                          height: 24,
                          color: CupertinoColors.separator.resolveFrom(context),
                        ),
                        
                        // Thickness Slider
                        const Icon(CupertinoIcons.circle, size: 10, color: CupertinoColors.systemGrey),
                        SizedBox(
                          width: 80,
                          child: CupertinoSlider(
                            value: _strokeWidth,
                            min: 1.0,
                            max: 40.0,
                            activeColor: CupertinoColors.activeBlue,
                            onChanged: (val) {
                              setState(() { _strokeWidth = val; });
                            },
                          ),
                        ),
                        const Icon(CupertinoIcons.circle_fill, size: 24, color: CupertinoColors.systemGrey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, DrawingTool tool, String tooltip) {
    final isSelected = _selectedTool == tool;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return CupertinoButton(
      padding: const EdgeInsets.all(8),
      color: isSelected 
          ? (isDark ? CupertinoColors.systemGrey4.darkColor : CupertinoColors.systemGrey4.color) 
          : null,
      borderRadius: BorderRadius.circular(12),
      onPressed: () {
        setState(() {
          _selectedTool = tool;
          _updateToolSettings();
        });
      },
      child: Icon(
        icon,
        color: isSelected 
            ? CupertinoColors.label.resolveFrom(context)
            : CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _selectedColor == color && _selectedTool != DrawingTool.eraser;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
          if (_selectedTool == DrawingTool.eraser) {
            _selectedTool = DrawingTool.pen;
            _updateToolSettings();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.systemGrey5,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: CupertinoColors.activeBlue.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: isSelected ? Icon(
          CupertinoIcons.checkmark_alt,
          color: color.computeLuminance() > 0.5 ? CupertinoColors.black : CupertinoColors.white,
          size: 20,
        ) : null,
      ),
    );
  }
}

class _SmoothDrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;

  _SmoothDrawingPainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingPath in paths) {
      final paint = Paint()
        ..color = drawingPath.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = drawingPath.strokeWidth;

      final path = Path();
      final points = drawingPath.points;

      if (points.isEmpty) continue;

      if (points.length == 1) {
        canvas.drawPoints(ui.PointMode.points, [points.first], paint);
      } else {
        path.moveTo(points.first.dx, points.first.dy);
        for (int i = 0; i < points.length - 1; i++) {
          final p0 = points[i];
          final p1 = points[i + 1];
          final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
          path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
        }
        path.lineTo(points.last.dx, points.last.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
