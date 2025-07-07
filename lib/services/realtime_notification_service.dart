import 'dart:async';
import 'package:app_reporte_iestp_sullana/services/notification_preferences_service.dart';
import 'package:app_reporte_iestp_sullana/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RealtimeNotificationService {
  static RealtimeChannel? _reportsChannel;
  static FirebaseMessaging? _messaging;
  static String? _currentUserRole;

  //INICIALIZAR FCM
  static Future<void> initializeFCM(String userRole) async {
    print('Inicializando Firebase Cloud Messaging para rol: $userRole');

    _messaging = FirebaseMessaging.instance;
    _currentUserRole = userRole;

    // Solicitar permisos
    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos de notificación otorgados');
    } else {
      print('Permisos de notificación denegados');
      return;
    }

    // Obtener token FCM
    String? token = await _messaging!.getToken();
    print('FCM Token: $token');

    // Suscribirse a topics según rol
    await _subscribeToTopics(userRole);

    // Configurar listeners
    _setupNotificationListeners();

    print('FCM inicializado correctamente');
  }

  // SUSCRIBIRSE A TOPICS SEGÚN ROL
  static Future<void> _subscribeToTopics(String role) async {
    try {
      print('Suscribiéndose a topics para rol: $role');

      // Topic general para todos
      await _messaging!.subscribeToTopic('all_users');
      print('Suscrito a: all_users');

      // Topics específicos por rol usando tu enum
      switch (role.toLowerCase()) {
        case 'administrador':
          await _messaging!.subscribeToTopic('admin');
          print('Suscrito a: admin');
          break;
        case 'soportetecnico':
          await _messaging!.subscribeToTopic('support');
          print('Suscrito a: support');
          break;
        case 'usuario':
          await _messaging!.subscribeToTopic('users');
          print('Suscrito a: users');
          break;
        case 'pendiente':
          await _messaging!.subscribeToTopic('pending');
          print('uscrito a: pending');
          break;
        default:
          await _messaging!.subscribeToTopic('users');
          print('Suscrito a: users (default)');
          break;
      }

      print('Suscripción a topics completada');
    } catch (e) {
      print('Error en suscripción a topics: $e');
    }
  }

  // CONFIGURAR LISTENERS PARA NOTIFICACIONES
  static void _setupNotificationListeners() {
    if (_messaging == null) return;

    // Cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación recibida en primer plano');
      _showLocalNotification(
        message.notification?.title ?? 'Nueva notificación',
        message.notification?.body ?? 'Tienes una nueva notificación',
        message.data['route'] ?? '/home',
      );
    });

    // Cuando el usuario toca la notificación (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación tocada desde background');
      _handleNotificationTap(message);
    });

    // Cuando la app se abre desde una notificación (app cerrada)
    _messaging!.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App abierta desde notificación');
        _handleNotificationTap(message);
      }
    });
  }

  // MANEJAR CUANDO EL USUARIO TOCA UNA NOTIFICACIÓN
  static void _handleNotificationTap(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null) {
      print('Navegando a: $route');
      // Aquí puedes implementar navegación usando tu sistema de rutas
    }
  }

  // VERIFICAR REPORTES PENDIENTES AL INICIAR SESIÓN (ACTUALIZADO)
  static Future<void> checkPendingReportsOnLogin(String userRole) async {
    print('Verificando reportes pendientes para rol: $userRole');

    try {
      switch (userRole.toLowerCase()) {
        case 'administrador':
          await _checkNewReportsForAdmin();
          break;
        case 'soportetecnico':
          await _checkAssignedReportsForSupport();
          break;
        case 'usuario':
          await _checkUserReportsStatus();
          break;
        case 'pendiente':
        default:
          // Los usuarios pendientes no necesitan verificaciones automáticas
          print('Sin verificaciones automáticas para rol: $userRole');
          break;
      }
    } catch (e) {
      print('Error verificando reportes pendientes: $e');
    }
  }

  // VERIFICAR REPORTES NUEVOS PARA ADMINISTRADOR (USANDO TUS IDs REALES)
  static Future<void> _checkNewReportsForAdmin() async {
    try {
      print('Verificando reportes nuevos para administrador...');

      // Usar el ID exacto de "Nuevo" de tu AdminActionProvider
      const String estadoNuevoId = "29e11cdf-fcf7-4c36-a7fd-f363dcaf864c";

      final response = await Supabase.instance.client
          .from('reporte_incidencia')
          .select('id, descripcion, id_estado_reporte')
          .eq('id_estado_reporte', estadoNuevoId);

      final reportesNuevos = response as List;
      final cantidad = reportesNuevos.length;

      print('Reportes nuevos encontrados: $cantidad');

      if (cantidad > 0) {
        String titulo;
        String mensaje;

        if (cantidad == 1) {
          titulo = 'Nuevo reporte por asignar';
          mensaje = 'Hay 1 reporte pendiente por asignar';
        } else {
          titulo = 'Reportes por asignar';
          mensaje = 'Hay $cantidad reportes pendientes por asignar';
        }

        await _showLocalNotification(titulo, mensaje, '/admin/reports');
        print('Notificación de reportes nuevos enviada al admin');
      } else {
        print('No hay reportes nuevos para el administrador');
      }
    } catch (e) {
      print('Error verificando reportes nuevos: $e');
    }
  }

  // VERIFICAR REPORTES ASIGNADOS PARA SOPORTE (USANDO TUS IDs REALES)
  static Future<void> _checkAssignedReportsForSupport() async {
    try {
      print('Verificando reportes asignados para soporte...');

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        print('No hay usuario autenticado');
        return;
      }

      // Usar el ID exacto de "Asignado" de tu AdminActionProvider
      const String estadoAsignadoId = "60af230d-a751-4dbe-9ecb-b101ffcb828b";

      // BUSCAR EN DETALLE_REPORTE COMO LO HACES EN TU PROVIDER
      final response = await Supabase.instance.client
          .from('detalle_reporte')
          .select('''
            id,
            id_reporte_incidencia,
            reporte_incidencia!inner(
              id,
              descripcion,
              id_estado_reporte
            )
          ''')
          .eq('id_soporte_asignado', currentUser.id)
          .eq('reporte_incidencia.id_estado_reporte', estadoAsignadoId);

      final reportesAsignados = response as List;
      final cantidad = reportesAsignados.length;

      print('Reportes asignados encontrados: $cantidad');

      if (cantidad > 0) {
        String titulo;
        String mensaje;

        if (cantidad == 1) {
          titulo = 'Nuevo reporte asignado';
          mensaje = 'Tienes 1 reporte asignado pendiente';
        } else {
          titulo = 'Reportes asignados';
          mensaje = 'Tienes $cantidad reportes asignados pendientes';
        }

        await _showLocalNotification(titulo, mensaje, '/support/reports');
        print('Notificación de reportes asignados enviada al soporte');
      } else {
        print('No hay reportes asignados para este técnico');
      }
    } catch (e) {
      print('Error verificando reportes asignados: $e');
    }
  }

  // VERIFICAR ESTADO DE REPORTES PARA USUARIOS
  static Future<void> _checkUserReportsStatus() async {
    try {
      print('Verificando estado de reportes para usuario...');

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        print('No hay usuario autenticado');
        return;
      }

      // IDs de estados importantes para el usuario
      const String estadoAsignadoId =
          "60af230d-a751-4dbe-9ecb-b101ffcb828b"; // Asignado
      const String estadoResueltoxId =
          "52c2b7bc-194c-4759-b83c-3913625da86d"; // Resuelto

      // Verificar reportes asignados
      await _checkUserAssignedReports(currentUser.id, estadoAsignadoId);

      // Verificar reportes resueltos
      await _checkUserResolvedReports(currentUser.id, estadoResueltoxId);
    } catch (e) {
      print('Error verificando reportes del usuario: $e');
    }
  }

  //VERIFICAR REPORTES ASIGNADOS DEL USUARIO
  static Future<void> _checkUserAssignedReports(
    String userId,
    String estadoAsignadoId,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('reporte_incidencia')
          .select('id, descripcion, id_estado_reporte, created_at')
          .eq('id_usuario', userId)
          .eq('id_estado_reporte', estadoAsignadoId);

      final reportesAsignados = response as List;
      final cantidad = reportesAsignados.length;

      print('Reportes asignados del usuario encontrados: $cantidad');

      if (cantidad > 0) {
        String titulo;
        String mensaje;

        if (cantidad == 1) {
          titulo = 'Tu reporte fue asignado';
          mensaje =
              'Tu reporte ha sido asignado a un soporte técnico. Pronto se acercarán a tu área';
        } else {
          titulo = 'Reportes asignados';
          mensaje = 'Tienes $cantidad reportes asignados a soporte técnico';
        }

        await _showLocalNotification(titulo, mensaje, '/user/reports');
        print('Notificación de reportes asignados enviada al usuario');
      } else {
        print('No hay reportes asignados nuevos para el usuario');
      }
    } catch (e) {
      print('Error verificando reportes asignados del usuario: $e');
    }
  }

  // VERIFICAR REPORTES RESUELTOS DEL USUARIO
  static Future<void> _checkUserResolvedReports(
    String userId,
    String estadoResueltoxId,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('reporte_incidencia')
          .select('id, descripcion, id_estado_reporte, created_at')
          .eq('id_usuario', userId)
          .eq('id_estado_reporte', estadoResueltoxId);

      final reportesResueltos = response as List;
      final cantidad = reportesResueltos.length;

      print('Reportes resueltos del usuario encontrados: $cantidad');

      if (cantidad > 0) {
        String titulo;
        String mensaje;

        if (cantidad == 1) {
          titulo = 'Tu reporte fue resuelto';
          mensaje =
              'Tu reporte ha sido resuelto exitosamente. ¡Gracias por tu reporte!';
        } else {
          titulo = 'Reportes resueltos';
          mensaje =
              'Tienes $cantidad reportes resueltos. ¡Gracias por reportar!';
        }

        await _showLocalNotification(titulo, mensaje, '/user/reports');
        print('Notificación de reportes resueltos enviada al usuario');
      } else {
        print('No hay reportes resueltos nuevos para el usuario');
      }
    } catch (e) {
      print('Error verificando reportes resueltos del usuario: $e');
    }
  }

  // SUSCRIBIRSE A CAMBIOS DE SUPABASE EN TIEMPO REAL
  static void subscribeToReportChanges() {
    print('Configurando suscripción a cambios de reportes...');

    _reportsChannel = Supabase.instance.client
        .channel('reportes_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'reporte_incidencia',
          callback: _handleReportInserted,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'reporte_incidencia',
          callback: _handleReportUpdated,
        )
        .subscribe();

    print('Suscripción a cambios de reportes configurada');
  }

  static void _handleReportInserted(PostgresChangePayload payload) async {
    print('Nuevo reporte detectado: ${payload.newRecord}');

    final reportData = payload.newRecord;
    final reportId = reportData['id'];
    final descripcion = reportData['descripcion'] ?? 'Nuevo reporte';
    final estadoId = reportData['id_estado_reporte'];

    // Solo notificar si es un reporte nuevo (estado "Nuevo")
    const String estadoNuevoId = "29e11cdf-fcf7-4c36-a7fd-f363dcaf864c";

    if (estadoId == estadoNuevoId) {
      // Notificar a administradores cuando se crea un reporte nuevo
      await _showLocalNotification(
        'Nuevo reporte creado',
        'Reporte: $descripcion',
        '/admin/reports/$reportId',
      );
      print('Notificación de nuevo reporte enviada');
    }
  }

  // CUANDO SE ACTUALIZA UN REPORTE
  static void _handleReportUpdated(PostgresChangePayload payload) async {
    print('Reporte actualizado: ${payload.newRecord}');

    final reportData = payload.newRecord;
    final reportId = reportData['id'];
    final descripcion = reportData['descripcion'] ?? 'Tu reporte';
    final userId = reportData['id_usuario'];
    final nuevoEstadoId = reportData['id_estado_reporte'];
    final estadoAnteriorId = payload.oldRecord['id_estado_reporte'];

    // Solo notificar si hubo cambio de estado significativo
    if (nuevoEstadoId != estadoAnteriorId && userId != null) {
      String tituloNotificacion = 'Tu reporte fue actualizado';
      String mensajeNotificacion = 'Reporte: $descripcion';

      // Personalizar mensaje según el nuevo estado usando tus IDs
      switch (nuevoEstadoId) {
        case "60af230d-a751-4dbe-9ecb-b101ffcb828b": // Asignado
          tituloNotificacion = 'Reporte asignado';
          mensajeNotificacion =
              'Tu reporte ha sido asignado a un soporte técnico. Pronto se acercarán a tu área para solucionarlo';
          break;
        case "cb56bfbe-6fd4-4d0b-ad5b-3bb31194e223": // En proceso
          tituloNotificacion = 'Reporte en proceso';
          mensajeNotificacion =
              'Tu reporte está siendo atendido por el equipo técnico';
          break;
        case "afab4980-5c12-4457-88a2-c3cd0bb198e1": // En espera
          tituloNotificacion = 'Reporte en espera';
          mensajeNotificacion =
              'Tu reporte está en espera de repuestos. Te notificaremos cuando continúe el proceso';
          break;
        case "52c2b7bc-194c-4759-b83c-3913625da86d": // Resuelto
          tituloNotificacion = '¡Reporte resuelto!';
          mensajeNotificacion =
              'Tu reporte ha sido resuelto exitosamente. ¡Gracias por ayudarnos a mejorar!';
          break;
        case "d2d0cc74-0a47-4626-9571-adc8c07a8be0": // Cerrado
          tituloNotificacion = 'Reporte cerrado';
          mensajeNotificacion =
              'Tu reporte ha sido cerrado. Si tienes dudas, contacta al administrador';
          break;
        case "1d7db7fb-5bbe-4c5a-a24e-2930fdc8289e": // Cancelado
          tituloNotificacion = 'Reporte cancelado';
          mensajeNotificacion =
              'Tu reporte ha sido cancelado. Si consideras que es un error, contacta al administrador';
          break;
      }

      await _showLocalNotification(
        tituloNotificacion,
        mensajeNotificacion,
        '/user/reports/$reportId',
      );
      print(
        'Notificación de actualización enviada al usuario: $tituloNotificacion',
      );
    }
  }

  // MOSTRAR NOTIFICACIÓN LOCAL (ACTUALIZADO)
  static Future<void> _showLocalNotification(
    String title,
    String body,
    String route,
  ) async {
    try {
      // VERIFICAR SI LAS NOTIFICACIONES ESTÁN HABILITADAS
      final notificationsEnabled =
          await NotificationPreferencesService.areNotificationsEnabled();

      if (!notificationsEnabled) {
        print(
          'Notificaciones deshabilitadas por el usuario - Omitiendo: $title',
        );
        return;
      }

      await NotificationService.showSystemNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        payload: route,
      );
      print('Notificación local mostrada: $title');
    } catch (e) {
      print('Error mostrando notificación local: $e');
    }
  }

  // MÉTODO ADICIONAL: Verificar reportes asignados para soporte específico
  static Future<void> checkAssignedReportsForSpecificSupport(
    String supportId,
  ) async {
    try {
      print('🔍 Verificando reportes para soporte específico: $supportId');

      const String estadoAsignadoId = "60af230d-a751-4dbe-9ecb-b101ffcb828b";

      final response = await Supabase.instance.client
          .from('detalle_reporte')
          .select('''
            id,
            id_reporte_incidencia,
            reporte_incidencia!inner(
              id,
              descripcion,
              id_estado_reporte
            )
          ''')
          .eq('id_soporte_asignado', supportId)
          .eq('reporte_incidencia.id_estado_reporte', estadoAsignadoId);

      final reportesAsignados = response as List;
      final cantidad = reportesAsignados.length;

      if (cantidad > 0) {
        String titulo = cantidad == 1
            ? 'Nuevo reporte asignado'
            : 'Reportes asignados';
        String mensaje = cantidad == 1
            ? 'Tienes 1 reporte asignado pendiente'
            : 'Tienes $cantidad reportes asignados pendientes';

        await _showLocalNotification(titulo, mensaje, '/support/reports');
        print('Notificación enviada al soporte $supportId');
      }
    } catch (e) {
      print('Error verificando reportes para soporte específico: $e');
    }
  }

  // OBTENER ESTADÍSTICAS PARA NOTIFICACIONES ADMIN
  static Future<Map<String, int>> getAdminStatistics() async {
    try {
      print('Obteniendo estadísticas para administrador...');

      final response = await Supabase.instance.client
          .from('reporte_incidencia')
          .select('id_estado_reporte');

      final reportes = response as List;

      // Contar usando tus IDs exactos
      int nuevos = 0;
      int asignados = 0;
      int enProceso = 0;
      int enEspera = 0;
      int resueltos = 0;
      int cerrados = 0;
      int cancelados = 0;

      for (final reporte in reportes) {
        final estadoId = reporte['id_estado_reporte'] as String;

        switch (estadoId) {
          case "29e11cdf-fcf7-4c36-a7fd-f363dcaf864c": // Nuevo
            nuevos++;
            break;
          case "60af230d-a751-4dbe-9ecb-b101ffcb828b": // Asignado
            asignados++;
            break;
          case "cb56bfbe-6fd4-4d0b-ad5b-3bb31194e223": // En proceso
            enProceso++;
            break;
          case "afab4980-5c12-4457-88a2-c3cd0bb198e1": // En espera
            enEspera++;
            break;
          case "52c2b7bc-194c-4759-b83c-3913625da86d": // Resuelto
            resueltos++;
            break;
          case "d2d0cc74-0a47-4626-9571-adc8c07a8be0": // Cerrado
            cerrados++;
            break;
          case "1d7db7fb-5bbe-4c5a-a24e-2930fdc8289e": // Cancelado
            cancelados++;
            break;
        }
      }

      return {
        'total': reportes.length,
        'nuevos': nuevos,
        'asignados': asignados,
        'enProceso': enProceso,
        'enEspera': enEspera,
        'resueltos': resueltos,
        'cerrados': cerrados,
        'cancelados': cancelados,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }

  // DESCONECTAR TODO
  static void disconnect() {
    print('Desconectando servicios de notificación...');

    _reportsChannel?.unsubscribe();
    _reportsChannel = null;
    _messaging = null;
    _currentUserRole = null;

    print('Servicios desconectados');
  }
}
