import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Utilitário para pré-processamento leve de imagens on-device
class ImagePreprocessor {
  /// Pré-processa uma imagem para melhorar a legibilidade do OCR
  /// - Redimensiona para largura máxima de 1280px preservando aspecto
  /// - Aplica crop heurístico da status bar se detectada
  /// - Ajusta contraste e gamma levemente
  /// - Codifica como JPEG 85%
  static Future<Uint8List> preprocessImage(Uint8List imageBytes) async {
    try {
      // Decodificar imagem
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Não foi possível decodificar a imagem');
      }

      debugPrint('Imagem original: ${originalImage.width}x${originalImage.height}');

      // 1. Redimensionar para largura máxima de 1280px preservando aspecto
      final resizedImage = _resizeImage(originalImage, maxWidth: 1280);

      // 2. Aplicar crop heurístico da status bar (se aplicável)
      final croppedImage = _cropStatusBarIfPresent(resizedImage);

      // 3. Aplicar ajustes leves de contraste e gamma
      final enhancedImage = _enhanceImage(croppedImage);

      // 4. Codificar como JPEG 85%
      final processedBytes = img.encodeJpg(enhancedImage, quality: 85);

      debugPrint('Imagem processada: ${enhancedImage.width}x${enhancedImage.height} (${processedBytes.length} bytes)');

      return processedBytes;
    } catch (e) {
      debugPrint('Erro no pré-processamento: $e');
      // Em caso de erro, retorna a imagem original
      return imageBytes;
    }
  }

  /// Redimensiona imagem preservando aspecto
  static img.Image _resizeImage(img.Image image, {required int maxWidth}) {
    if (image.width <= maxWidth) {
      return image;
    }

    final aspectRatio = image.height / image.width;
    final newWidth = maxWidth;
    final newHeight = (newWidth * aspectRatio).round();

    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  /// Crop heurístico da status bar (primeiras ~80px se quase uniformes)
  static img.Image _cropStatusBarIfPresent(img.Image image) {
    const statusBarHeight = 80;
    const tolerance = 10; // Tolerância para considerar uniforme

    if (image.height <= statusBarHeight + 100) {
      // Imagem muito pequena, não aplicar crop
      return image;
    }

    // Verificar se as primeiras linhas são quase uniformes (status bar)
    bool isStatusBar = true;
    final firstPixel = image.getPixel(0, 0);

    for (int y = 1; y < statusBarHeight && y < image.height; y++) {
      final pixel = image.getPixel(0, y);
      if ((firstPixel.r - pixel.r).abs() > tolerance ||
          (firstPixel.g - pixel.g).abs() > tolerance ||
          (firstPixel.b - pixel.b).abs() > tolerance) {
        isStatusBar = false;
        break;
      }
    }

    if (isStatusBar) {
      debugPrint('Status bar detectada e removida');
      return img.copyCrop(image, 
        x: 0, 
        y: statusBarHeight, 
        width: image.width, 
        height: image.height - statusBarHeight
      );
    }

    return image;
  }

  /// Aplica ajustes leves de contraste e gamma
  static img.Image _enhanceImage(img.Image image) {
    // Ajuste de contraste leve (+20%)
    final contrast = 1.2;

    // Ajuste de gamma (0.9 para escurecer um pouco)
    final gamma = 0.9;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        // Aplicar contraste
        int r = ((pixel.r - 128) * contrast + 128).clamp(0, 255).toInt();
        int g = ((pixel.g - 128) * contrast + 128).clamp(0, 255).toInt();
        int b = ((pixel.b - 128) * contrast + 128).clamp(0, 255).toInt();

        // Aplicar gamma
        r = (255 * pow(r / 255.0, gamma)).clamp(0, 255).toInt();
        g = (255 * pow(g / 255.0, gamma)).clamp(0, 255).toInt();
        b = (255 * pow(b / 255.0, gamma)).clamp(0, 255).toInt();

        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    return image;
  }

  /// Calcula o tamanho estimado após processamento
  static int estimateProcessedSize(Uint8List originalBytes) {
    // Estimativa conservadora: 30-60% de redução
    return (originalBytes.length * 0.5).round();
  }
}
