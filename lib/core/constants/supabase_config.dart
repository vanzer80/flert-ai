import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Configurações temporárias para desenvolvimento (REMOVER EM PRODUÇÃO)
  static String get url => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://olojvpoqosrjcoxygiyf.supabase.co'
  );

  static String get anonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9sb2p2cG9xb3NyamNveHlnaXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTUxNTEsImV4cCI6MjA3NDY3MTE1MX0.QyJcKSHfWA0RyzoucvSObabOl5lsdgvJ3BnZsBy7HX8'
  );

  // Configurações do banco de dados (usar variáveis de ambiente)
  static String get host => const String.fromEnvironment(
    'SUPABASE_DB_HOST',
    defaultValue: 'aws-1-sa-east-1.pooler.supabase.com'
  );

  static int get port {
    const envPort = String.fromEnvironment('SUPABASE_DB_PORT', defaultValue: '6543');
    return int.tryParse(envPort) ?? 6543;
  }

  static String get database => const String.fromEnvironment(
    'SUPABASE_DB_NAME',
    defaultValue: 'postgres'
  );

  static String get user => const String.fromEnvironment(
    'SUPABASE_DB_USER',
    defaultValue: 'postgres'
  );

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
      // Não relança o erro para não quebrar o app em desenvolvimento
    }
  }
}
