import 'package:app_reporte_iestp_sullana/services/notification_preferences_service.dart';
import 'package:app_reporte_iestp_sullana/services/notification_service.dart';
import 'package:app_reporte_iestp_sullana/services/realtime_notification_service.dart';

class NotificationUtils {
  /// Inicializar notificaciones para un usuario según su rol
  static Future<void> initializeForUser(String userRole) async {
    try {
      final enabled =
          await NotificationPreferencesService.areNotificationsEnabled();

      if (enabled) {
        print('Inicializando notificaciones para rol: $userRole');
        await RealtimeNotificationService.initializeFCM(userRole);
        RealtimeNotificationService.subscribeToReportChanges();
        await RealtimeNotificationService.checkPendingReportsOnLogin(userRole);
        print('Notificaciones inicializadas correctamente');
      } else {
        print('Notificaciones deshabilitadas por el usuario');
      }
    } catch (e) {
      print(' Error en NotificationUtils.initializeForUser: $e');
    }
  }

  /// Desconectar todas las notificaciones
  static Future<void> disconnect() async {
    try {
      print(' Desconectando notificaciones...');
      RealtimeNotificationService.disconnect();
      print(' Notificaciones desconectadas');
    } catch (e) {
      print(' Error en NotificationUtils.disconnect: $e');
    }
  }

  /// Verificar si las notificaciones están habilitadas
  static Future<bool> areNotificationsEnabled() async {
    return await NotificationPreferencesService.areNotificationsEnabled();
  }

  /// Activar notificaciones para un usuario
  static Future<void> enableForUser(String userRole) async {
    try {
      await NotificationPreferencesService.setNotificationsEnabled(true);
      await NotificationService.init();
      await initializeForUser(userRole);
    } catch (e) {
      print(' Error habilitando notificaciones: $e');
      rethrow;
    }
  }

  /// Desactivar notificaciones
  static Future<void> disable() async {
    try {
      await NotificationPreferencesService.setNotificationsEnabled(false);
      await disconnect();
    } catch (e) {
      print(' Error deshabilitando notificaciones: $e');
      rethrow;
    }
  }

  /// Verificar notificaciones al inicializar la app
  static Future<void> checkOnAppStart() async {
    try {
      final enabled =
          await NotificationPreferencesService.areNotificationsEnabled();
      print(' Estado de notificaciones al iniciar app: $enabled');
    } catch (e) {
      print(' Error verificando notificaciones en inicio: $e');
    }
  }
}
