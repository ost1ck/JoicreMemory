import 'package:joicrememory/l10n/localization.dart';
import 'dart:async';
import 'create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../app/app_scope.dart';
import '../../../core/network/api_error_message.dart';
import '../../../core/ui/app_snack_bar.dart';
import '../../../core/ui/gradient_panel.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/entities/event.dart';
import 'controllers/event_details_controller.dart';
import 'widgets/event_card.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.session,
    required this.event,
  });
  final AuthController session;
  final Event event;
  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late final EventDetailsController _controller;
  Timer? _statusTimer;
  Event get _event => _controller.event;

  @override
  void initState() {
    super.initState();
    final scope = AppScope.read(context);
    _controller = EventDetailsController(
      scope.events,
      widget.event,
      chats: scope.chats,
      currentUserId: widget.session.currentUser?.id,
    );
    _controller.addListener(_scheduleStatus);
    _controller.initialize();
    _scheduleStatus();
  }

  void _scheduleStatus() {
    _statusTimer?.cancel();
    final now = DateTime.now();
    final dates =
        [
            _event.startsAt,
            if (_event.endsAt != null) _event.endsAt!,
          ].where((date) => date.isAfter(now)).toList()
          ..sort();
    if (dates.isNotEmpty) {
      _statusTimer = Timer(dates.first.difference(now), () {
        if (mounted) {
          setState(() {});
          _scheduleStatus();
        }
      });
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _controller.removeListener(_scheduleStatus);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    try {
      await _controller.join();
      if (mounted) {
        showSuccessSnackBar(context, context.l10n.youVeJoinedTheEvent);
      }
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(
          context,
          context.localizeMessage(apiErrorMessage(error)),
        );
      }
    }
  }

  Future<void> _leave() async {
    final confirmed = await _confirm(
      context.l10n.leaveTheEvent,
      context.l10n.youWillBeRemovedFromTheParticipantList,
      context.l10n.leave,
    );
    if (!confirmed || !mounted) return;
    try {
      await _controller.leave();
      if (mounted) showSuccessSnackBar(context, context.l10n.youVeLeftTheEvent);
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(
          context,
          context.localizeMessage(apiErrorMessage(error)),
        );
      }
    }
  }

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(action),
                ),
              ],
            ),
      ) ??
      false;

  Future<void> _delete() async {
    if (!await _confirm(
          context.l10n.deleteTheEvent,
          context.l10n.theEventAndItsChatWillBeDeletedThisCannot,
          context.l10n.delete,
        ) ||
        !mounted) {
      return;
    }
    try {
      await _controller.delete();
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(
          context,
          context.localizeMessage(apiErrorMessage(error)),
        );
      }
    }
  }

  Future<void> _manage() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (context) => SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.yourEvent,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12),
                  if (_event.status == 'draft' ||
                      _event.isDiscoverableAt(DateTime.now()))
                    ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text(context.l10n.editEvent),
                      onTap: () => Navigator.pop(context, 'edit'),
                    ),
                  if (_event.status == 'draft')
                    ListTile(
                      leading: Icon(Icons.publish),
                      title: Text(context.l10n.publish),
                      onTap: () => Navigator.pop(context, 'published'),
                    ),
                  if (_event.isDiscoverableAt(DateTime.now()) &&
                      !_event.startsAt.isAfter(DateTime.now()))
                    ListTile(
                      leading: Icon(Icons.task_alt),
                      title: Text(context.l10n.completeEvent),
                      onTap: () => Navigator.pop(context, 'completed'),
                    ),
                  if (_event.status == 'draft' ||
                      _event.isDiscoverableAt(DateTime.now()))
                    ListTile(
                      leading: Icon(Icons.event_busy),
                      title: Text(context.l10n.cancelEvent),
                      onTap: () => Navigator.pop(context, 'cancelled'),
                    ),
                  if (_event.isDiscoverableAt(DateTime.now()))
                    ListTile(
                      leading: Icon(Icons.people_outline),
                      title: Text(context.l10n.viewParticipants),
                      onTap: () => Navigator.pop(context, 'members'),
                    ),
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(context.l10n.deleteEvent),
                    onTap: () => Navigator.pop(context, 'delete'),
                  ),
                ],
              ),
            ),
          ),
    );
    if (!mounted) return;
    if (action == 'delete') {
      await _delete();
      return;
    }
    if (action == 'members') {
      await _showMembers();
      return;
    }
    if (action == 'edit') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (routeContext) => CreateEventScreen(
                session: widget.session,
                initialEvent: _event,
                onCreated: () => Navigator.pop(routeContext),
              ),
        ),
      );
      if (mounted) await _controller.initialize();
    }
    if (!mounted) return;
    if (['published', 'completed', 'cancelled'].contains(action)) {
      final publishing = action == 'published';
      if (!await _confirm(
            publishing
                ? context.l10n.publishTheEvent
                : action == 'completed'
                ? context.l10n.completeTheEvent
                : context.l10n.cancelTheEvent,
            publishing
                ? context.l10n.theEventWillBecomeVisibleToOtherUsers
                : context.l10n.newParticipantsWillNoLongerBeAbleToJoinThe,
            publishing ? context.l10n.publish : context.l10n.confirm,
          ) ||
          !mounted) {
        return;
      }
      try {
        await _controller.setStatus(action!);
        if (mounted) {
          showSuccessSnackBar(context, context.l10n.eventStatusUpdated);
        }
      } catch (error) {
        if (mounted) {
          showErrorSnackBar(
            context,
            context.localizeMessage(apiErrorMessage(error)),
          );
        }
      }
    }
  }

  Future<void> _showMembers() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (context) => SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .65,
              child: ListenableBuilder(
                listenable: _controller,
                builder:
                    (context, _) => Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.eventParticipants,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 12),
                          Expanded(
                            child:
                                _controller.isLoadingMembers
                                    ? Center(child: CircularProgressIndicator())
                                    : _controller.membersError != null
                                    ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            context
                                                .l10n
                                                .couldNotLoadParticipants,
                                          ),
                                          TextButton(
                                            onPressed: _controller.loadMembers,
                                            child: Text(context.l10n.retry),
                                          ),
                                        ],
                                      ),
                                    )
                                    : _controller.members.isEmpty
                                    ? Center(
                                      child: Text(
                                        context.l10n.noParticipantsYet145,
                                      ),
                                    )
                                    : ListView.builder(
                                      itemCount: _controller.members.length,
                                      itemBuilder: (context, index) {
                                        final member =
                                            _controller.members[index];
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: _Avatar(
                                            name: member.fullName,
                                            url: member.avatarUrl,
                                          ),
                                          title: Text(member.fullName),
                                          subtitle:
                                              member.isOrganizer
                                                  ? Text(context.l10n.organizer)
                                                  : null,
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      final colors = Theme.of(context).colorScheme;
      final phase = _event.phaseAt(DateTime.now());
      final organizer = _event.organizer;
      final organizerName =
          organizer?.fullName ??
          (_controller.isOrganizer
              ? widget.session.currentUser?.fullName
              : null);
      final status = switch (phase) {
        EventPhase.upcoming => context.l10n.comingSoon,
        EventPhase.ongoing => context.l10n.happeningNow,
        EventPhase.today => context.l10n.today,
        EventPhase.cancelled => context.l10n.cancelled,
        EventPhase.completed || EventPhase.ended => context.l10n.completed,
        EventPhase.draft => context.l10n.draft,
      };
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.eventDetails),
          leading: BackButton(
            onPressed: () => Navigator.pop(context, _controller.hasChanges),
          ),
        ),
        bottomNavigationBar: _actionBar(phase),
        body: RefreshIndicator(
          onRefresh: _controller.initialize,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: EventCover(event: _event, height: 210),
              ),
              SizedBox(height: 22),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(
                    label: status,
                    icon:
                        phase == EventPhase.ongoing
                            ? Icons.radio_button_checked
                            : Icons.event_outlined,
                  ),
                  if (_controller.isOrganizer)
                    _Badge(
                      label: context.l10n.youReTheOrganizer,
                      icon: Icons.verified_outlined,
                    )
                  else if (_controller.isJoined)
                    _Badge(
                      label: context.l10n.youReAttending,
                      icon: Icons.check_circle_outline,
                    ),
                ],
              ),
              SizedBox(height: 14),
              Text(
                _event.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                  letterSpacing: -.7,
                ),
              ),
              SizedBox(height: 22),
              if (_controller.detailsError != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: GradientPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.couldNotRefreshTheEventDetails),
                        TextButton(
                          onPressed: _controller.initialize,
                          child: Text(context.l10n.tryAgain),
                        ),
                      ],
                    ),
                  ),
                ),
              GradientPanel(
                child: Column(
                  children: [
                    _Info(
                      icon: Icons.calendar_month_outlined,
                      label: context.l10n.when,
                      title: DateFormat(
                        'dd.MM.yyyy · HH:mm',
                      ).format(_event.startsAt.toLocal()),
                      subtitle:
                          _event.endsAt == null
                              ? context.l10n.noEndTimeSpecified
                              : context.l10n.until(
                                (DateFormat(
                                  'dd.MM · HH:mm',
                                ).format(_event.endsAt!.toLocal())).toString(),
                              ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: colors.outlineVariant),
                    ),
                    _Info(
                      icon: Icons.place_outlined,
                      label: context.l10n.where,
                      title: _event.locationName,
                      subtitle:
                          _event.address?.trim().isNotEmpty == true
                              ? _event.address!
                              : context
                                  .l10n
                                  .theMeetingPointIsMarkedOnTheEventMap,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final text =
                              '${_event.locationName}\n${_event.address ?? ''}\n${_event.latitude}, ${_event.longitude}';
                          await Clipboard.setData(ClipboardData(text: text));
                          if (context.mounted) {
                            showSuccessSnackBar(
                              context,
                              context.l10n.meetingPointCopied,
                            );
                          }
                        },
                        icon: Icon(Icons.copy_outlined, size: 16),
                        label: Text(context.l10n.copyLocation),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              _heading(context.l10n.whoSOrganizing),
              SizedBox(height: 12),
              GradientPanel(
                child: Row(
                  children: [
                    _Avatar(
                      name: organizerName ?? '?',
                      url:
                          organizer?.avatarUrl ??
                          (_controller.isOrganizer
                              ? widget.session.currentUser?.avatarUrl
                              : null),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            organizerName ??
                                context.l10n.organizerNameUnavailable,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            context.l10n.eventOrganizer,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              _heading(context.l10n.aboutTheEvent),
              SizedBox(height: 12),
              SelectableText(
                _event.description,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 26),
              _heading(context.l10n.joiningYou),
              SizedBox(height: 12),
              GradientPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline, color: colors.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            participantLabel(
                              _event.participantCount,
                              locale: context.l10n.localeName,
                            ),
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      _event.maxParticipants == null
                          ? context.l10n.noParticipantLimit
                          : context.l10n.participantLimit167(
                            (_event.maxParticipants).toString(),
                          ),
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    if (_event.maxParticipants != null &&
                        _event.maxParticipants! > 0) ...[
                      SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: (_event.participantCount /
                                  _event.maxParticipants!)
                              .clamp(0, 1),
                          backgroundColor: colors.secondaryContainer,
                        ),
                      ),
                    ],
                    SizedBox(height: 14),
                    if (_event.isDiscoverableAt(DateTime.now()) &&
                        (_controller.isJoined || _controller.isOrganizer)) ...[
                      if (_controller.members.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final member in _controller.members.take(6))
                              Tooltip(
                                message: member.fullName,
                                child: _Avatar(
                                  name: member.fullName,
                                  url: member.avatarUrl,
                                  radius: 18,
                                ),
                              ),
                          ],
                        ),
                      TextButton(
                        onPressed: _showMembers,
                        child: Text(context.l10n.viewParticipants),
                      ),
                    ] else
                      Text(
                        _event.status == 'draft'
                            ? context.l10n.youCanJoinAfterTheEventIsPublished
                            : !_event.isDiscoverableAt(DateTime.now())
                            ? context.l10n.registrationIsClosed
                            : context
                                .l10n
                                .theParticipantListWillBeAvailableAfterYouJoin,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _heading(String text) =>
      Text(text, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700));

  Widget _actionBar(EventPhase phase) {
    final colors = Theme.of(context).colorScheme;
    final controller = _controller;
    final unavailable = !_event.isDiscoverableAt(DateTime.now());
    final full =
        _event.maxParticipants != null &&
        _event.participantCount >= _event.maxParticipants!;
    final loading =
        controller.isLoadingDetails || controller.isLoadingParticipation;
    final failed =
        controller.detailsError != null ||
        controller.participationError != null;
    String label;
    String caption;
    VoidCallback? action;
    if (controller.isBusy || loading) {
      label = context.l10n.pleaseWait;
      caption = context.l10n.refreshingEventDetails;
    } else if (failed) {
      label = context.l10n.tryAgain;
      caption = context.l10n.couldNotCheckEventDetailsAndParticipation;
      action = controller.initialize;
    } else if (controller.isOrganizer) {
      label = context.l10n.manageEvent;
      caption = context.l10n.youReOrganizingThisEvent;
      action = _manage;
    } else if (controller.isJoined) {
      label = unavailable ? context.l10n.youAttended : context.l10n.leaveEvent;
      caption =
          unavailable
              ? context.l10n.thisEventIsNoLongerOpenToJoin
              : context.l10n.youReOnTheParticipantList;
      action = unavailable ? null : _leave;
    } else if (unavailable) {
      label =
          phase == EventPhase.cancelled
              ? context.l10n.eventCancelled
              : phase == EventPhase.draft
              ? context.l10n.thisEventHasnTBeenPublishedYet
              : context.l10n.eventCompleted;
      caption = context.l10n.participationUnavailable;
    } else if (full) {
      label = context.l10n.noPlacesLeft;
      caption = context.l10n.youCanCheckForPlacesLater;
    } else {
      label = context.l10n.joinEvent;
      caption =
          _event.maxParticipants == null
              ? context.l10n.bePartOfAGoodCause
              : context.l10n.placesAvailable(
                (_event.maxParticipants! - _event.participantCount).toString(),
              );
      action = _join;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: .6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                caption,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: Key('event-primary-action'),
                  onPressed: action,
                  icon: Icon(
                    controller.isOrganizer
                        ? Icons.tune
                        : controller.isJoined
                        ? Icons.check_circle_outline
                        : Icons.volunteer_activism_outlined,
                    size: 20,
                  ),
                  label: Text(label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String label, title, subtitle;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colors.onPrimaryContainer, size: 22),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 10,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSecondaryContainer),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onSecondaryContainer,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.url, this.radius = 24});
  final String name;
  final String? url;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final image = url?.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.secondaryContainer,
      foregroundImage:
          image == null || image.isEmpty ? null : NetworkImage(image),
      onForegroundImageError: image == null || image.isEmpty ? null : (_, _) {},
      child: Text(
        name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase(),
        style: TextStyle(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
