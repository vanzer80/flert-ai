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
    return Container(
      width: 240,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Notch do iPhone
          Positioned(
            top: 0,
            left: 100,
            right: 100,
            child: Container(
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
            ),
          ),
          
          // Tela do celular
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  // Header da conversa
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17.5),
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nome e status
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Maria',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
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
                        const Icon(Icons.videocam, color: Colors.grey),
                        const SizedBox(width: 16),
                        const Icon(Icons.call, color: Colors.grey),
                      ],
                    ),
                  ),
                  
                  // Mensagens
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Mensagem recebida
                          _buildMessage(
                            'Você fica muito fofo com esse maiô',
                            isMe: false,
                            color: AppColors.accentColor,
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Mensagem recebida
                          _buildMessage(
                            'Problemas? Eu? Nunca😇',
                            isMe: false,
                            color: Colors.grey[300]!,
                            textColor: Colors.black,
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Mensagem enviada
                          _buildMessage(
                            'Que tal uma taça de vinho?',
                            isMe: true,
                            color: const Color(0xFF007AFF),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Mensagem recebida
                          _buildMessage(
                            'Estou dentro😊',
                            isMe: false,
                            color: Colors.grey[300]!,
                            textColor: Colors.black,
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Mensagem enviada
                          _buildMessage(
                            'Sei onde te levar no primeiro encontro!😊',
                            isMe: true,
                            color: AppColors.accentColor,
                          ),
                          
                          const Spacer(),
                          
                          // Campo de mensagem
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, color: Colors.grey, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Mensagem',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                                Icon(Icons.mic, color: Colors.grey, size: 18),
                              ],
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

  Widget _buildMessage(String text, {required bool isMe, required Color color, Color? textColor}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 11,
          ),
        ),
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
