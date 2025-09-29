import 'package:flutter/material.dart';

/// Paleta de cores do FlertaAI (inspirada no WingAI com diferenciação sutil)
class AppColors {
  // Cores primárias
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)], // Coral mais suave
  );
  
  static const Color secondaryColor = Color(0xFFFFE7E7); // Rosa ainda mais claro
  static const Color accentColor = Color(0xFFFF7043); // Laranja terra
  static const Color backgroundColor = Color(0xFFFFFBFB); // Branco levemente rosado
  static const Color cardColor = Color(0xFFF9F9F9); // Cinza muito claro
  static const Color textPrimary = Color(0xFF2A2A2A); // Cinza escuro suave
  static const Color textSecondary = Color(0xFF666666); // Cinza médio
  
  // Cores adicionais
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  
  // Cores para premium
  static const Color premiumGold = Color(0xFFFFD700);
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  );
}
