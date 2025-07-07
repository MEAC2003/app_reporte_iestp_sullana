import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class NavBar extends StatefulWidget {
  final Widget child;

  const NavBar({super.key, required this.child});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNavBarWithRoute();
    });
  }

  void _syncNavBarWithRoute() {
    final location = GoRouterState.of(context).uri.path;
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.hasRole(UserRole.administrador.name);
    final isSoporte = authProvider.hasRole(UserRole.soporteTecnico.name);

    int correctIndex = _getIndexForRoute(location, isAdmin, isSoporte);

    // Solo actualizar si es diferente
    if (navigationProvider.currentIndex != correctIndex) {
      navigationProvider.setIndexSilently(correctIndex);
    }
  }

  int _getIndexForRoute(String route, bool isAdmin, bool isSoporte) {
    if (isAdmin) {
      switch (route) {
        case AppRouter.homeAdmin:
          return 0;
        case AppRouter.adminActions:
          return 1;
        case AppRouter.myAccount:
          return 2;
        default:
          return 0;
      }
    } else if (isSoporte) {
      switch (route) {
        case AppRouter.homeSupport:
          return 0;
        case AppRouter.myAccount:
          return 1;
        default:
          return 0;
      }
    } else {
      switch (route) {
        case AppRouter.homeUser:
          return 0;
        case AppRouter.myAccount:
          return 1;
        default:
          return 0;
      }
    }
  }

  void _navigateToIndex(int index, bool isAdmin, bool isSoporte) {
    if (isAdmin) {
      switch (index) {
        case 0:
          context.go(AppRouter.homeAdmin);
          break;
        case 1:
          context.go(AppRouter.adminActions);
          break;
        case 2:
          context.go(AppRouter.myAccount);
          break;
      }
    } else if (isSoporte) {
      switch (index) {
        case 0:
          context.go(AppRouter.homeSupport);
          break;
        case 1:
          context.go(AppRouter.myAccount);
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go(AppRouter.homeUser);
          break;
        case 1:
          context.go(AppRouter.myAccount);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.hasRole(UserRole.administrador.name);
    final isSoporte = authProvider.hasRole(UserRole.soporteTecnico.name);

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, _) {
        return Scaffold(
          body: Stack(
            children: [
              widget.child,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  child: SlidingClippedNavBar(
                    inactiveColor: AppColors.primaryColor,
                    backgroundColor: Colors.white,
                    onButtonPressed: (index) {
                      navigationProvider.setIndex(index);
                      _navigateToIndex(index, isAdmin, isSoporte);
                    },
                    iconSize: 30,
                    activeColor: AppColors.primaryColor,
                    selectedIndex: navigationProvider.currentIndex,
                    barItems: isAdmin
                        ? [
                            BarItem(icon: Icons.home, title: 'Inicio'),
                            BarItem(
                              icon: Icons.admin_panel_settings,
                              title: 'Acciones',
                            ),
                            BarItem(icon: Icons.person, title: 'Mi cuenta'),
                          ]
                        : [
                            BarItem(icon: Icons.home, title: 'Inicio'),
                            BarItem(icon: Icons.person, title: 'Mi cuenta'),
                          ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
