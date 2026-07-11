import 'package:flutter/cupertino.dart';
import 'home_dashboard.dart';
import 'notes_screen.dart';
import 'tasks_screen.dart';
import 'canvas_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final CupertinoTabController _tabController;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController();
    _screens = [
      HomeDashboardScreen(
        onNavigate: (index) {
          _tabController.index = index;
        },
      ),
      const NotesScreen(),
      const TasksScreen(),
      const CanvasScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.checkmark_circle),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.paintbrush),
            label: 'Canvas',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return _screens[index];
          },
        );
      },
    );
  }
}
