import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

void showErrorSnackBar(BuildContext context, String message) {
  _showAppSnackBar(
    context,
    message: message,
    icon: Icons.info_outline,
    backgroundColor: const Color(0xFFF8E7E4),
    foregroundColor: const Color(0xFF7D2E2A),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  _showAppSnackBar(
    context,
    message: message,
    icon: Icons.check_circle_outline,
    backgroundColor: const Color(0xFFE3F2E7),
    foregroundColor: AppColors.leaf,
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

