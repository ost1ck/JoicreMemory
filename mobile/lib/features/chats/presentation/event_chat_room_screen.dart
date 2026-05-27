import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;

import '../../../core/session/app_session.dart';
import '../../../core/ui/app_snack_bar.dart';
import '../data/event_chat.dart';
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

  final AppSession session;
  final stream.StreamChatClient client;
  final stream.Channel channel;
  final EventChat chat;
  final Future<void> Function() onChanged;

  @override
  State<EventChatRoomScreen> createState() => _EventChatRoomScreenState();
}

class _EventChatRoomScreenState extends State<EventChatRoomScreen> {
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
      showSuccessSnackBar(context, 'Аватар чату оновлено');
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
                  (context) => const [
                    PopupMenuItem(
                      value: _ChatAction.members,
                      child: ListTile(
                        leading: Icon(Icons.group_outlined),
                        title: Text('Учасники'),
                      ),
                    ),
                    PopupMenuItem(
                      value: _ChatAction.avatar,
                      child: ListTile(
                        leading: Icon(Icons.image_outlined),
                        title: Text('Аватар чату'),
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: stream.StreamChat(
        client: widget.client,
        child: stream.StreamChannel(
          channel: widget.channel,
          child: const SafeArea(
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
}

enum _ChatAction { members, avatar }
