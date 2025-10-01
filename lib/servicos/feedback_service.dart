import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_learning_service.dart';

/// Serviço para gerenciar feedback de sugestões
class FeedbackService {
  final _supabase = Supabase.instance.client;

  /// Salva feedback de uma sugestão
  /// 
  /// [conversationId] - ID da conversa
  /// [suggestionText] - Texto da sugestão avaliada
  /// [suggestionIndex] - Índice da sugestão (0, 1, 2)
  /// [feedbackType] - Tipo de feedback: 'like' ou 'dislike'
  /// [comentario] - Comentário opcional do usuário
  Future<Map<String, dynamic>> saveFeedback({
    required String conversationId,
    required String suggestionText,
    required int suggestionIndex,
    required String feedbackType,
    String? comentario,
  }) async {
    try {
      // Obter usuário atual
      final user = _supabase.auth.currentUser;
      final userId = user?.id;

      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Preparar dados do feedback
      final feedbackData = {
        'user_id': userId,
        'conversation_id': conversationId,
        'suggestion_text': suggestionText,
        'suggestion_index': suggestionIndex,
        'feedback_type': feedbackType,
        if (comentario != null && comentario.isNotEmpty) 'comentario': comentario,
      };

      // Inserir feedback no Supabase
      final response = await _supabase
          .from('suggestion_feedback')
          .insert(feedbackData)
          .select()
          .single();

      // Processar aprendizado do usuário (assíncrono, não bloqueia)
      _processUserLearning(suggestionText, feedbackType);

      return {
        'success': true,
        'feedback_id': response['id'],
        'message': 'Feedback salvo com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erro ao salvar feedback: $e',
      };
    }
  }

  /// Atualiza um feedback existente
  Future<Map<String, dynamic>> updateFeedback({
    required String feedbackId,
    required String feedbackType,
    String? comentario,
  }) async {
    try {
      final updateData = {
        'feedback_type': feedbackType,
        if (comentario != null) 'comentario': comentario,
      };

      await _supabase
          .from('suggestion_feedback')
          .update(updateData)
          .eq('id', feedbackId);

      return {
        'success': true,
        'message': 'Feedback atualizado com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erro ao atualizar feedback: $e',
      };
    }
  }

  /// Busca feedback de uma conversa
  Future<List<Map<String, dynamic>>> getFeedbackByConversation(
    String conversationId,
  ) async {
    try {
      final response = await _supabase
          .from('suggestion_feedback')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar feedback: $e');
      return [];
    }
  }

  /// Busca estatísticas de feedback do usuário
  Future<Map<String, int>> getUserFeedbackStats() async {
    try {
      final user = _supabase.auth.currentUser;
      final userId = user?.id;

      if (userId == null) {
        return {'likes': 0, 'dislikes': 0, 'total': 0};
      }

      final feedbacks = await _supabase
          .from('suggestion_feedback')
          .select()
          .eq('user_id', userId);

      final likes = feedbacks.where((f) => f['feedback_type'] == 'like').length;
      final dislikes = feedbacks.where((f) => f['feedback_type'] == 'dislike').length;

      return {
        'likes': likes,
        'dislikes': dislikes,
        'total': feedbacks.length,
      };
    } catch (e) {
      print('Erro ao buscar estatísticas: $e');
      return {'likes': 0, 'dislikes': 0, 'total': 0};
    }
  }

  /// Processa aprendizado do usuário em background
  Future<void> _processUserLearning(String suggestionText, String feedbackType) async {
    try {
      final learningService = UserLearningService();
      
      // Buscar conversation da última análise
      // Por enquanto, vamos usar tom genérico
      // TODO: Passar tom e tags da conversa real
      await learningService.processFeedback(
        suggestionText: suggestionText,
        feedbackType: feedbackType,
        tone: 'Flertar', // Default, idealmente viria do context
      );
      
      print('✅ Aprendizado processado: $feedbackType');
    } catch (e) {
      print('⚠️ Erro ao processar aprendizado: $e');
      // Falha silenciosa - não impacta UX
    }
  }
}

/// Exception personalizada para erros do serviço de feedback
class FeedbackServiceException implements Exception {
  final String message;
  FeedbackServiceException(this.message);

  @override
  String toString() => 'FeedbackServiceException: $message';
}
