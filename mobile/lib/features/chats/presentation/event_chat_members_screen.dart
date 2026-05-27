import 'package:flutter/material.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/session/app_session.dart';
import '../../../core/ui/app_snack_bar.dart';
import '../data/chat_member.dart';
import '../data/event_chat.dart';

class EventChatMembersScreen extends StatefulWidget {
  const EventChatMembersScreen({
    super.key,
    required this.session,
    required this.chat,
  });

  final AppSession session;
  final EventChat chat;

  @override
  State<EventChatMembersScreen> createState() => _EventChatMembersScreenState();
}

class _EventChatMembersScreenState extends State<EventChatMembersScreen> {
  late Future<List<ChatMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = widget.session.chatApi.listMembers(widget.chat.eventId);
  }

  Future<void> _refresh() async {
    setState(() {
      _membersFuture = widget.session.chatApi.listMembers(widget.chat.eventId);
    });
    await _membersFuture;
  }

  Future<void> _kick(ChatMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Викинути учасника?'),
            content: Text(
              '${member.fullName} втратить доступ до події та її чату.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Скасувати'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Викинути'),
              ),
            ],
          ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await widget.session.chatApi.kickMember(
        eventId: widget.chat.eventId,
        userId: member.userId,
      );
      await _refresh();

      if (mounted) {
        showSuccessSnackBar(context, 'Учасника видалено з події та чату');
      }
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, apiErrorMessage(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.session.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Учасники чату')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<ChatMember>>(
            future: _membersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final members = snapshot.data ?? [];

              if (members.isEmpty) {
                return ListView(
                  children: [
                    const SizedBox(height: 160),
                    const Center(child: Text('Учасників ще немає')),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemBuilder: (context, index) {
                  final member = members[index];
                  final avatarUrl = member.avatarUrl;
                  final canKick =
                      widget.chat.isOrganizer &&
                      !member.isOrganizer &&
                      member.userId != currentUserId;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        foregroundImage:
                            avatarUrl == null || avatarUrl.isEmpty
                                ? null
                                : NetworkImage(avatarUrl),
                        onForegroundImageError:
                            avatarUrl == null || avatarUrl.isEmpty
                                ? null
                                : (_, _) {},
                        child: Text(member.fullName.characters.first),
                      ),
                      title: Text(member.fullName),
                      subtitle: Text(
                        member.isOrganizer ? 'Організатор' : 'Учасник',
                      ),
                      trailing:
                          canKick
                              ? IconButton(
                                onPressed: () => _kick(member),
                                icon: const Icon(Icons.person_remove_outlined),
                                tooltip: 'Викинути',
                              )
                              : null,
                    ),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemCount: members.length,
              );
            },
          ),
        ),
      ),
    );
  }
}
