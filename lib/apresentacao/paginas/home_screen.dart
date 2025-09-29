import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';

enum AvatarPosition { left, right }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF8B8B),
              Color(0xFFFF9999),
              Color(0xFFFFB3B3),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Formas onduladas abstratas no background
            _buildWavyBackground(),
            
            SafeArea(
              child: Column(
                children: [
                  // Header com logo
                  _buildHeader(context),
                  
                  // Conteúdo principal
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Mockup do celular iPhone
                            _buildModernIPhoneMockup(),
                            
                            const SizedBox(height: 40),
                            
                            // Título
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'Envie um chat ou a bio do seu match',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.3,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Botão principal
                            _buildMainButton(context),
                            
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Navegação inferior
                  _buildBottomNavigation(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWavyBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: Color(0xFFFF7777).withOpacity(0.3),
              borderRadius: BorderRadius.circular(200),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              color: Color(0xFFFF6666).withOpacity(0.25),
              borderRadius: BorderRadius.circular(175),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Color(0xFFFF9999).withOpacity(0.2),
              borderRadius: BorderRadius.circular(125),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo WingAI
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'FlertAI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          // Menu hamburger
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernIPhoneMockup() {
    return Container(
      width: 280,
      height: 550,
      child: ClipRect(
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Frame do iPhone com notch moderno
            Container(
              width: 280,
              height: 550,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Notch/Dynamic Island
                  Positioned(
                    top: 0,
                    left: 90,
                    right: 90,
                    child: Container(
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  
                  // Tela interna do iPhone
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34),
                        child: Column(
                          children: [
                            // Header da conversa
                            Container(
                              padding: const EdgeInsets.only(top: 45, left: 16, right: 16, bottom: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F8F8),
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(19),
                                      color: Color(0xFFFF7B7B),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Nome e status
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Karinny',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Digitando...',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Ícones
                                  const Icon(Icons.videocam_rounded, color: Color(0xFF007AFF), size: 26),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.call, color: Color(0xFF007AFF), size: 24),
                                ],
                              ),
                            ),
                            
                            // Área de mensagens COM overflow permitido
                            Expanded(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Mensagem 1: Coral, saindo pela ESQUERDA
                                  Positioned(
                                    top: 20,
                                    left: -100,
                                    child: _buildOverflowMessage(
                                      'Você fica muito fofo com\nesse maiô',
                                      color: Color(0xFFFF7B7B),
                                      isMe: true,
                                      avatarPosition: AvatarPosition.right,
                                    ),
                                  ),
                                  
                                  // Mensagem 2: Cinza, dentro, esquerda
                                  Positioned(
                                    top: 95,
                                    left: 12,
                                    child: _buildOverflowMessage(
                                      'Problemas? Eu? Nunca😇',
                                      color: Color(0xFFE5E5EA),
                                      isMe: false,
                                      textColor: Colors.black,
                                      avatarPosition: AvatarPosition.left,
                                    ),
                                  ),
                                  
                                  // Mensagem 3: Azul, saindo pela DIREITA
                                  Positioned(
                                    top: 160,
                                    right: -100,
                                    child: _buildOverflowMessage(
                                      'Que tal uma taça de vinho?',
                                      color: Color(0xFF007AFF),
                                      isMe: true,
                                      avatarPosition: AvatarPosition.right,
                                      avatarColor: Color(0xFF007AFF),
                                    ),
                                  ),
                                  
                                  // Mensagem 4: Cinza, dentro, esquerda
                                  Positioned(
                                    top: 225,
                                    left: 12,
                                    child: _buildOverflowMessage(
                                      'Estou dentro😁',
                                      color: Color(0xFFE5E5EA),
                                      isMe: false,
                                      textColor: Colors.black,
                                      avatarPosition: AvatarPosition.left,
                                    ),
                                  ),
                                  
                                  // Mensagem 5: Coral, saindo pela DIREITA (inferior)
                                  Positioned(
                                    top: 290,
                                    right: -80,
                                    child: _buildOverflowMessage(
                                      'Sei onde te levar no\nprimeiro encontro!😊',
                                      color: Color(0xFFFF7B7B),
                                      isMe: true,
                                      avatarPosition: AvatarPosition.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Campo de input inferior
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(color: Colors.grey[200]!, width: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.grey[600], size: 26),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF0F0F0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'iMessage',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(Icons.mic, color: Colors.grey[600], size: 26),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverflowMessage(
    String text, {
    required Color color,
    required bool isMe,
    Color? textColor,
    required AvatarPosition avatarPosition,
    Color? avatarColor,
  }) {
    final avatar = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: avatarColor ?? (isMe ? color : Color(0xFFFF7B7B)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 18,
      ),
    );
    
    final messageBubble = Container(
      constraints: BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 15,
          height: 1.35,
        ),
      ),
    );
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: avatarPosition == AvatarPosition.left
          ? [
              avatar,
              const SizedBox(width: 8),
              messageBubble,
            ]
          : [
              messageBubble,
              const SizedBox(width: 8),
              avatar,
            ],
    );
  }

  Widget _buildMainButton(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        child: ElevatedButton(
          onPressed: () => _pickImage(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 6,
          ),
          child: const Text(
            'Enviar captura de tela',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              // Navegação para Home
            },
            icon: const Icon(Icons.home, size: 24, color: Colors.black54),
          ),
          IconButton(
            onPressed: () {
              // Navegação para Histórico
            },
            icon: const Icon(Icons.history, size: 24, color: Colors.black54),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person, size: 24, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // For web, directly pick from gallery
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Navigate to analysis screen with image
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
