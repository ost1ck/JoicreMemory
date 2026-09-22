import 'package:joicrememory/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error_message.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/ui/app_snack_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.session});

  final AuthController session;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await widget.session.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(
        context,
        context.localizeMessage(apiErrorMessage(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.registration)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.person_add_alt_1,
                            size: 58,
                            color: colorScheme.primary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            context.l10n.createAccount,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            context
                                .l10n
                                .signUpToCreateInitiativesAndJoinNearbyEvents,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          SizedBox(height: 28),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: context.l10n.name,
                              hintText: context.l10n.forExampleAnnaPetrenko,
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.trim().length < 2
                                        ? context.l10n.enterYourName
                                        : null,
                          ),
                          SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: context.l10n.email53,
                              hintText: 'name@example.com',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            validator:
                                (value) =>
                                    value == null || !value.contains('@')
                                        ? context.l10n.enterYourEmail
                                        : null,
                          ),
                          SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: context.l10n.password,
                              hintText: context.l10n.atLeastCharacters309,
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.length < 6
                                        ? context.l10n.atLeastCharacters309
                                        : null,
                          ),
                          SizedBox(height: 22),
                          ElevatedButton.icon(
                            onPressed: widget.session.isBusy ? null : _submit,
                            icon: Icon(Icons.person_add_alt),
                            label: Text(
                              widget.session.isBusy
                                  ? context.l10n.pleaseWait310
                                  : context.l10n.signUp,
                            ),
                          ),
                        ],
                      ),
                    ),
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
