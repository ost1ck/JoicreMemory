import 'package:joicrememory/l10n/localization.dart';
import '../../../app/app_scope.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error_message.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/ui/app_snack_bar.dart';
import '../domain/entities/chat_member.dart';
import '../domain/entities/event_chat.dart';

class EventChatMembersScreen extends StatefulWidget {
  const EventChatMembersScreen({
    super.key,
    required this.session,
    required this.chat,
  });

  final AuthController session;
  final EventChat chat;

  @override
  State<EventChatMembersScreen> createState() => _EventChatMembersScreenState();
}

class _EventChatMembersScreenState extends State<EventChatMembersScreen> {
  late Future<List<ChatMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = AppScope.read(
      context,
    ).chats.listMembers(widget.chat.eventId);
  }

  Future<void> _refresh() async {
    setState(() {
      _membersFuture = AppScope.read(
        context,
      ).chats.listMembers(widget.chat.eventId);
    });
    await _membersFuture;
  }

  Future<void> _kick(ChatMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.removeParticipant),
            content: Text(
              context.l10n.willLoseAccessToTheEventAndItsChat(
                (member.fullName).toString(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.l10n.remove),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await AppScope.read(
        context,
      ).chats.kickMember(eventId: widget.chat.eventId, userId: member.userId);
      if (!mounted) return;
      await _refresh();

      if (mounted) {
        showSuccessSnackBar(
          context,
          context.l10n.participantRemovedFromTheEventAndChat,
        );
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
    final currentUserId = widget.session.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.chatMembers)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<ChatMember>>(
            future: _membersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final members = snapshot.data ?? [];

              if (members.isEmpty) {
                return ListView(
                  children: [
                    SizedBox(height: 160),
                    Center(child: Text(context.l10n.noParticipantsYet259)),
                  ],
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                        member.isOrganizer
                            ? context.l10n.organizer
                            : context.l10n.participant,
                      ),
                      trailing:
                          canKick
                              ? IconButton(
                                onPressed: () => _kick(member),
                                icon: Icon(Icons.person_remove_outlined),
                                tooltip: context.l10n.remove,
                              )
                              : null,
                    ),
                  );
                },
                separatorBuilder: (_, _) => SizedBox(height: 8),
                itemCount: members.length,
              );
            },
          ),
        ),
      ),
    );
  }
}
