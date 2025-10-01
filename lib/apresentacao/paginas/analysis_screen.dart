import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/tone_dropdown.dart';
import '../paginas/focus_selector_screen.dart';
import '../../servicos/ai_service.dart';

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
  List<String> selectedFocusTags = [];
  final TextEditingController _focusController = TextEditingController();
  List<String> suggestions = [
    'Tenho que admitir, você fica muito fofo com esse maiô'
  ];
  bool isLoading = false;
  String? _storageImagePath; // caminho no bucket 'images' (ex.: img_123.jpg)

  @override
  void initState() {
    super.initState();
    _focusController.text = 'Defina seu foco';
    _initUploadAndGenerate();
  }

  Future<void> _initUploadAndGenerate() async {
    setState(() { isLoading = true; });
    try {
      final uploadedPath = await AIService().uploadImageToStorage(imagePath: widget.imagePath);
      if (uploadedPath != null) {
        _storageImagePath = uploadedPath; // ex.: img_... .jpg
      }
      await _generateSuggestions();
    } catch (_) {
      await _generateSuggestions();
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFF8E8E),
              AppColors.backgroundColor,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tone Selector (centralizado)
                  _buildToneSelector(),
                  
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileMockup(),
                          const SizedBox(height: 20),
                          _buildFocusInput(),
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    isLoading 
                                        ? 'Gerando sugestões incríveis para você...' 
                                        : (suggestions.isNotEmpty ? suggestions.first : 'Para gerar mensagens criativas e envolventes, preciso de informações sobre a imagem de perfil, conversa ou bio da pessoa em questão'),
                                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.35),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => _copyToClipboard(suggestions.isNotEmpty ? suggestions.first : ''),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.content_copy, size: 16, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildGenerateButton(),
                          const SizedBox(height: 10),
                          _buildFreeResponsesCounter(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToneSelector() {
    return Center(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ToneDropdown(
          selectedTone: selectedTone,
          onToneChanged: (tone) {
            if (tone != selectedTone) {
              setState(() { selectedTone = tone; });
              _generateSuggestions();
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileMockup() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mockup do telefone
          Container(
            width: 270,
            height: 500,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Notch
                Positioned(
                  top: 0,
                  left: 85,
                  right: 85,
                  child: Container(
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                  ),
                ),
                // Tela interna com a imagem selecionada
                Positioned.fill(
                  top: 10,
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: kIsWeb
                        ? Image.network(
                            widget.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              color: Colors.white,
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                              ),
                            ),
                          )
                        : Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              color: Colors.white,
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Botões laterais
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sideCircle(icon: Icons.help_outline, label: 'Ajuda', onTap: () {}),
              const SizedBox(height: 18),
              _sideCircle(icon: Icons.send, label: 'Enviar', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sideCircle({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.grey[700]),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFocusInput() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: InkWell(
          onTap: () => _showFocusSelector(),
          borderRadius: BorderRadius.circular(25),
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, color: AppColors.accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _focusController.text.isEmpty ? 'Defina seu foco' : _focusController.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: 200,
      child: ElevatedButton(
        onPressed: _generateMoreSuggestions,
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
  Future<void> _generateSuggestions() async {
    setState(() { isLoading = true; });
    try {
      final result = await AIService().analyzeImageAndGenerateSuggestions(
        imagePath: _storageImagePath, // se null, função usa modo texto
        tone: selectedTone,
        focusTags: selectedFocusTags.isEmpty ? null : selectedFocusTags,
      );
      final List<dynamic> list = result['suggestions'] ?? [];
      setState(() {
        suggestions = list.map((e) => e.toString()).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao gerar sugestões: $e')),
      );
    }
  }

  Future<void> _generateMoreSuggestions() async {
    if (suggestions.isEmpty) return _generateSuggestions();
    setState(() { isLoading = true; });
    try {
      final list = await AIService().generateMoreSuggestions(
        originalText: _storageImagePath ?? '', // se vazio, função cai para modo texto
        tone: selectedTone,
        focus: _focusController.text.isEmpty ? null : _focusController.text,
        previousSuggestions: suggestions,
      );
      setState(() {
        suggestions = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao gerar mais: $e')),
      );
    }
  }

  void _copyToClipboard(String text) async {
    if (text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensagem copiada para a área de transferência!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFocusSelector() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FocusSelectorScreen(
          initialSelectedTags: selectedFocusTags,
          onTagsSelected: (tags) {
            setState(() {
              selectedFocusTags = tags;
              _focusController.text = tags.join(', ');
            });
            _generateSuggestions();
          },
        ),
      ),
    );
  }
}
