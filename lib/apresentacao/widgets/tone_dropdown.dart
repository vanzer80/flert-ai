import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ToneDropdown extends StatelessWidget {
  final String selectedTone;
  final Function(String) onToneChanged;

  const ToneDropdown({
    super.key,
    required this.selectedTone,
    required this.onToneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showToneSelectionModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedTone,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showToneSelectionModal(BuildContext context) {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ToneSelectionModal(
        selectedTone: selectedTone,
        onToneSelected: (tone) {
          onToneChanged(tone);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class ToneSelectionModal extends StatefulWidget {
  final String selectedTone;
  final Function(String) onToneSelected;

  const ToneSelectionModal({
    super.key,
    required this.selectedTone,
    required this.onToneSelected,
  });

  @override
  State<ToneSelectionModal> createState() => _ToneSelectionModalState();
}

class _ToneSelectionModalState extends State<ToneSelectionModal> {
  late String _selectedTone;

  final List<ToneOption> _toneOptions = [
    ToneOption(
      emoji: '😘',
      name: 'Flertar',
      description: AppStrings.flirtDescription,
      isPremium: false,
      isDefault: true,
    ),
    ToneOption(
      emoji: '😏',
      name: 'Descontraído',
      description: 'Conversa natural e espontânea',
      isPremium: false,
    ),
    ToneOption(
      emoji: '😎',
      name: 'Casual',
      description: 'Conversa natural e espontânea',
      isPremium: true,
    ),
    ToneOption(
      emoji: '💬',
      name: 'Genuíno',
      description: 'Mensagens autênticas e profundas',
      isPremium: true,
    ),
    ToneOption(
      emoji: '😈',
      name: 'Sensual',
      description: 'Mensagens picantes com um toque de sedução',
      isPremium: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTone = widget.selectedTone;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.selectTone,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Tone Options
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _toneOptions.length,
              itemBuilder: (context, index) {
                final option = _toneOptions[index];
                final isSelected = _selectedTone.contains(option.name);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: isSelected 
                        ? Border.all(color: AppColors.accentColor, width: 2)
                        : null,
                  ),
                  child: RadioListTile<String>(
                    value: '${option.emoji} ${option.name}',
                    groupValue: _selectedTone,
                    onChanged: (value) {
                      if (!option.isPremium || _isPremiumUser()) {
                        setState(() {
                          _selectedTone = value!;
                        });
                      } else {
                        _showPremiumDialog(context);
                      }
                    },
                    title: Row(
                      children: [
                        Text(
                          '${option.emoji} ${option.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (option.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              AppStrings.defaultOption,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (option.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.premiumGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.star,
                                  color: AppColors.white,
                                  size: 10,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  AppStrings.premium,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    subtitle: option.description.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              option.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null,
                    activeColor: AppColors.accentColor,
                  ),
                );
              },
            ),
          ),
          
          // Generate Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onToneSelected(_selectedTone);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  AppStrings.generate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isPremiumUser() {
    // TODO: Check if user has premium subscription
    return false;
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recurso Premium'),
        content: const Text(
          'Este tom está disponível apenas para usuários Premium. Atualize sua conta para acessar todos os tons.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium upgrade screen
            },
            child: const Text(AppStrings.upgradeToPro),
          ),
        ],
      ),
    );
  }
}

class ToneOption {
  final String emoji;
  final String name;
  final String description;
  final bool isPremium;
  final bool isDefault;

  ToneOption({
    required this.emoji,
    required this.name,
    required this.description,
    this.isPremium = false,
    this.isDefault = false,
  });
}
