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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFF8E8E),
              Color(0xFFFFB3B3),
              Color(0xFFFFE7E7),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Formas onduladas abstratas
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF6B6B).withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
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
                            // Mockup do celular
                            _buildPhoneMockup(),
                            
                            const SizedBox(height: 30),
                            
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
      ),
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
      height: 500,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // iPhone moderno com Dynamic Island
          Positioned(
            left: 20,
            top: 50,
            child: Container(
              width: 240,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Dynamic Island
                  Positioned(
                    top: 8,
                    left: 85,
                    child: Container(
                      width: 70,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          // Header da conversa
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Nome e status
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Karinny',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Digitando...',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Ícones
                                const Icon(Icons.videocam_outlined, color: Colors.grey, size: 20),
                                const SizedBox(width: 12),
                                const Icon(Icons.call_outlined, color: Colors.grey, size: 20),
                              ],
                            ),
                          ),
                          
                          // Área de mensagens (sem padding para permitir overflow)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Mensagem 1 - overflow à esquerda
                                  Positioned(
                                    top: 20,
                                    left: -30,
                                    child: _buildOverflowMessage(
                                      'Você fica muito fofo com esse maiô',
                                      isMe: false,
                                      color: const Color(0xFFFF6B6B),
                                      avatar: true,
                                    ),
                                  ),
                                  
                                  // Mensagem 2 - normal esquerda
                                  Positioned(
                                    top: 70,
                                    left: 15,
                                    child: _buildOverflowMessage(
                                      'Problemas? Eu? Nunca😇',
                                      isMe: false,
                                      color: const Color(0xFFE5E5EA),
                                      textColor: Colors.black,
                                    ),
                                  ),
                                  
                                  // Mensagem 3 - overflow à direita
                                  Positioned(
                                    top: 120,
                                    right: -40,
                                    child: _buildOverflowMessage(
                                      'Que tal uma taça de vinho?',
                                      isMe: true,
                                      color: const Color(0xFF007AFF),
                                    ),
                                  ),
                                  
                                  // Mensagem 4 - normal esquerda
                                  Positioned(
                                    top: 170,
                                    left: 15,
                                    child: _buildOverflowMessage(
                                      'Estou dentro😊',
                                      isMe: false,
                                      color: const Color(0xFFE5E5EA),
                                      textColor: Colors.black,
                                    ),
                                  ),
                                  
                                  // Mensagem 5 - overflow à direita
                                  Positioned(
                                    top: 220,
                                    right: -35,
                                    child: _buildOverflowMessage(
                                      'Sei onde te levar no primeiro encontro!😊',
                                      isMe: true,
                                      color: const Color(0xFFFF6B6B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Campo de mensagem
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add_circle_outline, color: Colors.grey, size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'iMessage',
                                      style: TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ),
                                  Icon(Icons.mic_none, color: Colors.grey, size: 16),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverflowMessage(String text, {required bool isMe, required Color color, Color? textColor, bool avatar = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar para mensagens da esquerda
        if (!isMe && avatar) ...[
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 6, bottom: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
        
        // Balão da mensagem
        Container(
          constraints: const BoxConstraints(maxWidth: 180),
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Avatar para mensagens da direita
        if (isMe && avatar) ...[
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(left: 6, bottom: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
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
