import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/session/app_session.dart';
import '../../events/data/event.dart';
import '../../events/presentation/event_details_screen.dart';
import '../../reports/presentation/reports_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.session,
    required this.refreshSignal,
  });

  final AppSession session;
  final int refreshSignal;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = widget.session.eventApi.listMyEvents();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshSignal != widget.refreshSignal) {
      _refreshEvents();
    }
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = widget.session.eventApi.listMyEvents();
    });
  }

  Future<void> _editProfile() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(session: widget.session),
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Профіль оновлено')));
    }
  }

  void _openReports() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReportsScreen(session: widget.session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        actions: [
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Редагувати',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshEvents(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _ProfileHeader(
                fullName: user?.fullName ?? 'Користувач',
                email: user?.email ?? '',
                bio: user?.bio,
                avatarUrl: user?.avatarUrl,
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Темна тема'),
                  value: widget.session.isDarkTheme,
                  onChanged: widget.session.setDarkTheme,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('Звіти'),
                  subtitle: const Text('Аналітика, PDF та друк'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openReports,
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final events = snapshot.data ?? [];
                  final created =
                      events
                          .where((event) => event.creatorUserId == user?.id)
                          .toList();
                  final joined =
                      events
                          .where((event) => event.creatorUserId != user?.id)
                          .toList();

                  return Column(
                    children: [
                      _EventSection(
                        title: 'Мої створені події',
                        emptyText: 'Ти ще не створював подій',
                        events: created,
                        session: widget.session,
                      ),
                      const SizedBox(height: 12),
                      _EventSection(
                        title: 'Я учасник',
                        emptyText: 'Ти ще не долучався до подій',
                        events: joined,
                        session: widget.session,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _HoldToLogoutButton(onConfirmed: widget.session.signOut),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoldToLogoutButton extends StatefulWidget {
  const _HoldToLogoutButton({required this.onConfirmed});

  final VoidCallback onConfirmed;

  @override
  State<_HoldToLogoutButton> createState() => _HoldToLogoutButtonState();
}

class _HoldToLogoutButtonState extends State<_HoldToLogoutButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHolding = false;
  bool _didConfirm = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && !_didConfirm) {
        _didConfirm = true;
        widget.onConfirmed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHold() {
    if (_didConfirm) {
      return;
    }

    setState(() => _isHolding = true);
    _controller.forward(from: 0);
  }

  void _cancelHold() {
    if (_didConfirm) {
      return;
    }

    setState(() => _isHolding = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(28);

    return Semantics(
      button: true,
      label: 'Затисни, щоб вийти',
      child: Listener(
        onPointerDown: (_) => _startHold(),
        onPointerUp: (_) => _cancelHold(),
        onPointerCancel: (_) => _cancelHold(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final isActive = _controller.value > 0;

            return SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: isActive ? colorScheme.error : colorScheme.outline,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _controller.value,
                        child: ColoredBox(
                          color: colorScheme.error.withAlpha(52),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.logout,
                              color:
                                  isActive
                                      ? colorScheme.error
                                      : colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isHolding
                                  ? 'Тримай, щоб вийти'
                                  : 'Затисни, щоб вийти',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color:
                                    isActive
                                        ? colorScheme.error
                                        : colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.email,
    this.bio,
    this.avatarUrl,
  });

  final String fullName;
  final String email;
  final String? bio;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = this.avatarUrl;
    final hasAvatarUrl = avatarUrl != null && avatarUrl.isNotEmpty;
    final initial = fullName.trim().isEmpty ? '?' : fullName.characters.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.shadowGrey,
              foregroundImage: hasAvatarUrl ? NetworkImage(avatarUrl) : null,
              onForegroundImageError: hasAvatarUrl ? (_, _) {} : null,
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 26),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(email),
                  if (bio != null && bio!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(bio!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventSection extends StatelessWidget {
  const _EventSection({
    required this.title,
    required this.emptyText,
    required this.events,
    required this.session,
  });

  final String title;
  final String emptyText;
  final List<Event> events;
  final AppSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              Text(emptyText)
            else
              ...events.map(
                (event) => _ProfileEventTile(
                  event: event,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => EventDetailsScreen(
                              session: session,
                              event: event,
                            ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEventTile extends StatelessWidget {
  const _ProfileEventTile({required this.event, required this.onTap});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM HH:mm');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: const Icon(Icons.event_available_outlined),
      title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${event.locationName} · ${formatter.format(event.startsAt.toLocal())}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
