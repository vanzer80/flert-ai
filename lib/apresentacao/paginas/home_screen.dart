import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background com formas onduladas
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
                          // Mockup do iPhone
                          _buildPhoneMockup(),
                          
                          const SizedBox(height: 40),
                          
                          // Título
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Envie um chat ou a bio do seu match',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1.2,
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
    );
  }
  
  Widget _buildWavyBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF8B8B),
                Color(0xFFFFB3B3),
                Color(0xFFFFD6D6),
              ],
            ),
          ),
        ),
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6B6B).withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          top: 150,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF7B7B).withOpacity(0.25),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF8585).withOpacity(0.2),
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

  Widget _buildPhoneMockup() {
    return SizedBox(
      width: 280,
      height: 520,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Frame do iPhone
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(42),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Notch/Dynamic Island
                  Positioned(
                    top: 0,
                    left: 110,
                    right: 110,
                    child: Container(
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  
                  // Tela interna
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Container(
                      clipBehavior: Clip.none,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: [
                              // Header
                              _buildChatHeader(),
                              // Área de mensagens com overflow
                              Expanded(
                                child: _buildMessagesArea(),
                              ),
                              // Footer
                              _buildChatFooter(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7B7B), Color(0xFFFF8585)],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          // Nome e status
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Karinny',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Digitando...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Ícones
          const Icon(Icons.videocam_outlined, color: Colors.grey, size: 22),
          const SizedBox(width: 12),
          const Icon(Icons.call_outlined, color: Colors.grey, size: 22),
        ],
      ),
    );
  }
  
  Widget _buildMessagesArea() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Mensagem 1 - Laranja saindo pela ESQUERDA
              _buildMessageWithAvatar(
                text: 'Você fica muito fofo com esse maiô',
                color: const Color(0xFFFF7B7B),
                avatarColor: const Color(0xFFFF7B7B),
                isMe: false,
                offsetX: -100,
              ),
              
              const SizedBox(height: 16),
              
              // Mensagem 2 - Cinza DENTRO do telefone
              _buildMessageWithAvatar(
                text: 'Problemas? Eu? Nunca😇',
                color: const Color(0xFFE5E5EA),
                avatarColor: const Color(0xFFFF7B7B),
                isMe: false,
                textColor: Colors.black,
                offsetX: 0,
              ),
              
              const SizedBox(height: 16),
              
              // Mensagem 3 - Azul saindo pela DIREITA
              _buildMessageWithAvatar(
                text: 'Que tal uma taça de vinho?',
                color: const Color(0xFF007AFF),
                avatarColor: const Color(0xFF007AFF),
                isMe: true,
                offsetX: 100,
              ),
              
              const SizedBox(height: 16),
              
              // Mensagem 4 - Cinza DENTRO do telefone
              _buildMessageWithAvatar(
                text: 'Estou dentro😁',
                color: const Color(0xFFE5E5EA),
                avatarColor: const Color(0xFFFF7B7B),
                isMe: false,
                textColor: Colors.black,
                offsetX: 0,
              ),
              
              const Spacer(),
              
              // Mensagem 5 - Laranja saindo pela DIREITA (inferior)
              _buildMessageWithAvatar(
                text: 'Sei onde te levar no primeiro encontro!😊',
                color: const Color(0xFFFF7B7B),
                avatarColor: const Color(0xFFFF7B7B),
                isMe: true,
                offsetX: 90,
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMessageWithAvatar({
    required String text,
    required Color color,
    required Color avatarColor,
    required bool isMe,
    Color? textColor,
    required double offsetX,
  }) {
    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Avatar à esquerda
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          // Balão de mensagem
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            // Avatar à direita
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChatFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.camera_alt, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'iMessage',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.mic, color: Colors.grey.shade600, size: 24),
        ],
      ),
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
