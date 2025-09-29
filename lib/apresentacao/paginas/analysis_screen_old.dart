import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/tone_dropdown.dart';
import '../widgets/custom_field_modal.dart';

class AnalysisScreen extends StatefulWidget {
  final String imagePath;
  
  const AnalysisScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String selectedTone = AppStrings.flirtTone;
  final TextEditingController _focusController = TextEditingController();
  List<String> suggestions = [
    'Tenho que admitir, você fica muito fofo com esse maiô'
  ];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusController.text = 'Defina seu foco';
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF8E8E),
              Color(0xFFFFE7E7),
              AppColors.backgroundColor,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Tone Selector
              _buildToneSelector(),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Profile Mockup
                        _buildProfileMockup(),
                        
                        const SizedBox(height: 20),
                        
                        // Focus Input
                        _buildFocusInput(),
                        
                        const SizedBox(height: 20),
                        
                        // Success Banner
                        _buildSuccessBanner(),
                        
                        const SizedBox(height: 20),
                        
                        // Suggestion
                        _buildSuggestion(),
                        
                        const SizedBox(height: 20),
                        
                        // Generate More Button
                        _buildGenerateButton(),
                        
                        const SizedBox(height: 10),
                        
                        // Free responses counter
                        _buildFreeResponsesCounter(),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 24,
            ),
          ),
          const Text(
            'FlertAI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {
              // Menu action
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToneSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😘', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          const Text(
            'Flertar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildProfileMockup() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Profile content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile header
                Row(
                  children: [
                    // Profile picture
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Profile info
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔥 morena e louca 🔥',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text('3,657', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 20),
                              Text('631', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 20),
                              Text('4,308', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text('publicações', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              SizedBox(width: 8),
                              Text('seguidores', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              SizedBox(width: 8),
                              Text('seguindo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Seguir',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Mensagem',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_add, size: 16),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bio
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Destaques',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Photo grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Side buttons
          Positioned(
            right: 10,
            top: 120,
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.help_outline, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ajuda',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enviar',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Defina seu foco',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFF8C42)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Text('👑', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Obtenha uma mensagem melhor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text('👑', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildSuggestion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            suggestions.isNotEmpty ? suggestions.first : 'Gerando sugestão...',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.refresh, size: 16, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          // Generate more suggestions
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'Gerar mais',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFreeResponsesCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7E7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '7 respostas grátis restantes',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
    );
  }
              Color(0xFFFF8E8E),
              Color(0xFFFFE7E7),
              AppColors.backgroundColor,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              _buildHeader(context),
              
              // Tone Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ToneDropdown(
                  selectedTone: selectedTone,
                  onToneChanged: (tone) {
                    setState(() {
                      selectedTone = tone;
                    });
                    _generateSuggestions();
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Image Preview
              _buildImagePreview(),
              
              const SizedBox(height: 20),
              
              // Focus Input
              _buildFocusInput(),
              
              const SizedBox(height: 20),
              
              // Quick Suggestion Chips
              _buildQuickSuggestions(),
              
              const SizedBox(height: 20),
              
              // Better Message Banner
              _buildBetterMessageBanner(),
              
              // Suggestions List
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentColor,
                        ),
                      )
                    : SuggestionsList(
                        suggestions: suggestions,
                        onRegenerateMore: _generateMoreSuggestions,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                AppStrings.appName,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Open menu
            },
            icon: const Icon(
              Icons.menu,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: kIsWeb
              ? Image.network(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.cardColor,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                )
              : Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.cardColor,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildFocusInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        controller: _focusController,
        decoration: InputDecoration(
          hintText: AppStrings.defineYourFocus,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.accentColor,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              _showCustomFieldModal(context);
            },
            icon: const Icon(
              Icons.tune,
              color: AppColors.accentColor,
            ),
          ),
        ),
        onSubmitted: (value) {
          _generateSuggestions();
        },
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final quickSuggestions = [
      'Estilo praia',
      'Aventuras',
      'Viagens',
      'Hobbies',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: quickSuggestions.map((suggestion) {
          return GestureDetector(
            onTap: () {
              _focusController.text = suggestion;
              _generateSuggestions();
            },
            child: Chip(
              label: Text(suggestion),
              backgroundColor: AppColors.secondaryColor,
              labelStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBetterMessageBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE7E7), Color(0xFFFFF0F0)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Text('👆', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.getBetterMessage,
              style: const TextStyle(
                color: AppColors.accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const Text('👆', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  void _generateInitialSuggestions() {
    setState(() {
      isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        suggestions = [
          'Tenho que admitir, você fica muito fofo com esse maiô',
          'Essa foto na praia me fez querer planejar umas férias contigo',
          'Você tem um sorriso que ilumina qualquer lugar',
        ];
        isLoading = false;
      });
    });
  }

  void _generateSuggestions() {
    setState(() {
      isLoading = true;
    });

    // Simulate API call with focus and tone
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        suggestions = [
          'Nova sugestão baseada no tom: $selectedTone',
          'Foco: ${_focusController.text.isEmpty ? "Geral" : _focusController.text}',
          'Mensagem personalizada para o contexto',
        ];
        isLoading = false;
      });
    });
  }

  void _generateMoreSuggestions() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        suggestions.addAll([
          'Mais uma sugestão criativa',
          'Outra opção interessante',
        ]);
        isLoading = false;
      });
    });
  }

  void _showCustomFieldModal(BuildContext context) {
    showCustomFieldModal(
      context,
      onFocusSelected: (focus) {
        _focusController.text = focus;
        _generateSuggestions();
      },
    );
  }
}
