import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'custom_card.dart';

class SuggestionsList extends StatelessWidget {
  final List<String> suggestions;
  final VoidCallback onRegenerateMore;

  const SuggestionsList({
    super.key,
    required this.suggestions,
    required this.onRegenerateMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Suggestions
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOutBack,
                child: SuggestionCard(
                  suggestion: suggestions[index],
                  onCopy: () => _copySuggestion(context, suggestions[index]),
                  onEdit: () => _editSuggestion(context, suggestions[index]),
                ),
              );
            },
          ),
        ),
        
        // Generate More Button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRegenerateMore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                AppStrings.generateMore,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        
        // Free responses counter
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '2 respostas grátis restantes',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _copySuggestion(BuildContext context, String suggestion) {
    Clipboard.setData(ClipboardData(text: suggestion));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mensagem copiada!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editSuggestion(BuildContext context, String suggestion) {
    showDialog(
      context: context,
      builder: (context) => EditSuggestionDialog(
        initialText: suggestion,
        onSave: (editedText) {
          // TODO: Implement save edited suggestion
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mensagem editada!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }
}

class EditSuggestionDialog extends StatefulWidget {
  final String initialText;
  final Function(String) onSave;

  const EditSuggestionDialog({
    super.key,
    required this.initialText,
    required this.onSave,
  });

  @override
  State<EditSuggestionDialog> createState() => _EditSuggestionDialogState();
}

class _EditSuggestionDialogState extends State<EditSuggestionDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Mensagem'),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Digite sua mensagem...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSave(_controller.text.trim());
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
