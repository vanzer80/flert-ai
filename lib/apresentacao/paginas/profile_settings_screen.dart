import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../servicos/supabase_service.dart';

/// Tela de configurações de perfil do usuário
/// Permite ao usuário selecionar sua região para personalização de referências culturais
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  String _selectedRegion = 'nacional';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Map<String, String>> _regions = [
    {
      'value': 'nacional',
      'label': '🇧🇷 Brasil (Nacional)',
      'description': 'Gírias e referências usadas em todo o Brasil'
    },
    {
      'value': 'norte',
      'label': '🌴 Norte',
      'description': 'AM, PA, AC, RR, AP, RO, TO'
    },
    {
      'value': 'nordeste',
      'label': '☀️ Nordeste',
      'description': 'MA, PI, CE, RN, PB, PE, AL, SE, BA'
    },
    {
      'value': 'centro-oeste',
      'label': '🌾 Centro-Oeste',
      'description': 'MT, MS, GO, DF'
    },
    {
      'value': 'sudeste',
      'label': '🏙️ Sudeste',
      'description': 'SP, RJ, MG, ES'
    },
    {
      'value': 'sul',
      'label': '🧉 Sul',
      'description': 'PR, SC, RS'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRegion();
  }

  Future<void> _loadUserRegion() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabaseService.currentUser?.id;
      
      if (userId != null) {
        // Usuário autenticado: buscar do Supabase
        final region = await _supabaseService.getUserRegion(userId);
        setState(() {
          _selectedRegion = region ?? 'nacional';
          _isLoading = false;
        });
      } else {
        // Sem autenticação: buscar do armazenamento local
        final prefs = await SharedPreferences.getInstance();
        final region = prefs.getString('user_region') ?? 'nacional';
        setState(() {
          _selectedRegion = region;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedRegion = 'nacional';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRegion() async {
    setState(() => _isSaving = true);

    try {
      final userId = _supabaseService.currentUser?.id;
      
      if (userId != null) {
        // Usuário autenticado: salvar no Supabase
        await _supabaseService.updateUserRegion(userId, _selectedRegion);
      } else {
        // Sem autenticação: salvar localmente (MVP)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_region', _selectedRegion);
      }
      
      if (mounted) {
        _showSnackBar('Região salva com sucesso! ✅');
        Navigator.pop(context, _selectedRegion);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao salvar região: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Configurações de Região',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header informativo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selecione sua região',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Isso nos ajuda a usar gírias e referências culturais da sua região nas sugestões! 🎯',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Lista de regiões
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: _regions.map((region) {
                        final isSelected = _selectedRegion == region['value'];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedRegion = region['value']!;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              color: isSelected
                                  ? const Color(0xFFFFEBEE)
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                // Radio button
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE91E63)
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? const Color(0xFFE91E63)
                                        : Colors.white,
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),

                                // Conteúdo
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        region['label']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        region['description']!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Exemplos de referências
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Exemplo de regionalização',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getExampleText(_selectedRegion),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[800],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
      // Botão flutuante na parte inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveRegion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Salvar Região',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _getExampleText(String region) {
    switch (region) {
      case 'sudeste':
        return '• "Você é mó legal!"\n• "Que bagulho interessante!"\n• "Vamos dar um rolê?"';
      case 'nordeste':
        return '• "Oxe! Seu sorriso é lindo!"\n• "Visse como você é especial?"\n• "Bora marcar um açaí?"';
      case 'sul':
        return '• "Bah tchê! Tu é tri legal!"\n• "Que guriazinha linda!"\n• "Vamos tomar um chimarrão?"';
      case 'norte':
        return '• "Maninho, você é demais!"\n• "Tá doido! Que pessoa incrível!"\n• "Bora pro açaí?"';
      case 'centro-oeste':
        return '• "Sô! Você é muito legal!"\n• "Que pessoa bacana!"\n• "Vamos dar uma volta?"';
      default:
        return '• "Oi crush!"\n• "Seu sorriso é top!"\n• "Bora marcar algo?"';
    }
  }
}
