import 'package:supabase_flutter/supabase_flutter.dart';
import 'device_id_service.dart';

/// Serviço para gerenciar aprendizado personalizado do usuário
/// 
/// Este serviço:
/// - Cria e gerencia perfis anônimos por dispositivo
/// - Busca preferências aprendidas do usuário
/// - Atualiza preferências baseado em feedbacks
/// - Fornece instruções personalizadas para a IA
class UserLearningService {
  final _supabase = Supabase.instance.client;

  /// Inicializa perfil do usuário (criar se não existir)
  /// 
  /// Deve ser chamado no início do app para garantir que o perfil existe
  Future<String> initializeUserProfile() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      
      // Verificar se perfil já existe
      final existing = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('device_id', deviceId)
          .maybeSingle();
      
      if (existing != null) {
        // Atualizar last_active_at
        await _supabase
            .from('user_profiles')
            .update({'last_active_at': DateTime.now().toIso8601String()})
            .eq('device_id', deviceId);
        
        print('👤 Perfil existente encontrado');
        return existing['id'];
      }
      
      // Criar novo perfil
      final newProfile = await _supabase
          .from('user_profiles')
          .insert({
            'device_id': deviceId,
            'created_at': DateTime.now().toIso8601String(),
            'last_active_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      // Criar preferências iniciais
      await _supabase
          .from('user_preferences')
          .insert({
            'user_profile_id': newProfile['id'],
          });
      
      print('✨ Novo perfil criado: ${newProfile['id']}');
      return newProfile['id'];
      
    } catch (e) {
      print('❌ Erro ao inicializar perfil: $e');
      rethrow;
    }
  }

  /// Busca preferências aprendidas do usuário
  /// 
  /// Retorna dados sobre tons favoritos, exemplos de mensagens, etc.
  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      
      final result = await _supabase
          .from('user_preferences')
          .select('''
            *,
            user_profiles!inner(device_id)
          ''')
          .eq('user_profiles.device_id', deviceId)
          .maybeSingle();
      
      if (result != null) {
        print('📊 Preferências carregadas: ${result['total_likes']} likes, ${result['total_dislikes']} dislikes');
      }
      
      return result;
      
    } catch (e) {
      print('❌ Erro ao buscar preferências: $e');
      return null;
    }
  }

  /// Gera instruções personalizadas para a IA baseadas no aprendizado
  /// 
  /// Retorna um texto adicional para ser incluído no prompt da IA
  Future<String> getPersonalizedInstructions() async {
    try {
      final prefs = await getUserPreferences();
      
      if (prefs == null || prefs['total_likes'] + prefs['total_dislikes'] < 3) {
        // Sem dados suficientes para personalizar
        return '';
      }
      
      final buffer = StringBuffer();
      buffer.writeln('\n\n=== PREFERÊNCIAS APRENDIDAS DESTE USUÁRIO ===');
      
      // Estatísticas
      final totalFeedbacks = prefs['total_likes'] + prefs['total_dislikes'];
      final likeRate = prefs['like_rate'] ?? 0.0;
      buffer.writeln('Taxa de aprovação: ${likeRate.toStringAsFixed(1)}%');
      buffer.writeln('Total de feedbacks: $totalFeedbacks');
      
      // Tons favoritos
      final favoriteTones = prefs['favorite_tones'] as List?;
      if (favoriteTones != null && favoriteTones.isNotEmpty) {
        buffer.writeln('\nTons que ESTE usuário gosta:');
        for (var tone in favoriteTones) {
          buffer.writeln('  - $tone');
        }
      }
      
      // Exemplos de mensagens curtidas
      final goodExamples = prefs['good_examples'] as List?;
      if (goodExamples != null && goodExamples.isNotEmpty) {
        buffer.writeln('\nExemplos de mensagens que ESTE usuário adorou:');
        int count = 0;
        for (var example in goodExamples.take(5)) {
          if (example is Map && example['text'] != null) {
            count++;
            buffer.writeln('  $count. "${example['text']}"');
          }
        }
        buffer.writeln('\n⚠️ IMPORTANTE: Use estes exemplos como inspiração!');
        buffer.writeln('Crie mensagens SIMILARES em estilo e tom.');
      }
      
      // Exemplos de mensagens rejeitadas
      final badExamples = prefs['bad_examples'] as List?;
      if (badExamples != null && badExamples.isNotEmpty) {
        buffer.writeln('\n❌ Mensagens que este usuário NÃO gostou (EVITE):');
        int count = 0;
        for (var example in badExamples.take(3)) {
          if (example is Map && example['text'] != null) {
            count++;
            buffer.writeln('  $count. "${example['text']}"');
          }
        }
        buffer.writeln('\n⚠️ NÃO crie mensagens similares a estas!');
      }
      
      buffer.writeln('\n=====================================\n');
      
      final instructions = buffer.toString();
      print('🎯 Instruções personalizadas geradas (${instructions.length} chars)');
      return instructions;
      
    } catch (e) {
      print('❌ Erro ao gerar instruções: $e');
      return '';
    }
  }

  /// Registra um evento de aprendizado
  Future<void> logLearningEvent(String eventType, Map<String, dynamic> eventData) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      
      // Buscar user_profile_id
      final profile = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('device_id', deviceId)
          .single();
      
      await _supabase
          .from('learning_events')
          .insert({
            'user_profile_id': profile['id'],
            'event_type': eventType,
            'event_data': eventData,
          });
      
      print('📝 Evento registrado: $eventType');
      
    } catch (e) {
      print('❌ Erro ao registrar evento: $e');
    }
  }

  /// Processa feedback manualmente (fallback se trigger não funcionar)
  /// 
  /// Este método atualiza as preferências baseado em um novo feedback
  Future<void> processFeedback({
    required String suggestionText,
    required String feedbackType,
    required String tone,
    List<String>? focusTags,
  }) async {
    try {
      
      // Buscar preferências atuais
      final currentPrefs = await getUserPreferences();
      if (currentPrefs == null) return;
      
      final userProfileId = currentPrefs['user_profile_id'];
      
      // Preparar updates
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (feedbackType == 'like') {
        // Incrementar likes
        updates['total_likes'] = (currentPrefs['total_likes'] ?? 0) + 1;
        
        // Adicionar tom aos favoritos
        final favTones = List<String>.from(currentPrefs['favorite_tones'] ?? []);
        if (!favTones.contains(tone)) {
          favTones.add(tone);
          updates['favorite_tones'] = favTones;
        }
        
        // Adicionar aos bons exemplos (máximo 10)
        final goodExamples = List<Map<String, dynamic>>.from(
          (currentPrefs['good_examples'] ?? []).map((e) => Map<String, dynamic>.from(e))
        );
        goodExamples.insert(0, {
          'text': suggestionText,
          'tone': tone,
          'timestamp': DateTime.now().toIso8601String(),
        });
        updates['good_examples'] = goodExamples.take(10).toList();
        
      } else {
        // Incrementar dislikes
        updates['total_dislikes'] = (currentPrefs['total_dislikes'] ?? 0) + 1;
        
        // Adicionar aos maus exemplos (máximo 10)
        final badExamples = List<Map<String, dynamic>>.from(
          (currentPrefs['bad_examples'] ?? []).map((e) => Map<String, dynamic>.from(e))
        );
        badExamples.insert(0, {
          'text': suggestionText,
          'tone': tone,
          'timestamp': DateTime.now().toIso8601String(),
        });
        updates['bad_examples'] = badExamples.take(10).toList();
      }
      
      // Calcular like_rate
      final totalLikes = updates['total_likes'] ?? currentPrefs['total_likes'] ?? 0;
      final totalDislikes = updates['total_dislikes'] ?? currentPrefs['total_dislikes'] ?? 0;
      final total = totalLikes + totalDislikes;
      if (total > 0) {
        updates['like_rate'] = (totalLikes * 100.0 / total);
      }
      
      // Atualizar no banco
      await _supabase
          .from('user_preferences')
          .update(updates)
          .eq('user_profile_id', userProfileId);
      
      print('✅ Preferências atualizadas: ${updates['total_likes'] ?? currentPrefs['total_likes']}/${updates['total_dislikes'] ?? currentPrefs['total_dislikes']}');
      
      // Log do evento
      await logLearningEvent('preferences_updated', {
        'feedback_type': feedbackType,
        'tone': tone,
        'like_rate': updates['like_rate'],
      });
      
    } catch (e) {
      print('❌ Erro ao processar feedback: $e');
    }
  }

  /// Obtém estatísticas do aprendizado do usuário
  Future<Map<String, dynamic>> getLearningStats() async {
    try {
      final prefs = await getUserPreferences();
      
      if (prefs == null) {
        return {
          'total_feedbacks': 0,
          'total_likes': 0,
          'total_dislikes': 0,
          'like_rate': 0.0,
          'favorite_tones': [],
          'has_learning_data': false,
        };
      }
      
      return {
        'total_feedbacks': (prefs['total_likes'] ?? 0) + (prefs['total_dislikes'] ?? 0),
        'total_likes': prefs['total_likes'] ?? 0,
        'total_dislikes': prefs['total_dislikes'] ?? 0,
        'like_rate': prefs['like_rate'] ?? 0.0,
        'favorite_tones': prefs['favorite_tones'] ?? [],
        'has_learning_data': ((prefs['total_likes'] ?? 0) + (prefs['total_dislikes'] ?? 0)) >= 3,
      };
      
    } catch (e) {
      print('❌ Erro ao buscar estatísticas: $e');
      return {
        'total_feedbacks': 0,
        'has_learning_data': false,
      };
    }
  }
}
