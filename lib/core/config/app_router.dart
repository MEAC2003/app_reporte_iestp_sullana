import 'package:app_reporte_iestp_sullana/features/actions/presentation/screens/screens.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/screens/screens.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/screens/screen.dart';
import 'package:app_reporte_iestp_sullana/features/onboarding/onboarding.dart';
import 'package:app_reporte_iestp_sullana/features/onboarding/onboarding_helper.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/screens/screens.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/features/support/presentation/screens/screens.dart';
import 'package:app_reporte_iestp_sullana/features/user/presentation/screens/screens.dart';
import 'package:app_reporte_iestp_sullana/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static const String home = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String onboarding = '/onboarding';
  static const String userPending = '/user-pending';
  static const String myAccount = '/my-account';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String homeUser = '/home-user';
  static const String homeSupport = '/home-support';
  static const String homeAdmin = '/home-admin';
  static const String addReport = '/add-report';
  static const String reportHistory = '/report-history';
  static const String reportDetail = '/report-detail';
  static const String adminReportDetail = '/admin-report-detail';
  static const String adminRoles = '/admin-roles';
  static const String adminActions = '/admin-actions';
  static const String adminAreaDetail = '/admin-area-detail';
  static const String adminAreaAdd = '/admin-area-add';
  static const String adminAreaUpdate = '/admin-area-update';
  static const String adminViewArea = '/admin-view-area';
  static const String adminEstadoReporteAdd = '/admin-add-estado-reporte';
  static const String adminEstadoReporteUpdate = '/admin-update-estado-reporte';
  static const String adminEstadoReporteDetail = '/admin-detail-estado-reporte';
  static const String adminViewEstadoReporte = '/admin-view-estado-reporte';
  static const String adminPriorityReporteAdd = '/admin-add-priority-reporte';
  static const String adminPriorityReporteUpdate =
      '/admin-update-priority-reporte';
  static const String adminPriorityReporteDetail =
      '/admin-detail-priority-reporte';
  static const String adminViewPriorityReporte = '/admin-view-priority-reporte';
  static const String adminTipoReporteAdd = '/admin-add-tipo-reporte';
  static const String adminTipoReporteUpdate = '/admin-update-tipo-reporte';
  static const String adminTipoReporteDetail = '/admin-detail-tipo-reporte';
  static const String adminViewTipoReporte = '/admin-view-tipo-reporte';
  static const String adminReport = '/admin-report';
  static const String supportTicketsAssigned = '/support-tickets-assigned';
  static const String supportTicketDetail = '/support-ticket-detail';
  static const String supportHistory = '/support-history';
  static const String adminAnalytics = '/admin-analytics';

  static Future<GoRouter> getRouter(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final isOnboardingComplete = await OnboardingHelper.isOnboardingComplete();

    String initialLocation = home;

    if (!isOnboardingComplete) {
      initialLocation = onboarding;
    } else {
      if (authProvider.isAuthenticated &&
          authProvider.hasRole(UserRole.administrador.name)) {
        initialLocation = homeAdmin;
      } else if (authProvider.isAuthenticated &&
          authProvider.hasRole(UserRole.soporteTecnico.name)) {
        initialLocation = homeSupport;
      } else if (authProvider.isAuthenticated &&
          authProvider.hasRole(UserRole.pendiente.name)) {
        initialLocation = userPending;
      } else if (authProvider.isAuthenticated &&
          authProvider.hasRole(UserRole.usuario.name)) {
        initialLocation = homeUser;
      } else if (!authProvider.isAuthenticated) {
        initialLocation = signIn;
      } else {
        initialLocation = home;
      }
    }
    print('Navegando a $initialLocation');
    return GoRouter(
      navigatorKey: NotificationService.navigatorKey,
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (context, state, child) => NavBar(child: child),
          routes: [
            GoRoute(
              path: homeUser,
              builder: (context, state) => const HomeUserScreen(),
            ),
            GoRoute(
              path: myAccount,
              builder: (context, state) => const MyAccountScreen(),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => NavBar(child: child),
          routes: [
            GoRoute(
              path: homeAdmin,
              builder: (context, state) => const HomeAdminScreen(),
            ),
            GoRoute(
              path: adminActions,
              builder: (context, state) => const AdminActionsScreen(),
            ),
            GoRoute(
              path: myAccount,
              builder: (context, state) => const MyAccountScreen(),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => NavBar(child: child),
          routes: [
            GoRoute(
              path: homeSupport,
              builder: (context, state) => const HomeSupportScreen(),
            ),
            GoRoute(
              path: myAccount,
              builder: (context, state) => const MyAccountScreen(),
            ),
          ],
        ),

        GoRoute(
          path: signIn,
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: signUp,
          builder: (context, state) => const SignUpScreen(),
        ),

        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: userPending,
          builder: (context, state) => const UserPendingScreen(),
        ),
        GoRoute(
          path: myAccount,
          builder: (context, state) => const MyAccountScreen(),
        ),
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: homeUser,
          builder: (context, state) => const HomeUserScreen(),
        ),
        GoRoute(
          path: addReport,
          builder: (context, state) => const AddReportScreen(),
        ),
        GoRoute(
          path: reportHistory,
          builder: (context, state) => const ReportHistoryScreen(),
        ),
        GoRoute(
          path: '$reportDetail/:id',
          builder: (context, state) {
            final reportId = state.pathParameters['id']!;
            return UserDetailReportScreen(productId: reportId);
          },
        ),
        GoRoute(
          path: homeAdmin,
          builder: (context, state) => const HomeAdminScreen(),
        ),
        GoRoute(
          path: adminRoles,
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: adminActions,
          builder: (context, state) => const AdminActionsScreen(),
        ),
        GoRoute(
          path: '$adminAreaDetail/:id',
          builder: (context, state) {
            final areaId = state.pathParameters['id']!;
            return AdminDetailAreaScreen(areaId: areaId);
          },
        ),
        GoRoute(
          path: adminAreaAdd,
          builder: (context, state) => const AdminAddAreaScreen(),
        ),
        GoRoute(
          path: '$adminAreaUpdate/:id',
          builder: (context, state) {
            final areaId = state.pathParameters['id']!;
            return AdminUpdateAreaScreen(areaId: areaId);
          },
        ),
        GoRoute(
          path: adminViewArea,
          builder: (context, state) => const AdminViewAreaScreen(),
        ),
        GoRoute(
          path: adminEstadoReporteAdd,
          builder: (context, state) => const AdminAddEstadoReporteScreen(),
        ),
        GoRoute(
          path: '$adminEstadoReporteUpdate/:id',
          builder: (context, state) {
            final estadoId = state.pathParameters['id']!;
            return AdminUpdateEstadoReporteScreen(estadoId: estadoId);
          },
        ),
        GoRoute(
          path: '$adminEstadoReporteDetail/:id',
          builder: (context, state) {
            final estadoId = state.pathParameters['id']!;
            return AdminDetailEstadoReporteScreen(estadoId: estadoId);
          },
        ),
        GoRoute(
          path: adminViewEstadoReporte,
          builder: (context, state) => const AdminViewEstadoReporteScreen(),
        ),
        GoRoute(
          path: adminPriorityReporteAdd,
          builder: (context, state) => const AdminAddPrioridadScreen(),
        ),
        GoRoute(
          path: '$adminPriorityReporteUpdate/:id',
          builder: (context, state) {
            final prioridadId = state.pathParameters['id']!;
            return AdminUpdatePrioridadScreen(prioridadId: prioridadId);
          },
        ),
        GoRoute(
          path: '$adminPriorityReporteDetail/:id',
          builder: (context, state) {
            final prioridadId = state.pathParameters['id']!;
            return AdminDetailPrioridadScreen(prioridadId: prioridadId);
          },
        ),
        GoRoute(
          path: adminViewPriorityReporte,
          builder: (context, state) => const AdminViewPrioridadScreen(),
        ),
        GoRoute(
          path: adminTipoReporteAdd,
          builder: (context, state) => const AdminAddTipoReporteScreen(),
        ),
        GoRoute(
          path: '$adminTipoReporteUpdate/:id',
          builder: (context, state) {
            final tipoReporteId = state.pathParameters['id']!;
            return AdminUpdateTipoReporteScreen(tipoId: tipoReporteId);
          },
        ),
        GoRoute(
          path: '$adminTipoReporteDetail/:id',
          builder: (context, state) {
            final tipoReporteId = state.pathParameters['id']!;
            return AdminDetailTipoReporteScreen(tipoId: tipoReporteId);
          },
        ),
        GoRoute(
          path: adminViewTipoReporte,
          builder: (context, state) => const AdminViewTipoReporteScreen(),
        ),
        GoRoute(
          path: adminReport,
          builder: (context, state) => const AdminReportsScreen(),
        ),
        GoRoute(
          path: '$adminReportDetail/:id',
          builder: (context, state) {
            final reportId = state.pathParameters['id']!;
            return AdminDetailReportScreen(reportId: reportId);
          },
        ),
        GoRoute(
          path: homeSupport,
          builder: (context, state) => const HomeSupportScreen(),
        ),
        GoRoute(
          path: supportTicketsAssigned,
          builder: (context, state) => const SupportTicketsAssignedScreen(),
        ),
        GoRoute(
          path: '$supportTicketDetail/:id',
          builder: (context, state) {
            final ticketId = state.pathParameters['id']!;
            return SupportDetailReportScreen(reportId: ticketId);
          },
        ),
        GoRoute(
          path: supportHistory,
          builder: (context, state) => const SupportHistoryScreen(),
        ),
        GoRoute(
          path: adminAnalytics,
          builder: (context, state) => const AdminAnalyticsScreen(),
        ),
      ],
    );
  }
}
