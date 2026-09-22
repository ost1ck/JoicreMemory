import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String message) {
  _showAppSnackBar(
    context,
    message: message,
    icon: Icons.info_outline,
    backgroundColor: Theme.of(context).colorScheme.errorContainer,
    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  _showAppSnackBar(
    context,
    message: message,
    icon: Icons.check_circle_outline,
    backgroundColor:
        Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF243C2A)
            : const Color(0xFFE3EEDF),
    foregroundColor:
        Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFB7DDB1)
            : const Color(0xFF2F5634),
  );
}

void _showAppSnackBar(
  BuildContext context, {
  required String message,
  required IconData icon,
  required Color backgroundColor,
  required Color foregroundColor,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      elevation: 0,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Row(
        children: [
          Icon(icon, color: foregroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
