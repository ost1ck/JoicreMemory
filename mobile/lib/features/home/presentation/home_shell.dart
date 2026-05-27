import 'package:flutter/material.dart';

import '../../../core/session/app_session.dart';
import '../../chats/presentation/chats_screen.dart';
import '../../events/presentation/create_event_screen.dart';
import '../../events/presentation/event_list_screen.dart';
import '../../map/presentation/event_map_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.session});

  final AppSession session;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  int _refreshSignal = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      EventMapScreen(session: widget.session),
      EventListScreen(session: widget.session),
      CreateEventScreen(
        session: widget.session,
        onCreated: () => setState(() => _index = 1),
      ),
      ChatsScreen(session: widget.session, refreshSignal: _refreshSignal),
      ProfileScreen(session: widget.session, refreshSignal: _refreshSignal),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected:
            (value) => setState(() {
              _index = value;
              if (value == 3 || value == 4) {
                _refreshSignal++;
              }
            }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Мапа',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Події',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Створити',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Чати',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профіль',
          ),
        ],
      ),
    );
  }
}
