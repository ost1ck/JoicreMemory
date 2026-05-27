import 'package:flutter/material.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/session/app_session.dart';
import '../../../core/ui/app_snack_bar.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.session});

  final AppSession session;

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
      showErrorSnackBar(context, apiErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.diversity_3,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 18),
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
                    const SizedBox(height: 8),
                    Text(
                      'Ініціативи, події та люди поруч',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Пошта',
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Введи коректну пошту';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        hintText: 'Введи пароль',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Мінімум 6 символів';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: widget.session.isBusy ? null : _submit,
                      icon: const Icon(Icons.login),
                      label: Text(
                        widget.session.isBusy ? 'Зачекай...' : 'Увійти',
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
                        child: const Text('Забув пароль?'),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                  'Акаунт створено. Тепер увійди зі своєю поштою та паролем.',
                                );
                              },
                      child: const Text('Створити акаунт'),
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
