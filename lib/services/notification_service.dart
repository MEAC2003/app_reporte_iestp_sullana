import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // INICIALIZACIÓN COMPLETA
  static Future<void> init() async {
    print('Inicializando NotificationService...');

    try {
      // Configuración Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Configuración general
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      // INICIALIZAR EL PLUGIN
      final bool? initialized = await _flutterLocalNotificationsPlugin
          .initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: _onNotificationTapped,
          );

      if (initialized == true) {
        print('NotificationService inicializado correctamente');

        // Solicitar permisos para Android 13+
        await _requestPermissions();
      } else {
        print('Error al inicializar NotificationService');
      }
    } catch (e) {
      print('Error en inicialización: $e');
    }
  }

  // Solicitar permisos
  static Future<void> _requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation
            .requestNotificationsPermission();
        print(
          'Permisos de notificación: ${granted == true ? 'Concedidos' : 'Denegados'}',
        );
      }
    } catch (e) {
      print('Error solicitando permisos: $e');
    }
  }

  // Manejar cuando se toca la notificación
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      print('🔗 Notificación tocada con payload: $payload');
    }
  }

  // MOSTRAR NOTIFICACIÓN REAL DEL SISTEMA
  static Future<void> showSystemNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Configuración de la notificación Android
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'reporte_channel_id',
            'Reportes de Incidencias',
            channelDescription:
                'Notificaciones de nuevos reportes y actualizaciones',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF4CAF50), // Verde
            playSound: true,
            enableVibration: true,
            showWhen: true,
          );

      // Configuración de la notificación iOS
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      // Configuración general
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Mostrar la notificación
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('¡NOTIFICACIÓN DEL SISTEMA ENVIADA!');
      print('   ID: $id');
      print('   Título: $title');
      print('   Cuerpo: $body');
    } catch (e) {
      print('Error enviando notificación del sistema: $e');
      rethrow; // Re-lanzar para que el RealtimeNotificationService use fallback
    }
  }
}
