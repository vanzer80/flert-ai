import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_config.dart';

class SupabaseService {
  static final SupabaseClient _client = SupabaseConfig.client;
  
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Getters
  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Authentication methods
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Profile methods
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    
    return response;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _client
        .from('profiles')
        .update(data)
        .eq('id', userId);
  }

  // Conversation methods
  Future<String> saveConversation({
    required String userId,
    required String imageUrl,
    required Map<String, dynamic> analysisResult,
  }) async {
    final response = await _client
        .from('conversations')
        .insert({
          'user_id': userId,
          'image_url': imageUrl,
          'analysis_result': analysisResult,
        })
        .select()
        .single();
    
    return response['id'];
  }

  Future<List<Map<String, dynamic>>> getUserConversations(String userId) async {
    final response = await _client
        .from('conversations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // Suggestions methods
  Future<void> saveSuggestion({
    required String conversationId,
    required String toneType,
    required String suggestionText,
  }) async {
    await _client
        .from('suggestions')
        .insert({
          'conversation_id': conversationId,
          'tone_type': toneType,
          'suggestion_text': suggestionText,
        });
  }

  Future<List<Map<String, dynamic>>> getConversationSuggestions(
    String conversationId,
  ) async {
    final response = await _client
        .from('suggestions')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // Storage methods
  Future<String> uploadImage(String filePath, String fileName) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    
    await _client.storage
        .from('images')
        .uploadBinary(fileName, bytes);
    
    final publicUrl = _client.storage
        .from('images')
        .getPublicUrl(fileName);
    
    return publicUrl;
  }

  // Usage tracking methods
  Future<int> getDailyUsageCount(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final response = await _client
        .from('conversations')
        .select('id')
        .eq('user_id', userId)
        .gte('created_at', startOfDay.toIso8601String());
    
    return response.length;
  }

  Future<void> incrementDailyUsage(String userId) async {
    await _client
        .from('profiles')
        .update({
          'daily_suggestions_used': 
              await getDailyUsageCount(userId) + 1,
        })
        .eq('id', userId);
  }

  // Subscription methods
  Future<bool> isPremiumUser(String userId) async {
    final profile = await getUserProfile(userId);
    return profile?['subscription_type'] == 'premium';
  }

  Future<void> updateSubscription(String userId, String subscriptionType) async {
    await _client
        .from('profiles')
        .update({'subscription_type': subscriptionType})
        .eq('id', userId);
  }

  // Region methods
  Future<String?> getUserRegion(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?['region'] as String?;
    } catch (e) {
      return 'nacional'; // Fallback
    }
  }

  Future<void> updateUserRegion(String userId, String region) async {
    await _client
        .from('profiles')
        .update({'region': region})
        .eq('id', userId);
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToUserConversations(
    String userId,
    void Function(PostgresChangePayload) callback,
  ) {
    return _client
        .channel('conversations:user_id=eq.$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: callback,
        )
        .subscribe();
  }
}


