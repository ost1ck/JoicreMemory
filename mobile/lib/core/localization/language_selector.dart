import 'package:flutter/material.dart';
import '../../app/app_scope.dart';
import '../../l10n/localization.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        context.getInheritedWidgetOfExactType<AppScope>()?.locale;
    if (controller == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: controller,
      builder:
          (context, _) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: Text(context.l10n.language),
            trailing: DropdownButton<String>(
              value: controller.languageCode,
              onChanged: (value) {
                if (value != null) controller.setLanguage(value);
              },
              items: [
                const DropdownMenuItem(value: 'uk', child: Text('Українська')),
                const DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(
                  value: 'system',
                  child: Text(context.l10n.systemLanguage),
                ),
              ],
            ),
          ),
    );
  }
}
