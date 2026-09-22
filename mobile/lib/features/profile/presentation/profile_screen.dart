import '../../../core/localization/language_selector.dart';
import 'package:joicrememory/l10n/localization.dart';
import '../../../core/ui/loading_skeleton.dart';
import '../../../core/ui/empty_state.dart';
import '../../../core/network/api_error_message.dart';
import '../../events/presentation/create_event_screen.dart';
import '../../events/presentation/event_list_screen.dart';
import '../../../app/app_scope.dart';
import 'package:flutter/material.dart';
import '../../events/presentation/widgets/event_card.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../events/domain/entities/event.dart';
import '../../events/presentation/event_details_screen.dart';
import '../../reports/presentation/reports_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.session,
    required this.refreshSignal,
  });

  final AuthController session;
  final int refreshSignal;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = AppScope.read(context).events.listMyEvents();
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
      _eventsFuture = AppScope.read(context).events.listMyEvents();
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
      ).showSnackBar(SnackBar(content: Text(context.l10n.profileUpdated)));
    }
  }

  Future<void> _createEvent() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (routeContext) => CreateEventScreen(
              session: widget.session,
              onCreated: () => Navigator.pop(routeContext),
            ),
      ),
    );
    if (mounted) _refreshEvents();
  }

  Future<void> _findEvents() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventListScreen(session: widget.session),
      ),
    );
    if (mounted) _refreshEvents();
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
        title: Text(context.l10n.profile),
        actions: [
          IconButton(
            onPressed: _editProfile,
            icon: Icon(Icons.edit_outlined),
            tooltip: context.l10n.edit,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshEvents(),
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              _ProfileHeader(
                fullName: user?.fullName ?? context.l10n.user260,
                email: user?.email ?? '',
                bio: user?.bio,
                avatarUrl: user?.avatarUrl,
              ),
              SizedBox(height: 28),
              _ProfileSectionHeading(context.l10n.myActivity),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.analytics_outlined),
                title: Text(context.l10n.reportsAndStatistics),
                subtitle: Text(
                  context.l10n.myContributionParticipationAndPdfReport,
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: _openReports,
              ),
              Divider(height: 32),
              _ProfileSectionHeading(context.l10n.settings),
              const LanguageSelector(),
              ListenableBuilder(
                listenable: AppScope.read(context).theme,
                builder:
                    (context, _) => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(Icons.dark_mode_outlined),
                      title: Text(context.l10n.darkTheme),
                      value: AppScope.read(context).theme.isDark,
                      onChanged: AppScope.read(context).theme.setDark,
                    ),
              ),
              Divider(height: 32),
              FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingSkeleton();
                  }

                  if (snapshot.hasError) {
                    return EmptyState(
                      title: context.l10n.couldNotLoadYourEvents,
                      message: context.localizeMessage(
                        apiErrorMessage(snapshot.error!),
                      ),
                      actionLabel: context.l10n.tryAgain,
                      onAction: _refreshEvents,
                      icon: Icons.cloud_off_outlined,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _EventSection(
                        title: context.l10n.eventsICreated,
                        actionLabel: context.l10n.createEvent,
                        onAction: _createEvent,
                        emptyText: context.l10n.youHavenTCreatedAnyEventsYet271,
                        events: created,
                        onChanged: _refreshEvents,
                        session: widget.session,
                      ),
                      SizedBox(height: 12),
                      _EventSection(
                        title: context.l10n.eventsIJoined,
                        actionLabel: context.l10n.findEvents,
                        onAction: _findEvents,
                        emptyText: context.l10n.youHavenTJoinedAnyEventsYet273,
                        events: joined,
                        onChanged: _refreshEvents,
                        session: widget.session,
                      ),
                    ],
                  );
                },
              ),
              Divider(height: 40),
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
      duration: Duration(milliseconds: 2500),
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
      label: context.l10n.holdToSignOut,
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
                decoration: BoxDecoration(borderRadius: borderRadius),
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
                                      : colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 10),
                            Text(
                              _isHolding
                                  ? context.l10n.keepHoldingToSignOut
                                  : context.l10n.holdToSignOut,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color:
                                    isActive
                                        ? colorScheme.error
                                        : colorScheme.onSurfaceVariant,
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

    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: colors.surfaceContainerHighest,
          foregroundImage: hasAvatarUrl ? NetworkImage(avatarUrl) : null,
          onForegroundImageError: hasAvatarUrl ? (_, _) {} : null,
          child: Text(
            initial.toUpperCase(),
            style: TextStyle(color: colors.onSurface, fontSize: 26),
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(email, style: TextStyle(color: colors.onSurfaceVariant)),
              if (bio != null && bio!.trim().isNotEmpty) ...[
                SizedBox(height: 12),
                Text(bio!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileSectionHeading extends StatelessWidget {
  const _ProfileSectionHeading(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
  );
}

class _EventSection extends StatelessWidget {
  const _EventSection({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.onChanged,
    required this.emptyText,
    required this.events,
    required this.session,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onChanged;
  final String emptyText;
  final List<Event> events;
  final AuthController session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: 14),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (events.isEmpty)
          EmptyState(
            title: emptyText,
            message:
                actionLabel == context.l10n.createEvent
                    ? context.l10n.bringPeopleTogetherAroundYourIdea
                    : context.l10n.chooseAnEventAndJoinItWillAppearHere,
            actionLabel: actionLabel,
            onAction: onAction,
          )
        else
          for (final event in events)
            Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: EventCard(
                event: event,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => EventDetailsScreen(
                            session: session,
                            event: event,
                          ),
                    ),
                  );
                  if (context.mounted) onChanged();
                },
              ),
            ),
      ],
    );
  }
}
