import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class CustomFieldModal extends StatefulWidget {
  final Function(String) onFocusSelected;

  const CustomFieldModal({
    super.key,
    required this.onFocusSelected,
  });

  @override
  State<CustomFieldModal> createState() => _CustomFieldModalState();
}

class _CustomFieldModalState extends State<CustomFieldModal> {
  final TextEditingController _controller = TextEditingController();
  
  late final List<String> _quickSuggestions = {
    AppStrings.swimsuitStyle,
    AppStrings.beachVibes,
    AppStrings.outdoorAdventures,
    AppStrings.favoriteTravelSpots,
    ...AppStrings.focusQuickChips,
  }.toList();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            AppStrings.customFieldTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.accentColor, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: AppStrings.defineYourFocus,
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                              ),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                              maxLines: 1,
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) _handleGenerate();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickSuggestions.map((suggestion) {
                        return GestureDetector(
                          onTap: () => _controller.text = suggestion,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.accentColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search, color: AppColors.textSecondary, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  suggestion,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleGenerate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          AppStrings.generate,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
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

  void _handleGenerate() {
    final focus = _controller.text.trim();
    if (focus.isNotEmpty) {
      widget.onFocusSelected(focus);
      Navigator.of(context).pop();
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite algo para conversar'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// Helper function to show the modal
void showCustomFieldModal(
  BuildContext context, {
  required Function(String) onFocusSelected,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => CustomFieldModal(
      onFocusSelected: onFocusSelected,
    ),
  );
}
