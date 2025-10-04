import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// Removed direct OpenAI client usage; all calls go through Edge Functions
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_config.dart';
import '../utils/preprocess_screenshot.dart';
import 'ocr_service.dart';
import 'user_learning_service.dart';

class AIService {
  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Cache para vision_context por image_id
  final Map<String, Map<String, dynamic>> _visionContextCache = {};

  // No direct initialization needed; Edge Function holds the OpenAI key
  static void initialize() {}

  // Upload a imagem para o Storage 'images' e retorna o caminho (ex.: images/abc.jpg)
  // Em Web, baixa bytes se a URL for http/https. Se for blob: retorna null.
  // Se upload falhar, tenta enviar base64 diretamente
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

      // NOVO: Aplicar pré-processamento leve on-device
      try {
        final processedBytes = await ImagePreprocessor.preprocessImage(bytes!);
        if (processedBytes.length < bytes!.length) {
          bytes = processedBytes;
          debugPrint('Imagem pré-processada: ${bytes!.length} bytes');
        }
      } catch (preprocessError) {
        debugPrint('Erro no pré-processamento, usando imagem original: $preprocessError');
      }

      try {
        await storage.uploadBinary(
          fileName,
          bytes!,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
        return fileName; // caminho relativo no bucket
      } catch (uploadError) {
        // Se upload falhou, converte para base64 e retorna com prefixo
        debugPrint('Upload falhou, tentando base64: $uploadError');
        try {
          final base64String = base64Encode(bytes!);
          return 'base64:$base64String'; // Prefixo identifica que é base64
        } catch (base64Error) {
          debugPrint('Erro ao converter para base64: $base64Error');
          return null;
        }
      }
    } catch (e) {
      debugPrint('Erro geral no upload: $e');
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

      // NOVO: Executar OCR antes da análise (apenas mobile, web usa Vision API)
      String? ocrText;
      if (imagePath != null && imagePath.isNotEmpty && !kIsWeb) {
        try {
          // Obter bytes da imagem para OCR
          Uint8List? imageBytes;
          
          if (imagePath.startsWith('base64:')) {
            final base64Data = imagePath.substring(7);
            imageBytes = base64Decode(base64Data);
          } else if (!imagePath.startsWith('http')) {
            final file = File(imagePath);
            if (await file.exists()) {
              imageBytes = await file.readAsBytes();
            }
          }

          if (imageBytes != null) {
            final ocrService = OCRService();
            ocrText = await ocrService.extractText(imageBytes);
            
            if (ocrText != null && ocrText.isNotEmpty) {
              debugPrint('✅ OCR extraiu ${ocrText.length} caracteres');
            }
          }
        } catch (ocrError) {
          debugPrint('⚠️ Erro no OCR (não-crítico): $ocrError');
          // Continua sem OCR - não é crítico
        }
      }

      // Call Supabase Edge Function for image analysis
      final payload = <String, dynamic>{
        'tone': tone,
        'focus_tags': focusTags ?? [],
      };

      // Melhor tratamento de base64 quando upload falha
      if (imagePath != null && imagePath.isNotEmpty) {
        if (imagePath.startsWith('base64:')) {
          // Já é base64, extrair e enviar diretamente
          final base64Data = imagePath.substring(7); // Remove 'base64:' prefix
          payload['image_base64'] = base64Data;
          debugPrint('Enviando imagem como base64 (upload falhou)');
        } else {
          payload['image_path'] = imagePath;
        }
      }

      // NOVO: Incluir texto OCR se disponível (mobile only)
      if (ocrText != null && ocrText.isNotEmpty) {
        payload['ocr_text_raw'] = ocrText;
        debugPrint('📝 OCR incluído no payload: ${ocrText.substring(0, ocrText.length > 50 ? 50 : ocrText.length)}...');
      }

      // Adicionar instruções personalizadas se existirem
      if (personalizedInstructions.isNotEmpty) {
        payload['personalized_instructions'] = personalizedInstructions;
      }

      final response = await _callEdgeFunction('analyze-conversation', payload);

      // Guardar vision_context se disponível (para uso em "Gerar mais")
      if (response.containsKey('vision_context') && response['vision_context'] != null) {
        final imageId = imagePath ?? 'no_image';
        _visionContextCache[imageId] = response['vision_context'];
        debugPrint('Vision context armazenado em cache para imagem: $imageId');
      }

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
    List<String>? focusTags,
    List<String>? previousSuggestions,
  }) async {
    try {
      // NOVO: Usar vision_context em cache para evitar reprocessamento de visão
      final imageId = originalText;
      final visionContext = _visionContextCache[imageId];

      final payload = <String, dynamic>{
        'tone': tone,
        'focus': focus ?? '',
        'focus_tags': focusTags ?? [],
        'previous_suggestions': previousSuggestions ?? [],
      };

      if (visionContext != null) {
        // Usar contexto de visão em cache (skip vision processing)
        payload['skip_vision'] = true;
        payload['vision_context'] = visionContext;
        debugPrint('Usando vision_context em cache para gerar mais sugestões');
      } else {
        // Fallback: enviar novamente a imagem (comportamento antigo)
        payload['image_path'] = originalText;
        debugPrint('Vision context não disponível, reenviando imagem');
      }

      final response = await _callEdgeFunction('analyze-conversation', payload);

      // Atualizar cache se novo vision_context for recebido
      if (response.containsKey('vision_context') && response['vision_context'] != null) {
        _visionContextCache[imageId] = response['vision_context'];
      }

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
