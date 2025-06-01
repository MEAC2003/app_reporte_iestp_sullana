import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/screens/screen.dart';
import 'package:app_reporte_iestp_sullana/features/home/presentation/screens/screens.dart';
import 'package:app_reporte_iestp_sullana/features/onboarding/onboarding.dart';
import 'package:app_reporte_iestp_sullana/features/onboarding/onboarding_helper.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/screens/screens.dart';
import 'package:app_reporte_iestp_sullana/features/user/presentation/screens/screens.dart';
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

  static Future<GoRouter> getRouter(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final isOnboardingComplete = await OnboardingHelper.isOnboardingComplete();

    String initialLocation = home;

    if (!isOnboardingComplete) {
      initialLocation = onboarding;
    } else {
      if (authProvider.isAuthenticated &&
          authProvider.hasRole(UserRole.administrador.name)) {
        initialLocation = home;
      } else if (authProvider.isAuthenticated &&
          authProvider.hasRole(UserRole.soporteTecnico.name)) {
        initialLocation = home;
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
      initialLocation: initialLocation,
      routes: [
        // ShellRoute(
        //   builder: (context, state, child) => NavBar(child: child),
        //   routes: [
        //     GoRoute(
        //       path: home,
        //       builder: (context, state) => const HomeScreen(),
        //     ),
        //     GoRoute(
        //       path: catalog,
        //       builder: (context, state) => const CatalogScreen(),
        //     ),
        //     GoRoute(
        //       path: myAccount,
        //       builder: (context, state) {
        //         if (authProvider
        //             .hasRole(UserRole.admin.toString().split('.').last)) {
        //           return const AdminMyAccountScreen();
        //         }
        //         return const MyAccountScreen();
        //       },
        //     ),
        //   ],
        // ),
        // ShellRoute(
        //   builder: (context, state, child) => AdminNavBar(child: child),
        //   routes: [
        //     GoRoute(
        //       path: dashboard,
        //       builder: (context, state) => const DashboardScreen(),
        //     ),
        //     GoRoute(
        //       path: adminActions,
        //       builder: (context, state) => const AdminActionsScreen(),
        //     ),
        //     GoRoute(
        //       path: adminMyAccount,
        //       builder: (context, state) => const AdminMyAccountScreen(),
        //     ),
        //   ],
        // ),
        GoRoute(path: home, builder: (context, state) => const HomeScreen()),
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
      ],
    );
  }
}
