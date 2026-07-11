import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';
import 'package:provider/provider.dart';
import '../providers/scribbly_provider.dart';
import 'note_editor_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const HomeDashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? CupertinoColors.systemBackground.darkColor : CupertinoColors.secondarySystemBackground;

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: bgColor.withValues(alpha: 0.8),
            largeTitle: Text('Dashboard', style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
            border: null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(context),
                  const SizedBox(height: 24),
                  _buildQuickCreate(context),
                  const SizedBox(height: 32),
                  _buildRecentlyEdited(context),
                  const SizedBox(height: 100), // padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning,';
    } else if (hour < 17) {
      greeting = 'Good Afternoon,';
    } else {
      greeting = 'Good Evening,';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ready to create?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label.resolveFrom(context),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCreate(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Create',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _QuickCreateCard(
              title: 'New Note',
              subtitle: 'Blank document',
              icon: CupertinoIcons.doc_text,
              iconColor: CupertinoColors.activeBlue,
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(builder: (_) => const NoteEditorScreen()),
                );
              },
            ),
            _QuickCreateCard(
              title: 'Draw',
              subtitle: 'Blank canvas',
              icon: CupertinoIcons.paintbrush,
              iconColor: CupertinoColors.activeGreen,
              onTap: () {
                onNavigate?.call(3);
              },
            ),
            _QuickCreateCard(
              title: 'Checklist',
              subtitle: 'To-do list',
              icon: CupertinoIcons.checkmark_square,
              iconColor: CupertinoColors.activeOrange,
              onTap: () {
                onNavigate?.call(2);
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildRecentlyEdited(BuildContext context) {
    return Consumer<ScribblyProvider>(
      builder: (context, provider, child) {
        final notes = provider.notes.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Edited',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    onNavigate?.call(1);
                  },
                  child: const Text('View All', style: TextStyle(fontSize: 15)),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (notes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No recent notes.',
                    style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                  ),
                ),
              )
            else
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final cardColor = isDark
                        ? CupertinoColors.secondarySystemGroupedBackground.darkColor
                        : CupertinoColors.systemBackground.color;

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(builder: (_) => NoteEditorScreen(existingNote: note)),
                        );
                      },
                      child: GlassContainer(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(16),
                        color: cardColor,
                        opacity: isDark ? 0.4 : 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                note.content,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QuickCreateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickCreateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Create a dynamic gradient for the cards
    final baseColor = isDark ? CupertinoColors.secondarySystemGroupedBackground.darkColor : CupertinoColors.systemBackground.color;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        iconColor.withValues(alpha: isDark ? 0.2 : 0.05),
        baseColor.withValues(alpha: isDark ? 0.6 : 0.8),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        gradient: gradient,
        opacity: 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
