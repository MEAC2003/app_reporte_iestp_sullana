import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/services/notification_service.dart';
import 'package:app_reporte_iestp_sullana/services/notification_utils.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchNotifications extends StatefulWidget {
  const SwitchNotifications({super.key});

  @override
  State<SwitchNotifications> createState() => _SwitchNotificationsState();
}

class _SwitchNotificationsState extends State<SwitchNotifications> {
  bool _notificationsEnabled = false;
  bool _isLoading = false;
  final String _notificationKey = 'reporte_notifications_enabled';

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_notificationKey) ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, value);

      setState(() {
        _notificationsEnabled = value;
      });

      if (value) {
        await _enableNotifications();
      } else {
        await _disableNotifications();
      }

      print('Notificaciones ${value ? 'activadas' : 'desactivadas'}');
    } catch (e) {
      print('Error toggle notificaciones: $e');

      setState(() {
        _notificationsEnabled = !value;
      });

      _showErrorMessage('Error al cambiar configuración de notificaciones');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // MÉTODO SIMPLIFICADO PARA ACTIVAR
  Future<void> _enableNotifications() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userRole = authProvider.userRole.toString().split('.').last;

      // UNA SOLA LÍNEA EN LUGAR DE TODO EL CÓDIGO ANTERIOR
      await NotificationUtils.enableForUser(userRole);

      // Mostrar notificación de confirmación
      await NotificationService.showSystemNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Notificaciones activadas',
        body: 'Te notificaremos sobre cambios en tus reportes',
      );

      _showSuccessMessage('Notificaciones activadas correctamente');
    } catch (e) {
      print('Error activando notificaciones: $e');
      rethrow;
    }
  }

  // MÉTODO SIMPLIFICADO PARA DESACTIVAR
  Future<void> _disableNotifications() async {
    try {
      // UNA SOLA LÍNEA EN LUGAR DE TODO EL CÓDIGO ANTERIOR
      await NotificationUtils.disable();
      _showSuccessMessage('Notificaciones desactivadas');
    } catch (e) {
      print(' Error desactivando notificaciones: $e');
      rethrow;
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(
            _isLoading
                ? Icons.hourglass_empty
                : (_notificationsEnabled
                      ? Icons.notifications
                      : Icons.notifications_off),
          ),
          SizedBox(width: AppSize.defaultPaddingHorizontal * 0.2),
          Text(
            'Notificaciones',
            style: AppStyles.h3(
              fontWeight: FontWeight.w600,
              color: AppColors.darkColor,
            ),
          ),
        ],
      ),
      value: _notificationsEnabled,
      onChanged: _isLoading ? null : _toggleNotifications,
    );
  }
}
