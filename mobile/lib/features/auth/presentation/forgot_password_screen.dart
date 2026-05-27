import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/session/app_session.dart';
import '../../../core/ui/app_snack_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  Timer? _timer;
  int _secondsToResend = 0;
  bool _emailSent = false;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_secondsToResend > 0) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await widget.session.sendPasswordResetEmail(_emailController.text.trim());

      if (!mounted) {
        return;
      }

      setState(() {
        _emailSent = true;
        _secondsToResend = 60;
      });
      _startResendTimer();

      showSuccessSnackBar(
        context,
        'Лист для зміни пароля надіслано. Перевір пошту та папку Спам.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showErrorSnackBar(context, apiErrorMessage(error));
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsToResend <= 1) {
        setState(() => _secondsToResend = 0);
        timer.cancel();
        return;
      }

      setState(() => _secondsToResend -= 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Відновлення пароля')),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 58,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Забув пароль?',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Введи пошту акаунта, і Firebase надішле лист для зміни пароля.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_emailSent) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.mark_email_read_outlined,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Лист надіслано. Якщо його немає, перевір папку Спам або надішли повторно після таймера.',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed:
                          widget.session.isBusy || _secondsToResend > 0
                              ? null
                              : _submit,
                      icon: const Icon(Icons.send_outlined),
                      label: Text(
                        widget.session.isBusy
                            ? 'Надсилання...'
                            : _secondsToResend > 0
                            ? 'Повторно через $_secondsToResend с'
                            : _emailSent
                            ? 'Надіслати повторно'
                            : 'Надіслати лист',
                      ),
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
