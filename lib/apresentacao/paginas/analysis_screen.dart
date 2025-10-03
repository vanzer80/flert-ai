import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/tone_dropdown.dart';
import '../paginas/focus_selector_screen.dart';
import '../../servicos/ai_service.dart';
import '../../servicos/feedback_service.dart';

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
  List<String> _allSuggestions = []; // Histórico completo de sugestões
  bool isLoading = false;
  String? _storageImagePath; // caminho no bucket 'images' (ex.: img_123.jpg)
  String? _currentConversationId; // ID da conversa atual
  Map<int, String?> _suggestionFeedbacks = {}; // Armazena feedback por índice
  bool _hasConversation = false; // Indica se há conversa segmentada detectada
  List<Map<String, dynamic>> _conversationSegments = []; // Segmentos da conversa

  @override
  void initState() {
    super.initState();
    // Não definir placeholder aqui - deixar vazio inicialmente
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
                          // Lista de sugestões com feedback ou loading
                          if (isLoading)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Column(
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Gerando sugestões incríveis para você...',
                                      style: TextStyle(fontSize: 16, color: Colors.black87),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Exibir conversa segmentada se detectada
                          if (_hasConversation && _conversationSegments.isNotEmpty)
                            _buildConversationPreview(),
                          if (!isLoading && suggestions.isNotEmpty)
                            _buildSuggestionsList(),
                          if (!isLoading && suggestions.isEmpty)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  'Para gerar mensagens criativas, faça upload de uma imagem e defina seu foco.',
                                  style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.35),
                                  textAlign: TextAlign.center,
                                ),
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
  }

  Future<void> _generateSuggestions() async {
    setState(() { 
      isLoading = true;
      _suggestionFeedbacks.clear(); // Limpar feedbacks anteriores
    });
    try {
      final result = await AIService().analyzeImageAndGenerateSuggestions(
        imagePath: _storageImagePath, // se null, função usa modo texto
        tone: selectedTone,
        focusTags: selectedFocusTags.isEmpty ? null : selectedFocusTags,
      );
      final List<dynamic> list = result['suggestions'] ?? [];
      final conversationId = result['conversation_id'];
      
      // Processar novos campos de conversa segmentada
      final hasConversation = result['has_conversation'] ?? false;
      final List<dynamic> segments = result['conversation_segments'] ?? [];
      
      setState(() {
        suggestions = list.map((e) => e.toString()).toList();
        // Adicionar ao histórico completo
        _allSuggestions.addAll(suggestions);
        if (conversationId != null) {
          _currentConversationId = conversationId.toString();
        }
        
        // Atualizar dados de conversa
        _hasConversation = hasConversation;
        _conversationSegments = segments
            .map((seg) => {
                  'autor': seg['autor']?.toString() ?? 'unknown',
                  'texto': seg['texto']?.toString() ?? '',
                })
            .toList();
        
        isLoading = false;
      });
      
      // Log para debug
      if (_hasConversation && _conversationSegments.isNotEmpty) {
        debugPrint('✅ Conversa detectada: ${_conversationSegments.length} mensagens');
      }
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
        focusTags: selectedFocusTags.isEmpty ? null : selectedFocusTags,
        previousSuggestions: _allSuggestions, // Enviar histórico completo
      );
      setState(() {
        suggestions = list;
        // Adicionar ao histórico completo
        _allSuggestions.addAll(suggestions);
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

  /// Widget para exibir uma sugestão com botões de feedback
  Widget _buildSuggestionCard(String suggestion, int index) {
    final feedbackType = _suggestionFeedbacks[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texto da sugestão
          Text(
            suggestion,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Barra de ações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botões de feedback
              Row(
                children: [
                  // Botão "Gostei"
                  _buildFeedbackButton(
                    icon: Icons.thumb_up,
                    label: 'Gostei',
                    isSelected: feedbackType == 'like',
                    color: Colors.green,
                    onTap: () => _handleFeedback(index, suggestion, 'like'),
                  ),
                  const SizedBox(width: 12),
                  // Botão "Não Gostei"
                  _buildFeedbackButton(
                    icon: Icons.thumb_down,
                    label: 'Não gostei',
                    isSelected: feedbackType == 'dislike',
                    color: Colors.red,
                    onTap: () => _handleFeedback(index, suggestion, 'dislike'),
                  ),
                ],
              ),
              // Botão copiar
              IconButton(
                icon: const Icon(Icons.content_copy, size: 20),
                color: Colors.grey[600],
                onPressed: () => _copyToClipboard(suggestion),
                tooltip: 'Copiar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget para botão de feedback
  Widget _buildFeedbackButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lista todas as sugestões com feedback
  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Cabeçalho
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${suggestions.length} Sugestões Geradas',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lista de sugestões
          ...suggestions.asMap().entries.map((entry) {
            return _buildSuggestionCard(entry.value, entry.key);
          }).toList(),
        ],
      ),
    );
  }

  /// Manipula feedback do usuário
  Future<void> _handleFeedback(
    int index,
    String suggestion,
    String feedbackType,
  ) async {
    // Atualizar estado local imediatamente para feedback visual
    setState(() {
      _suggestionFeedbacks[index] = feedbackType;
    });

    // Salvar feedback no backend (assíncrono, não bloqueia UI)
    if (_currentConversationId != null) {
      try {
        final result = await FeedbackService().saveFeedback(
          conversationId: _currentConversationId!,
          suggestionText: suggestion,
          suggestionIndex: index,
          feedbackType: feedbackType,
        );

        if (result['success'] == true) {
          // Feedback visual sutil
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  feedbackType == 'like'
                      ? '👍 Obrigado pelo feedback positivo!'
                      : '👎 Obrigado! Vamos melhorar.',
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: feedbackType == 'like'
                    ? Colors.green
                    : Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Erro ao salvar feedback: $e');
        // Falha silenciosa - não impacta UX
      }
    }
  }

  /// Widget para exibir preview da conversa segmentada detectada
  Widget _buildConversationPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: AppColors.accentColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Conversa Detectada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_conversationSegments.length} msgs',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // Mensagens (máximo 4 para preview)
          ..._conversationSegments.take(4).map((segment) {
            final isUser = segment['autor'] == 'user';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de autor
                  Container(
                    width: 50,
                    child: Text(
                      isUser ? 'VOCÊ:' : 'MATCH:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isUser ? Colors.blue[700] : Colors.pink[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mensagem
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isUser 
                            ? Colors.blue[50] 
                            : Colors.pink[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUser 
                              ? Colors.blue[200]! 
                              : Colors.pink[200]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        segment['texto'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          // Indicador se há mais mensagens
          if (_conversationSegments.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '+ ${_conversationSegments.length - 4} mensagens...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          // Nota informativa
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'As sugestões abaixo consideram o contexto desta conversa',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[900],
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
