import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/scribbly_provider.dart';
import '../widgets/glass_container.dart';
import 'canvas_editor_screen.dart';

class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? CupertinoColors.systemBackground.darkColor : CupertinoColors.secondarySystemBackground;

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            alwaysShowMiddle: false,
            backgroundColor: bgColor.withValues(alpha: 0.8),
            middle: Text('My Canvases', style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
            largeTitle: Row(
              children: [
                Expanded(child: Text('My Canvases', style: TextStyle(color: CupertinoColors.label.resolveFrom(context)))),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute(builder: (_) => const CanvasEditorScreen()),
                      );
                    },
                    child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
                  ),
                ),
              ],
            ),
            border: null,
          ),
          SliverToBoxAdapter(
            child: Consumer<ScribblyProvider>(
              builder: (context, provider, child) {
                final drawings = provider.drawings.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

                if (drawings.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.paintbrush, size: 64, color: CupertinoColors.systemGrey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No canvases yet.\nTap + to create one!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 100.0), // Space for bottom nav
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: drawings.length,
                    itemBuilder: (context, index) {
                      return _buildDrawingCard(context, drawings[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawingCard(BuildContext context, CanvasDrawing drawing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? CupertinoColors.secondarySystemGroupedBackground.darkColor
        : CupertinoColors.systemBackground.color;

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(builder: (_) => CanvasEditorScreen(existingDrawing: drawing)),
        );
      },
      child: GlassContainer(
        padding: EdgeInsets.zero,
        color: cardColor,
        opacity: isDark ? 0.4 : 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: drawing.previewImagePath != null
                  ? Image.file(
                      File(drawing.previewImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey),
                    )
                  : const Center(child: Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey)),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context).withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drawing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        drawing.updatedAt.formatted,
                        style: TextStyle(
                          color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                          fontSize: 12,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Delete Canvas?'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    context.read<ScribblyProvider>().deleteDrawing(drawing.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(CupertinoIcons.trash, size: 16, color: CupertinoColors.destructiveRed),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
