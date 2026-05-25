import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);

    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(langProvider.translate('settings'), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Theme Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dark Mode', style: Theme.of(context).textTheme.bodyMedium),
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (val) {
                  themeProvider.toggleTheme();
                },
                activeColor: const Color(0xFFB9B0A2), // Match premium vibe
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Language Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Language', style: Theme.of(context).textTheme.bodyMedium),
              DropdownButton<String>(
                value: langProvider.currentLanguage,
                dropdownColor: Theme.of(context).cardColor,
                style: Theme.of(context).textTheme.bodyMedium,
                underline: Container(), // Remove underline for cleaner look
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'es', child: Text('Español')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    langProvider.setLanguage(val);
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(langProvider.translate('cancel'), style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
