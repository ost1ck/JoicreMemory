import 'package:joicrememory/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error_message.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.session});

  final AuthController session;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _avatarController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.session.currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _avatarController = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.session.updateProfile(
        fullName: _fullNameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarUrl: _avatarController.text.trim(),
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
            context.l10n.couldNotUpdateYourProfile(
              (context.localizeMessage(apiErrorMessage(error))).toString(),
            ),
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
      return context.l10n.enterTheFullImageUrl;
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return context.l10n.theUrlMustStartWithHttpsOrHttp;
    }

    final path = uri.path.toLowerCase();
    final looksLikeImage =
        path.contains(RegExp(r'\.(jpg|jpeg|png|webp|gif)\b')) ||
        uri.host == 'i.pravatar.cc' ||
        uri.host == 'picsum.photos';

    if (!looksLikeImage) {
      return context.l10n.useADirectLinkToAnImageFile;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editProfile)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.name,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
                validator:
                    (value) =>
                        value == null || value.trim().length < 2
                            ? context.l10n.atLeastCharacters92
                            : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: context.l10n.bio,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _avatarController,
                decoration: InputDecoration(
                  labelText: context.l10n.avatarUrl,
                  helperText: context.l10n.directUrlHttpsSiteComAvatarPng,
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                keyboardType: TextInputType.url,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
                validator: _validateAvatarUrl,
              ),
              SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: Icon(Icons.save_outlined),
                label: Text(
                  _isSaving ? context.l10n.saving239 : context.l10n.save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
