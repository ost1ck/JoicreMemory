import 'package:joicrememory/l10n/localization.dart';
import '../domain/usecases/load_active_chats.dart';
import 'dart:async';
import '../../../core/ui/loading_skeleton.dart';
import '../../../core/ui/empty_state.dart';
import '../../events/presentation/event_list_screen.dart';
import '../../../app/app_scope.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;

import '../../../core/constants/app_config.dart';
import '../../../core/network/api_error_message.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/ui/app_snack_bar.dart';
import '../domain/entities/event_chat.dart';
import '../domain/entities/stream_token_data.dart';
import 'event_chat_room_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({
    super.key,
    required this.session,
    required this.refreshSignal,
  });

  final AuthController session;
  final int refreshSignal;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with WidgetsBindingObserver {
  StreamTokenData? _tokenData;
  stream.StreamChatClient? _client;
  late Future<List<EventChat>> _chatsFuture;
  bool _isConnecting = true;
  String? _message;
  Timer? _expiryTimer;
  StreamSubscription<stream.Event>? _deletedSubscription;
  final Set<String> _deletedChannels = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatsFuture = Future.value([]);
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
    WidgetsBinding.instance.removeObserver(this);
    _deletedSubscription?.cancel();
    _expiryTimer?.cancel();
    _client?.disconnectUser();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isConnecting) {
      _refresh().catchError((Object _) {});
    }
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isConnecting = true;
      _message = null;
    });

    try {
      final tokenData = await AppScope.read(context).chats.getStreamToken();
      if (!mounted) return;
      stream.StreamChatClient? client;
      String? message = tokenData.message;

      if (tokenData.token != null && AppConfig.streamApiKey.isEmpty) {
        message = context.l10n.addStreamApiKeyToMobileEnvAndFullyRestart;
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

      await _deletedSubscription?.cancel();
      if (!mounted) {
        await client?.disconnectUser();
        return;
      }
      _deletedSubscription = client
          ?.on()
          .where(
            (event) =>
                event.type == 'channel.deleted' ||
                event.type == 'notification.channel_deleted',
          )
          .listen((event) {
            if (!mounted) return;
            if (event.cid != null) {
              setState(() => _deletedChannels.add(event.cid!));
            }
          });
      setState(() {
        _tokenData = tokenData;
        _client = client;
        _message = message;
        _chatsFuture = _loadChats();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _message = context.localizeMessage(apiErrorMessage(error));
        _chatsFuture = Future.value([]);
      });
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<List<EventChat>> _loadChats() async {
    final scope = AppScope.read(context);
    final chats = await LoadActiveChats(scope.chats, scope.events)();
    if (mounted) _scheduleExpiry(chats);
    return chats;
  }

  void _scheduleExpiry(List<EventChat> chats) {
    _expiryTimer?.cancel();
    final now = DateTime.now();
    final ends =
        chats
            .where((c) => c.isActiveAt(now) && c.endsAt != null)
            .map((c) => c.endsAt!)
            .toList()
          ..sort();
    if (ends.isEmpty) return;
    _expiryTimer = Timer(ends.first.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleExpiry(chats);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _chatsFuture = _loadChats();
    });
    await _chatsFuture;
  }

  Future<void> _openChat(EventChat chat) async {
    if (!chat.isActiveAt(DateTime.now())) {
      showErrorSnackBar(
        context,
        context.l10n.theEventHasEndedItsChatIsNoLongerAvailable,
      );
      return;
    }
    final client = _client;

    if (client == null) {
      showErrorSnackBar(context, context.l10n.streamChatIsNotConfiguredYet);
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
        showErrorSnackBar(
          context,
          context.localizeMessage(apiErrorMessage(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenData = _tokenData;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.chats),
        actions: [
          IconButton(
            onPressed: _isConnecting ? null : _bootstrap,
            icon: Icon(Icons.refresh),
            tooltip: context.l10n.refresh,
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isConnecting
                ? ListView(
                  padding: EdgeInsets.all(24),
                  children: [LoadingSkeleton(cards: false, count: 5)],
                )
                : RefreshIndicator(
                  onRefresh: _refresh,
                  child: FutureBuilder<List<EventChat>>(
                    future: _chatsFuture,
                    builder: (context, snapshot) {
                      final chats =
                          (snapshot.data ?? <EventChat>[])
                              .where(
                                (chat) =>
                                    chat.isActiveAt(DateTime.now()) &&
                                    !_deletedChannels.contains(
                                      'messaging:${chat.streamChannelId}',
                                    ),
                              )
                              .toList();

                      return ListView(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          if (_message != null) ...[
                            _InfoCard(
                              icon: Icons.key_off_outlined,
                              text: context.localizeMessage(_message!),
                            ),
                            SizedBox(height: 12),
                          ],
                          if (tokenData != null && _client != null) ...[
                            _InfoCard(
                              icon: Icons.verified_user_outlined,
                              text: context.l10n
                                  .connectedAsOnlyChatsForYourEventsAppearHere(
                                    (tokenData.fullName).toString(),
                                  ),
                            ),
                            SizedBox(height: 12),
                          ],
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            LoadingSkeleton(cards: false, count: 4)
                          else if (snapshot.hasError)
                            EmptyState(
                              title: context.l10n.couldNotLoadChats,
                              message: context.localizeMessage(
                                apiErrorMessage(snapshot.error!),
                              ),
                              actionLabel: context.l10n.tryAgain,
                              onAction: _refresh,
                            )
                          else if (chats.isEmpty)
                            EmptyState(
                              title: context.l10n.yourConversationsStartHere,
                              message:
                                  context
                                      .l10n
                                      .joinAnEventToChatWithItsParticipants,
                              actionLabel: context.l10n.findEvents,
                              onAction: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => EventListScreen(
                                          session: widget.session,
                                        ),
                                  ),
                                );
                                if (mounted) _refresh();
                              },
                              icon: Icons.chat_bubble_outline,
                            )
                          else
                            ...chats.map(
                              (chat) => Padding(
                                padding: EdgeInsets.only(bottom: 12),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          context.l10n.participants251(
            (chat.locationName).toString(),
            (formatter.format(chat.startsAt.toLocal())).toString(),
            (chat.participantCount).toString(),
          ),
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
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
