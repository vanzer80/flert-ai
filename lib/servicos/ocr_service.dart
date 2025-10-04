import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

/// Serviço de OCR para extrair texto de imagens
class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  TextRecognizer? _textRecognizer;

  /// Inicializa o reconhecedor de texto (apenas mobile)
  void _initializeRecognizer() {
    if (!kIsWeb && _textRecognizer == null) {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    }
  }

  /// Extrai texto de uma imagem usando OCR
  /// - Mobile: usa Google ML Kit (preciso e offline)
  /// - Web: retorna vazio (OCR será feito pelo backend via Vision API)
  Future<String> extractText(Uint8List imageBytes) async {
    try {
      if (kIsWeb) {
        return await _extractTextWeb(imageBytes);
      } else {
        return await _extractTextMobile(imageBytes);
      }
    } catch (e) {
      debugPrint('❌ Erro no OCR: $e');
      return '';
    }
  }

  /// OCR usando Google ML Kit (mobile apenas)
  Future<String> _extractTextMobile(Uint8List imageBytes) async {
    try {
      _initializeRecognizer();
      
      if (_textRecognizer == null) {
        debugPrint('⚠️ OCR Mobile: TextRecognizer não inicializado');
        return '';
      }

      // Decodificar imagem para obter dimensões reais
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('⚠️ OCR Mobile: Não foi possível decodificar imagem');
        return '';
      }

      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: ui.Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.yuv420,
          bytesPerRow: image.width,
        ),
      );

      final RecognizedText recognizedText = await _textRecognizer!.processImage(inputImage);

      // Combinar todos os blocos de texto preservando estrutura
      final extractedText = recognizedText.blocks
          .map((block) => block.text)
          .join('\n')
          .trim();

      if (extractedText.isNotEmpty) {
        debugPrint('✅ OCR Mobile extraiu: ${extractedText.length} caracteres');
        debugPrint('📝 Primeiros 100 chars: ${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}');
      } else {
        debugPrint('⚠️ OCR Mobile: Nenhum texto detectado');
      }

      return extractedText;
    } catch (e) {
      debugPrint('❌ Erro no OCR Mobile: $e');
      return '';
    }
  }

  /// OCR Web - Delegado ao backend (Vision API já faz OCR)
  Future<String> _extractTextWeb(Uint8List imageBytes) async {
    try {
      // Na web, o OCR é feito pelo backend via Vision API
      // que já extrai texto durante a análise da imagem
      debugPrint('ℹ️ OCR Web: Delegado ao backend (Vision API)');
      return '';
    } catch (e) {
      debugPrint('❌ Erro no OCR Web: $e');
      return '';
    }
  }

  /// Fecha o reconhecedor de texto
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
