import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Configurações do projeto FlertAI
  static const String url = 'https://olojvpoqosrjcoxygiyf.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9sb2p2cG9xb3NyamNveHlnaXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTUxNTEsImV4cCI6MjA3NDY3MTE1MX0.QyJcKSHfWA0RyzoucvSObabOl5lsdgvJ3BnZsBy7HX8';
  
  // Configurações do banco de dados
  static const String host = 'aws-1-sa-east-1.pooler.supabase.com';
  static const int port = 6543;
  static const String database = 'postgres';
  static const String user = 'postgres.olojvpoqosrjcoxygiyf';
  
  // Chaves adicionais
  static const String publishableKey = 'sb_publishable_sQQEaOA4VmvgaDEXJgI25Q_yVt2VF_E';
  static const String secretKey = 'sb_secret_jbDrvR5xbv9RxbXpNySPQQ_WVwzest8';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      // ignore: avoid_print
      print('[SupabaseConfig] Supabase inicializado com sucesso!');
    } catch (e) {
      // ignore: avoid_print
      print('[SupabaseConfig] Erro ao inicializar Supabase: $e');
      rethrow;
    }
  }
}
