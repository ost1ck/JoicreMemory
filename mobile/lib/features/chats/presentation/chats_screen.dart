import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;

import '../../../core/constants/app_config.dart';
import '../../../core/network/api_error_message.dart';
import '../../../core/session/app_session.dart';
import '../../../core/ui/app_snack_bar.dart';
import '../data/event_chat.dart';
import '../data/stream_token_data.dart';
import 'event_chat_room_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({
    super.key,
    required this.session,
    required this.refreshSignal,
  });

  final AppSession session;
  final int refreshSignal;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  StreamTokenData? _tokenData;
  stream.StreamChatClient? _client;
  late Future<List<EventChat>> _chatsFuture;
  bool _isConnecting = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _chatsFuture = Future.value(const []);
    _bootstrap();
  }

  @override
  void didUpdateWidget(covariant ChatsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshSignal != widget.refreshSignal && !_isConnecting) {
      if (_client == null) {
        _bootstrap();
      } else {
        _refresh();
      }
    }
  }

  @override
  void dispose() {
    _client?.disconnectUser();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isConnecting = true;
      _message = null;
    });

    try {
      final tokenData = await widget.session.chatApi.getStreamToken();
      stream.StreamChatClient? client;
      String? message = tokenData.message;

      if (tokenData.token != null && AppConfig.streamApiKey.isEmpty) {
        message =
            'Додай STREAM_API_KEY у mobile/.env і повністю перезапусти Flutter.';
      } else if (tokenData.token != null) {
        client = stream.StreamChatClient(AppConfig.streamApiKey);
        await client.connectUser(
          stream.User(
            id: tokenData.streamUserId,
            name: tokenData.fullName,
            image: tokenData.avatarUrl,
          ),
          tokenData.token!,
        );
      }

      if (!mounted) {
        await client?.disconnectUser();
        return;
      }

      setState(() {
        _tokenData = tokenData;
        _client = client;
        _message = message;
        _chatsFuture = widget.session.chatApi.listChats();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _message = apiErrorMessage(error);
        _chatsFuture = Future.value(const []);
      });
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _chatsFuture = widget.session.chatApi.listChats();
    });
    await _chatsFuture;
  }

  Future<void> _openChat(EventChat chat) async {
    final client = _client;

    if (client == null) {
      showErrorSnackBar(context, 'Stream Chat ще не налаштовано.');
      return;
    }

    try {
      final channel = client.channel('messaging', id: chat.streamChannelId);
      await channel.watch();

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => EventChatRoomScreen(
                session: widget.session,
                client: client,
                channel: channel,
                chat: chat,
                onChanged: _refresh,
              ),
        ),
      );

      if (mounted) {
        _refresh();
      }
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, apiErrorMessage(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenData = _tokenData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чати'),
        actions: [
          IconButton(
            onPressed: _isConnecting ? null : _bootstrap,
            icon: const Icon(Icons.refresh),
            tooltip: 'Оновити',
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isConnecting
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _refresh,
                  child: FutureBuilder<List<EventChat>>(
                    future: _chatsFuture,
                    builder: (context, snapshot) {
                      final chats = snapshot.data ?? [];

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          if (_message != null) ...[
                            _InfoCard(
                              icon: Icons.key_off_outlined,
                              text: _message!,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (tokenData != null && _client != null) ...[
                            _InfoCard(
                              icon: Icons.verified_user_outlined,
                              text:
                                  'Підключено як ${tokenData.fullName}. Тут показані тільки чати твоїх подій.',
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (chats.isEmpty)
                            const _EmptyChats()
                          else
                            ...chats.map(
                              (chat) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _EventChatTile(
                                  chat: chat,
                                  canOpen: _client != null,
                                  onTap: () => _openChat(chat),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

class _EventChatTile extends StatelessWidget {
  const _EventChatTile({
    required this.chat,
    required this.canOpen,
    required this.onTap,
  });

  final EventChat chat;
  final bool canOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM HH:mm');
    final avatarUrl = chat.avatarUrl;
    final initial = chat.eventTitle.characters.first.toUpperCase();

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          foregroundImage:
              avatarUrl == null || avatarUrl.isEmpty
                  ? null
                  : NetworkImage(avatarUrl),
          onForegroundImageError:
              avatarUrl == null || avatarUrl.isEmpty ? null : (_, _) {},
          child: Text(initial),
        ),
        title: Text(
          chat.eventTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${chat.locationName} · ${formatter.format(chat.startsAt.toLocal())} · ${chat.participantCount} учасн.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          !canOpen
              ? Icons.lock_outline
              : chat.isOrganizer
              ? Icons.admin_panel_settings_outlined
              : Icons.chevron_right,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 120),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.forum_outlined, size: 56),
            SizedBox(height: 12),
            Text(
              'Чатів ще немає.\nДолучись до події або створи свою.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
