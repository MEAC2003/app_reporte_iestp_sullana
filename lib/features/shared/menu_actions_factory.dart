import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MenuActionsFactory {
  static List<MenuAction> getActionsForRole(
    BuildContext context,
    UserRole role,
  ) {
    switch (role) {
      case UserRole.usuario:
        return _getUserActions(context);
      case UserRole.administrador:
        return _getAdminActions(context);
      case UserRole.soporteTecnico:
        return _getSupportActions(context);
      case UserRole.pendiente:
        return _getPendingActions(context);
    }
  }

  static List<MenuAction> _getUserActions(BuildContext context) {
    return [
      MenuAction(
        icon: Icons.person,
        label: 'Mi Perfil',
        onTap: () {
          Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
          context.push(AppRouter.myAccount);
        },
      ),
      MenuAction(
        icon: Icons.report,
        label: 'Nuevo reporte',
        onTap: () => context.push(AppRouter.addReport),
      ),
      MenuAction(
        icon: Icons.history,
        label: 'H. de reportes',
        onTap: () => context.push(AppRouter.reportHistory),
      ),
    ];
  }

  static List<MenuAction> _getAdminActions(BuildContext context) {
    return [
      MenuAction(
        icon: Icons.people,
        label: 'Usuarios',
        onTap: () => context.push(AppRouter.adminRoles),
      ),
      MenuAction(
        icon: Icons.report,
        label: 'Reportes',
        onTap: () => context.push(AppRouter.adminReport),
      ),
      MenuAction(
        icon: Icons.analytics,
        label: 'Estadísticas',
        onTap: () => context.push(AppRouter.adminAnalytics),
      ),
    ];
  }

  static List<MenuAction> _getSupportActions(BuildContext context) {
    return [
      MenuAction(
        icon: Icons.person,
        label: 'Mi Perfil',
        onTap: () {
          Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
          context.push(AppRouter.myAccount);
        },
      ),
      MenuAction(
        icon: Icons.support_agent,
        label: 'R. Asignados',
        onTap: () => context.push(AppRouter.supportTicketsAssigned),
      ),
      MenuAction(
        icon: Icons.history,
        label: 'Historial',
        onTap: () => context.push(AppRouter.supportHistory),
      ),
    ];
  }

  static List<MenuAction> _getPendingActions(BuildContext context) {
    return [
      MenuAction(
        icon: Icons.hourglass_empty,
        label: 'Cuenta Pendiente',
        onTap: () => context.push(AppRouter.userPending),
      ),
      MenuAction(
        icon: Icons.info,
        label: 'Información',
        onTap: () => _showPendingInfo(context),
      ),
    ];
  }

  static void _showPendingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cuenta en Revisión'),
        content: const Text(
          'Tu cuenta está siendo revisada por nuestro equipo. '
          'Serás notificado cuando sea aprobada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  static String getTitleForRole(UserRole role) {
    switch (role) {
      case UserRole.usuario:
        return 'Menú Principal';
      case UserRole.administrador:
        return 'Estadísticas';
      case UserRole.soporteTecnico:
        return 'Mesa de Soporte';
      case UserRole.pendiente:
        return 'Cuenta Pendiente';
    }
  }

  // Método para obtener el segundo título (solo para admin)
  static String? getSecondaryTitleForRole(UserRole role) {
    switch (role) {
      case UserRole.administrador:
        return 'Panel de Administración';
      default:
        return null;
    }
  }

  // Método para verificar si debe mostrar KPIs
  static bool shouldShowKPIs(UserRole role) {
    return role == UserRole.administrador;
  }

  // Método para obtener los datos de KPI con datos reales
  static Future<Map<String, int>> getReportsKPIData(
    BuildContext context,
  ) async {
    final adminProvider = Provider.of<AdminActionProvider>(
      context,
      listen: false,
    );

    // Asegurarse de que los datos estén cargados
    if (adminProvider.reportes.isEmpty) {
      await adminProvider.loadReportes();
    }

    return adminProvider.getReportsStatistics();
  }

  // Método síncrono que devuelve los datos actuales
  static Map<String, int> getCurrentReportsKPIData(BuildContext context) {
    final adminProvider = Provider.of<AdminActionProvider>(
      context,
      listen: false,
    );
    return adminProvider.getReportsStatistics();
  }
}
