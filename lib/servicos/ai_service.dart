import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// Removed direct OpenAI client usage; all calls go through Edge Functions
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_config.dart';
import 'user_learning_service.dart';

class AIService {
  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // No direct initialization needed; Edge Function holds the OpenAI key
  static void initialize() {}

  // Upload a imagem para o Storage 'images' e retorna o caminho (ex.: images/abc.jpg)
  // Em Web, baixa bytes se a URL for http/https. Se for blob: retorna null.
  Future<String?> uploadImageToStorage({
    required String imagePath,
  }) async {
    try {
      final storage = SupabaseConfig.client.storage.from('images');
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      Uint8List? bytes;
      if (kIsWeb) {
        if (imagePath.startsWith('http')) {
          final res = await http.get(Uri.parse(imagePath));
          if (res.statusCode == 200) {
            bytes = Uint8List.fromList(res.bodyBytes);
          }
        } else {
          // blob: ou outro esquema não suportado para download direto
          return null;
        }
      } else {
        final file = File(imagePath);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      }

      if (bytes == null) return null;

      await storage.uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );
      return fileName; // caminho relativo no bucket
    } catch (e) {
      return null;
    }
  }

  // Analyze image and generate suggestions
  Future<Map<String, dynamic>> analyzeImageAndGenerateSuggestions({
    String? imagePath,
    required String tone,
    List<String>? focusTags,
  }) async {
    try {
      // Buscar instruções personalizadas do usuário
      final learningService = UserLearningService();
      final personalizedInstructions = await learningService.getPersonalizedInstructions();
      
      // Call Supabase Edge Function for image analysis
      final payload = <String, dynamic>{
        'tone': tone,
        'focus_tags': focusTags ?? [],
      };
      if (imagePath != null && imagePath.isNotEmpty) {
        payload['image_path'] = imagePath;
      }
      // Adicionar instruções personalizadas se existirem
      if (personalizedInstructions.isNotEmpty) {
        payload['personalized_instructions'] = personalizedInstructions;
      }
      
      final response = await _callEdgeFunction('analyze-conversation', payload);

      return response;
    } catch (e) {
      throw AIServiceException('Erro ao analisar imagem: $e');
    }
  }

  // All text generation is handled by the Edge Function now
  Future<List<String>> generateTextSuggestions({
    required String text,
    required String tone,
    String? focus,
  }) async {
    try {
      final resp = await _callEdgeFunction('analyze-conversation', {
        'text': text,
        'tone': tone,
        'focus': focus ?? '',
      });
      final List<dynamic> list = resp['suggestions'] ?? [];
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      throw AIServiceException('Erro ao gerar sugestões (texto): $e');
    }
  }

  // Generate more suggestions
  Future<List<String>> generateMoreSuggestions({
    required String originalText,
    required String tone,
    String? focus,
    List<String>? previousSuggestions,
  }) async {
    try {
      // Agora a Edge Function aceita URL absoluta em image_path.
      // Enviamos novamente a imagem para contextualizar as novas sugestões.
      // CRÍTICO: Enviar previous_suggestions para evitar repetição!
      final response = await _callEdgeFunction('analyze-conversation', {
        'image_path': originalText,
        'tone': tone,
        'focus': focus ?? '',
        if (previousSuggestions != null && previousSuggestions.isNotEmpty)
          'previous_suggestions': previousSuggestions,
      });

      final List<dynamic> list = response['suggestions'] ?? [];
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      throw AIServiceException('Erro ao gerar mais sugestões: $e');
    }
  }

  // Call Supabase Edge Function
  Future<Map<String, dynamic>> _callEdgeFunction(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('${SupabaseConfig.url}/functions/v1/$functionName');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
        'apikey': SupabaseConfig.anonKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw AIServiceException(
        'Edge Function error: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Removed local prompt builders – handled centrally in Edge Function
}

// Custom exception for AI service errors
class AIServiceException implements Exception {
  final String message;
  
  AIServiceException(this.message);
  
  @override
  String toString() => 'AIServiceException: $message';
}
