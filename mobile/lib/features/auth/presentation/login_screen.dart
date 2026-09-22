import '../../../core/localization/language_selector.dart';
import 'package:joicrememory/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error_message.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/ui/app_snack_bar.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.session});

  final AuthController session;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await widget.session.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LanguageSelector(),
                    Icon(
                      Icons.diversity_3,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'JoicreMemory',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      context.l10n.initiativesEventsAndPeopleNearby,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 32),
                    if (widget.session.errorMessage != null) ...[
                      Text(
                        context.localizeMessage(widget.session.errorMessage!),
                        style: TextStyle(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.session.restorationFailed)
                        TextButton.icon(
                          onPressed:
                              widget.session.isBusy
                                  ? null
                                  : widget.session.initialize,
                          icon: Icon(Icons.refresh),
                          label: Text(context.l10n.retryRestoringYourSession),
                        ),
                      SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: context.l10n.email53,
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return context.l10n.enterAValidEmail;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.password,
                        hintText: context.l10n.enterYourPassword,
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return context.l10n.atLeastCharacters309;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: widget.session.isBusy ? null : _submit,
                      icon: Icon(Icons.login),
                      label: Text(
                        widget.session.isBusy
                            ? context.l10n.pleaseWait310
                            : context.l10n.signIn,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            widget.session.isBusy
                                ? null
                                : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ForgotPasswordScreen(
                                            session: widget.session,
                                          ),
                                    ),
                                  );
                                },
                        child: Text(context.l10n.forgotPassword),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed:
                          widget.session.isBusy
                              ? null
                              : () async {
                                final created = await Navigator.of(
                                  context,
                                ).push<bool>(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => RegisterScreen(
                                          session: widget.session,
                                        ),
                                  ),
                                );

                                if (!context.mounted || created != true) {
                                  return;
                                }

                                showSuccessSnackBar(
                                  context,
                                  context
                                      .l10n
                                      .accountCreatedSignInWithYourEmailAndPassword,
                                );
                              },
                      child: Text(context.l10n.createAccount),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
