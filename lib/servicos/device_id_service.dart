import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Serviço para gerenciar ID único do dispositivo
/// 
/// Este serviço gera e mantém um ID único para cada dispositivo/navegador,
/// permitindo personalização sem autenticação (MVP).
class DeviceIdService {
  static const String _deviceIdKey = 'flertai_device_id';
  static const _uuid = Uuid();
  
  static String? _cachedDeviceId;

  /// Obtém ou cria um Device ID único
  /// 
  /// O Device ID é gerado uma vez e armazenado localmente.
  /// Mesmo ID será usado em todas as sessões do app.
  static Future<String> getDeviceId() async {
    // Retornar do cache se já tiver
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    
    // Buscar ID armazenado
    String? deviceId = prefs.getString(_deviceIdKey);
    
    // Gerar novo ID se não existir
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
      await prefs.setString(_deviceIdKey, deviceId);
      print('🆔 Novo Device ID gerado: $deviceId');
    } else {
      print('🆔 Device ID existente: $deviceId');
    }
    
    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// Limpa o Device ID (útil para testes)
  static Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    _cachedDeviceId = null;
    print('🗑️ Device ID removido');
  }

  /// Verifica se já existe um Device ID
  static Future<bool> hasDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_deviceIdKey);
  }
}
