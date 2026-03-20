import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const ApiKeyDialog(),
    );
  }
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    final existing = box.get(AppConstants.geminiApiKeySettingKey);
    if (existing != null) {
      _controller.text = existing;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gemini API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your Google Gemini API key to enable AI-powered recipe extraction from TikTok videos.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get a free API key at aistudio.google.com',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'API Key',
              prefixIcon: const Icon(Icons.key),
              errorText: _error,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final key = _controller.text.trim();
            if (key.isEmpty) {
              setState(() => _error = 'Please enter an API key');
              return;
            }
            final box = Hive.box<String>(AppConstants.settingsBoxName);
            box.put(AppConstants.geminiApiKeySettingKey, key);
            Navigator.pop(context, key);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
