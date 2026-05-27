import 'package:flutter/material.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/session/app_session.dart';
import '../data/event_chat.dart';

class EditEventChatAvatarScreen extends StatefulWidget {
  const EditEventChatAvatarScreen({
    super.key,
    required this.session,
    required this.chat,
  });

  final AppSession session;
  final EventChat chat;

  @override
  State<EditEventChatAvatarScreen> createState() =>
      _EditEventChatAvatarScreenState();
}

class _EditEventChatAvatarScreenState extends State<EditEventChatAvatarScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _avatarController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _avatarController = TextEditingController(
      text: widget.chat.avatarUrl ?? '',
    );
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _save({bool clear = false}) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!clear && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final avatarUrl = _avatarController.text.trim();

      await widget.session.chatApi.updateChatAvatar(
        eventId: widget.chat.eventId,
        avatarUrl: clear || avatarUrl.isEmpty ? null : avatarUrl,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Не вдалося оновити аватар чату: ${apiErrorMessage(error)}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateAvatarUrl(String? value) {
    final avatarUrl = value?.trim() ?? '';

    if (avatarUrl.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(avatarUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'Встав повне посилання на зображення';
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return 'Посилання має починатися з https:// або http://';
    }

    final path = uri.path.toLowerCase();
    final looksLikeImage =
        path.contains(RegExp(r'\.(jpg|jpeg|png|webp|gif)\b')) ||
        uri.host == 'i.pravatar.cc' ||
        uri.host == 'picsum.photos' ||
        uri.host == 'static.wikia.nocookie.net';

    if (!looksLikeImage) {
      return 'Це має бути пряме посилання на файл картинки';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.chat.avatarUrl;
    final hasAvatarUrl = avatarUrl != null && avatarUrl.isNotEmpty;
    final title = widget.chat.eventTitle.trim();
    final initial = title.isEmpty ? '?' : title.characters.first.toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Аватар чату')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 42,
                  foregroundImage:
                      hasAvatarUrl ? NetworkImage(avatarUrl) : null,
                  onForegroundImageError: hasAvatarUrl ? (_, _) {} : null,
                  child: Text(initial, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _avatarController,
                decoration: const InputDecoration(
                  labelText: 'Посилання на аватарку',
                  helperText: 'Прямий URL: https://site.com/avatar.png',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                keyboardType: TextInputType.url,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
                validator: _validateAvatarUrl,
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Збереження...' : 'Зберегти'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : () => _save(clear: true),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Очистити аватар'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
