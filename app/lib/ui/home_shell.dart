import 'package:flutter/material.dart';

import 'debug_page.dart';
import 'discovery_page.dart';
import 'home_page.dart';
import 'library_page.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'widgets/mini_player.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _pages = [
    HomePage(),
    DiscoveryPage(),
    LibraryPage(),
    SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _tab, children: _pages),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.travel_explore_outlined),
                selectedIcon: Icon(Icons.travel_explore),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Spotless'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: 'Diagnostics & Debug',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DebugPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(SettingsPage.route);
            },
          ),
        ],
      ),
    );
  }
}
