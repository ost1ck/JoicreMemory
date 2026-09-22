import 'package:joicrememory/l10n/localization.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_error_message.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/ui/app_snack_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.session});

  final AuthController session;

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
        context.l10n.passwordResetEmailSentCheckYourInboxAndSpamFolder,
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

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
      appBar: AppBar(title: Text(context.l10n.resetPassword)),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 58,
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: 18),
                    Text(
                      context.l10n.forgotPassword,
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
                          .enterYourAccountEmailToReceiveAPasswordResetLink,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_emailSent) ...[
                      SizedBox(height: 18),
                      Container(
                        padding: EdgeInsets.all(14),
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
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context
                                    .l10n
                                    .emailSentCheckYourSpamFolderOrResendWhenThe,
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
                    SizedBox(height: 24),
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
                    SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed:
                          widget.session.isBusy || _secondsToResend > 0
                              ? null
                              : _submit,
                      icon: Icon(Icons.send_outlined),
                      label: Text(
                        widget.session.isBusy
                            ? context.l10n.sending
                            : _secondsToResend > 0
                            ? context.l10n.resendInS(
                              (_secondsToResend).toString(),
                            )
                            : _emailSent
                            ? context.l10n.resendEmail
                            : context.l10n.sendEmail,
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
