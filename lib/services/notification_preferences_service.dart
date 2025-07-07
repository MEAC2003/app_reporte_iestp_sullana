import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesService {
  static const String _notificationKey = 'reporte_notifications_enabled';
  static const String _lastCheckKey = 'last_notification_check';

  // VERIFICAR SI LAS NOTIFICACIONES ESTÁN HABILITADAS
  static Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationKey) ?? true; // Por defecto activado
    } catch (e) {
      print('Error checking notification preferences: $e');
      return true; // Fallback a activado
    }
  }

  // HABILITAR/DESHABILITAR NOTIFICACIONES
  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, enabled);
      print('Preferencia de notificaciones guardada: $enabled');
    } catch (e) {
      print('Error saving notification preference: $e');
    }
  }

  // GUARDAR ÚLTIMA VERIFICACIÓN
  static Future<void> saveLastCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving last check: $e');
    }
  }

  // OBTENER ÚLTIMA VERIFICACIÓN
  static Future<DateTime?> getLastCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastCheckKey);
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      print('Error getting last check: $e');
      return null;
    }
  }

  // VERIFICAR SI DEBE MOSTRAR NOTIFICACIONES
  static Future<bool> shouldShowNotifications() async {
    return await areNotificationsEnabled();
  }
}
