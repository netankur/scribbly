import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scribbly_provider.dart';
import '../models/models.dart';
import '../widgets/glass_container.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;
  String _selectedTag = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
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
            middle: Text('Notes', style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
            largeTitle: Row(
              children: [
                Expanded(child: Text('Notes', style: TextStyle(color: CupertinoColors.label.resolveFrom(context)))),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute(builder: (_) => const NoteEditorScreen()),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToolbar(context),
                  const SizedBox(height: 16),
                  _buildChips(context),
                  const SizedBox(height: 16),
                  _buildNotesGrid(context),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: 'Search notes...',
          ),
        ),
        const SizedBox(width: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.list_bullet, color: !_isGridView ? CupertinoColors.activeBlue : CupertinoColors.systemGrey),
          onPressed: () {
            setState(() {
              _isGridView = false;
            });
          },
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.square_grid_2x2, color: _isGridView ? CupertinoColors.activeBlue : CupertinoColors.systemGrey),
          onPressed: () {
            setState(() {
              _isGridView = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChips(BuildContext context) {
    return Consumer<ScribblyProvider>(
      builder: (context, provider, child) {
        final allTags = <String>{};
        for (var note in provider.notes) {
          allTags.addAll(note.tags);
        }
        final tagsList = allTags.toList()..sort();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip(context, 'All', isSelected: _selectedTag == 'All'),
              _buildChip(context, 'Untagged', isSelected: _selectedTag == 'Untagged'),
              ...tagsList.map((tag) => _buildChip(context, tag, isSelected: _selectedTag == tag)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(BuildContext context, String label, {bool isSelected = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() {
              _selectedTag = label;
            });
          } else if (label != 'All') {
            setState(() {
              _selectedTag = 'All';
            });
          }
        },
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: BorderRadius.circular(20),
          color: isSelected 
              ? CupertinoColors.activeBlue 
              : (isDark ? CupertinoColors.secondarySystemGroupedBackground.darkColor : CupertinoColors.systemBackground.color),
          opacity: isSelected ? 0.8 : (isDark ? 0.4 : 0.7),
          child: Text(
            (label == 'All' || label == 'Untagged') ? label : '#$label',
            style: TextStyle(
              color: isSelected ? Colors.white : CupertinoColors.label.resolveFrom(context),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesGrid(BuildContext context) {
    return Consumer<ScribblyProvider>(
      builder: (context, provider, child) {
        final query = _searchController.text.toLowerCase();
        final notes = provider.notes.where((note) {
          final matchesQuery = note.title.toLowerCase().contains(query) || note.content.toLowerCase().contains(query);
          final matchesTag = _selectedTag == 'All' || 
                             (_selectedTag == 'Untagged' && note.tags.isEmpty) || 
                             note.tags.contains(_selectedTag);
          return matchesQuery && matchesTag;
        }).toList()
        ..sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        
        if (notes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No notes found.'),
            ),
          );
        }

        if (_isGridView) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return _buildNoteCard(context, notes[index]);
            },
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  height: 140,
                  child: _buildNoteCard(context, notes[index]),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? CupertinoColors.secondarySystemGroupedBackground.darkColor
        : CupertinoColors.systemBackground.color;
    final contentColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(builder: (_) => NoteEditorScreen(existingNote: note)),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        color: cardColor,
        opacity: isDark ? 0.4 : 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(CupertinoIcons.ellipsis, size: 20, color: contentColor),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: contentColor,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (note.tags.isNotEmpty)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        note.tags.first,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                Text(
                  note.updatedAt.formatted,
                  style: TextStyle(
                    fontSize: 12,
                    color: contentColor,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
