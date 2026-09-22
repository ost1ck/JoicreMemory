import 'package:joicrememory/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../chats/presentation/chats_screen.dart';
import '../../events/presentation/create_event_screen.dart';
import 'home_screen.dart';
import '../../map/presentation/event_map_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.session});

  final AuthController session;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  int _createRevision = 0;
  int _refreshSignal = 0;
  int _homeRefreshSignal = 0;
  final Set<int> _visited = {0};

  void _select(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _index = index;
      _visited.add(index);
      if (index == 0) _homeRefreshSignal++;
      if (index == 3 || index == 4) _refreshSignal++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        session: widget.session,
        refreshSignal: _homeRefreshSignal,
        onCreate: () => _select(2),
        onMap: () => _select(1),
        onProfile: () => _select(4),
      ),
      EventMapScreen(session: widget.session),
      CreateEventScreen(
        key: ValueKey(_createRevision),
        session: widget.session,
        onCreated: () {
          _createRevision++;
          _select(0);
        },
        onDraftSaved: () {
          _createRevision++;
          _select(4);
        },
      ),
      ChatsScreen(session: widget.session, refreshSignal: _refreshSignal),
      ProfileScreen(session: widget.session, refreshSignal: _refreshSignal),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < screens.length; i++)
            _visited.contains(i) ? screens[i] : SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: context.l10n.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: context.l10n.map,
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: context.l10n.create,
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: context.l10n.chats,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: context.l10n.profile,
          ),
        ],
      ),
    );
  }
}
