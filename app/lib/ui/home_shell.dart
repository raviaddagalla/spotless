import 'package:flutter/material.dart';

import 'home_page.dart';
import 'library_page.dart';
import 'search_page.dart';
import 'widgets/mini_player.dart';

/// Root shell with a PixelPlayer-inspired 3-tab bottom navigation bar
/// (Home, Search, Library) and a persistent [MiniPlayer] above it.
///
/// The AppBar is removed from the shell; each page owns its own header
/// (gradient top bar or collapsing toolbar).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _pages = [
    HomePage(),
    SearchPage(),
    LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar — each page provides its own header.
      body: IndexedStack(index: _tab, children: _pages),
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
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded),
                label: 'Library',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
