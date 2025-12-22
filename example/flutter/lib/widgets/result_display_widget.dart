import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultDisplayWidget extends StatelessWidget {
  final String title;
  final String content;
  final bool isError;

  const ResultDisplayWidget({
    super.key,
    required this.title,
    required this.content,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isError ? Colors.red.shade50 : Colors.green.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error : Icons.check_circle,
                  color: isError ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.red : Colors.green,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copiado para a área de transferência'),
                      ),
                    );
                  },
                  tooltip: 'Copiar',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
