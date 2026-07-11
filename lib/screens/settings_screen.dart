import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scribbly_provider.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            largeTitle: Text('Settings', style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
            border: null,
          ),
          SliverToBoxAdapter(
            child: Consumer<ScribblyProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'APPEARANCE'),
                      _buildSettingsGroup(
                        context,
                        children: [
                          _buildSettingsTile(
                            context,
                            CupertinoIcons.moon,
                            'Theme',
                            trailing: Text(
                              provider.themeMode.name[0].toUpperCase() + provider.themeMode.name.substring(1),
                              style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                            ),
                            onTap: () => _showThemeDialog(context, provider),
                            showDivider: true,
                          ),
                          _buildSettingsTile(
                            context,
                            CupertinoIcons.paintbrush,
                            'Accent Color',
                            trailing: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: provider.accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: CupertinoColors.systemGrey5, width: 1),
                              ),
                            ),
                            onTap: () => _showColorDialog(context, provider),
                            showDivider: true,
                          ),
                          _buildSettingsTile(
                            context,
                            CupertinoIcons.textformat_size,
                            'Font Size',
                            trailing: Text(
                              provider.fontSizeScale == 1.0 ? 'Medium' : (provider.fontSizeScale < 1.0 ? 'Small' : 'Large'),
                              style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                            ),
                            onTap: () => _showFontSizeDialog(context, provider),
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildSectionHeader(context, 'DATA & PRIVACY'),
                      _buildSettingsGroup(
                        context,
                        children: [
                          _buildSettingsTile(
                            context,
                            CupertinoIcons.cloud_upload,
                            'Export Backup',
                            onTap: () async {
                              final path = await provider.exportData();
                              if (!context.mounted) return;
                              _showCupertinoAlert(
                                context, 
                                path != null ? 'Success' : 'Notice', 
                                path != null ? 'Backup saved successfully.' : 'Export cancelled or failed.'
                              );
                            },
                            showDivider: true,
                          ),
                          _buildSettingsTile(
                            context,
                            CupertinoIcons.cloud_download,
                            'Restore Backup',
                            onTap: () async {
                              final success = await provider.importData();
                              if (!context.mounted) return;
                              _showCupertinoAlert(
                                context, 
                                success ? 'Success' : 'Error', 
                                success ? 'Data restored successfully.' : 'Failed to restore data.'
                              );
                            },
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _buildFooter(context),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCupertinoAlert(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ScribblyProvider provider) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Theme'),
        actions: ThemeMode.values.map((mode) {
          final modeName = mode.name[0].toUpperCase() + mode.name.substring(1);
          return CupertinoActionSheetAction(
            onPressed: () {
              provider.setThemeMode(mode);
              Navigator.pop(context);
            },
            child: Text(modeName, style: TextStyle(
              fontWeight: provider.themeMode == mode ? FontWeight.bold : FontWeight.normal,
            )),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showColorDialog(BuildContext context, ScribblyProvider provider) {
    final colors = [
      const Color(0xFF5E5CE6), // Indigo
      const Color(0xFF007AFF), // Blue
      const Color(0xFFFF3B30), // Red
      const Color(0xFF34C759), // Green
      const Color(0xFFFF9500), // Orange
      const Color(0xFFAF52DE), // Purple
    ];

    showCupertinoDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return CupertinoAlertDialog(
          title: const Text('Select Accent Color'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    provider.setAccentColor(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: provider.accentColor == color ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context, ScribblyProvider provider) {
    final scales = {
      'Small': 0.85,
      'Medium': 1.0,
      'Large': 1.15,
    };

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Font Size'),
        actions: scales.entries.map((entry) {
          return CupertinoActionSheetAction(
            onPressed: () {
              provider.setFontSizeScale(entry.value);
              Navigator.pop(context);
            },
            child: Text(entry.key, style: TextStyle(
              fontWeight: provider.fontSizeScale == entry.value ? FontWeight.bold : FontWeight.normal,
            )),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      padding: EdgeInsets.zero,
      color: isDark ? CupertinoColors.secondarySystemGroupedBackground.darkColor : CupertinoColors.systemBackground.color,
      opacity: isDark ? 0.4 : 0.7,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, {Widget? trailing, VoidCallback? onTap, bool showDivider = true}) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator.resolveFrom(context).withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.activeBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 16,
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: 8),
          ],
          Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.tertiaryLabel.resolveFrom(context), size: 20),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'SCRIBBLY v1.0.0',
            style: TextStyle(
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('About Scribbly'),
                  content: const Text('Scribbly is your ultimate companion for taking notes, sketching ideas, and organizing tasks.\n\nVersion 1.0.0'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('Close'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
            child: const Text('About Scribbly', style: TextStyle(fontSize: 14)),
          ),
        )
      ],
    );
  }
}
