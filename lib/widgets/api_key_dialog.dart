import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiKeyDialog extends StatefulWidget {
  final Function(String) onApiKeySet;
  final String? currentApiKey;

  const ApiKeyDialog({
    Key? key,
    required this.onApiKeySet,
    this.currentApiKey,
  }) : super(key: key);

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    if (widget.currentApiKey != null) {
      _controller.text = widget.currentApiKey!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onApiKeySet(_controller.text.trim());
      Navigator.of(context).pop();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Gemini API Key'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Gemini API key to start chatting. Your key will be stored locally on your device.',
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              obscureText: _isObscured,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter your Gemini API key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              maxLines: 1,
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: () => _launchUrl('https://makersuite.google.com/app/apikey'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Get your free API key',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Tap to visit Google AI Studio',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.launch,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _controller.text.trim().isNotEmpty ? _handleSave : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}