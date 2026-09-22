import 'package:joicrememory/l10n/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/ui/app_snack_bar.dart';
import '../domain/entities/event_chat.dart';
import 'edit_event_chat_avatar_screen.dart';
import 'event_chat_members_screen.dart';

class EventChatRoomScreen extends StatefulWidget {
  const EventChatRoomScreen({
    super.key,
    required this.session,
    required this.client,
    required this.channel,
    required this.chat,
    required this.onChanged,
  });

  final AuthController session;
  final stream.StreamChatClient client;
  final stream.Channel channel;
  final EventChat chat;
  final Future<void> Function() onChanged;

  @override
  State<EventChatRoomScreen> createState() => _EventChatRoomScreenState();
}

class _EventChatRoomScreenState extends State<EventChatRoomScreen> {
  Timer? _expiryTimer;
  StreamSubscription<stream.Event>? _deletedSubscription;
  bool _deleted = false;
  @override
  void initState() {
    super.initState();
    _deletedSubscription = widget.channel
        .on()
        .where(
          (event) =>
              event.type == 'channel.deleted' ||
              event.type == 'notification.channel_deleted',
        )
        .listen((_) {
          if (mounted) setState(() => _deleted = true);
        });
    final end = widget.chat.endsAt;
    if (end != null) {
      final remaining = end.difference(DateTime.now());
      _expiryTimer = Timer(
        remaining.isNegative ? Duration.zero : remaining,
        () {
          if (mounted) setState(() {});
        },
      );
    }
  }

  @override
  void dispose() {
    _deletedSubscription?.cancel();
    _expiryTimer?.cancel();
    super.dispose();
  }

  Future<void> _changeAvatar() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => EditEventChatAvatarScreen(
              session: widget.session,
              chat: widget.chat,
            ),
      ),
    );

    if (!mounted || updated != true) {
      return;
    }

    await widget.onChanged();

    if (mounted) {
      showSuccessSnackBar(context, context.l10n.chatAvatarUpdated);
    }
  }

  Future<void> _openMembers() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => EventChatMembersScreen(
              session: widget.session,
              chat: widget.chat,
            ),
      ),
    );
    await widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted || !widget.chat.isActiveAt(DateTime.now())) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.eventCompleted)),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              context.l10n.thisEventSChatIsNoLongerAvailable,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chat.eventTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (widget.chat.isOrganizer)
            PopupMenuButton<_ChatAction>(
              onSelected: (action) {
                switch (action) {
                  case _ChatAction.avatar:
                    _changeAvatar();
                  case _ChatAction.members:
                    _openMembers();
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: _ChatAction.members,
                      child: ListTile(
                        leading: Icon(Icons.group_outlined),
                        title: Text(context.l10n.participants45),
                      ),
                    ),
                    PopupMenuItem(
                      value: _ChatAction.avatar,
                      child: ListTile(
                        leading: Icon(Icons.image_outlined),
                        title: Text(context.l10n.chatAvatar),
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: stream.StreamChat(
        client: widget.client,
        streamChatThemeData: _chatTheme(context),
        child: stream.StreamChannel(
          channel: widget.channel,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: stream.StreamMessageListView(
                    showConnectionStateTile: true,
                  ),
                ),
                stream.StreamMessageInput(
                  disableAttachments: true,
                  showCommandsButton: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  stream.StreamChatThemeData _chatTheme(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final base = stream.StreamChatThemeData(brightness: theme.brightness);
    return stream.StreamChatThemeData.fromColorAndTextTheme(
      base.colorTheme.copyWith(
        brightness: theme.brightness,
        accentPrimary: scheme.primary,
        accentError: scheme.error,
        textHighEmphasis: scheme.onSurface,
        textLowEmphasis: scheme.onSurfaceVariant,
        appBg: theme.scaffoldBackgroundColor,
        barsBg: scheme.surface,
        inputBg: scheme.surface,
        borders: scheme.outlineVariant,
        linkBg: scheme.primaryContainer,
      ),
      base.textTheme,
    );
  }
}

enum _ChatAction { members, avatar }
