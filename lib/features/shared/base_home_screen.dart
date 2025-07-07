import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/features/user/presentation/widgets/widget.dart';
import 'package:app_reporte_iestp_sullana/services/realtime_notification_service.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BaseHomeScreen extends StatelessWidget {
  final UserRole userRole;

  const BaseHomeScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _BaseHomeView(userRole: userRole));
  }
}

class _BaseHomeView extends StatefulWidget {
  final UserRole userRole;

  const _BaseHomeView({required this.userRole});

  @override
  State<_BaseHomeView> createState() => _BaseHomeViewState();
}

class _BaseHomeViewState extends State<_BaseHomeView> {
  @override
  void initState() {
    super.initState();
    // Cargar datos de reportes para KPIs si es administrador
    if (widget.userRole == UserRole.administrador) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final adminProvider = Provider.of<AdminActionProvider>(
          context,
          listen: false,
        );
        adminProvider.loadReportes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UsuarioPublico? user = userProvider.user;
    final userName = user?.nombre ?? '';
    final firstName = userName.split(' ')[0];

    if (userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userProvider.error != null) {
      return Center(child: Text('Error: ${userProvider.error}'));
    }

    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    final menuActions = MenuActionsFactory.getActionsForRole(
      context,
      widget.userRole,
    );
    final title = MenuActionsFactory.getTitleForRole(widget.userRole);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.defaultPadding * 1.5),
          child: Column(
            children: [
              // Header con información del usuario
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: user.avatarUrl.isNotEmpty
                        ? NetworkImage(user.avatarUrl)
                        : null,
                    child: user.avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 35)
                        : null,
                  ),
                  SizedBox(width: AppSize.defaultPaddingHorizontal * 0.69),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName
                              .split(' ')
                              .map(
                                (word) =>
                                    word.substring(0, 1).toUpperCase() +
                                    word.substring(1).toLowerCase(),
                              )
                              .join(' '),
                          style: AppStyles.h3p5(
                            color: AppColors.darkColor,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getRoleDisplayName(widget.userRole),
                          style: AppStyles.h4(
                            color: AppColors.darkColor50,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push(AppRouter.settings),
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              SizedBox(height: AppSize.defaultPadding * 1.25),

              // Banner (solo si no es cuenta pendiente)
              if (widget.userRole != UserRole.pendiente) ...[
                Container(
                  width: double.infinity,
                  height: 146.h,
                  margin: EdgeInsets.symmetric(
                    vertical: AppSize.defaultPadding,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppSize.defaultRadius * 1.5,
                    ),
                    child: Image.asset(
                      AppAssets.banner,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text('Error al cargar la imagen'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: AppSize.defaultPadding * 1.5),
              ],

              // Primer título
              Row(
                children: [
                  SizedBox(width: AppSize.defaultPaddingHorizontal * 0.2),
                  Text(
                    title,
                    style: AppStyles.h3p5(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.defaultPadding * 1.5),

              // KPIs (solo para admin)
              if (MenuActionsFactory.shouldShowKPIs(widget.userRole)) ...[
                _buildReportsKPIs(),
                SizedBox(height: AppSize.defaultPadding * 2),
              ],

              // Segundo título (solo para admin)
              if (MenuActionsFactory.getSecondaryTitleForRole(
                    widget.userRole,
                  ) !=
                  null) ...[
                Row(
                  children: [
                    SizedBox(width: AppSize.defaultPaddingHorizontal * 0.2),
                    Text(
                      MenuActionsFactory.getSecondaryTitleForRole(
                        widget.userRole,
                      )!,
                      style: AppStyles.h3p5(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.defaultPadding * 1.5),
              ],

              // Grid de acciones
              _buildActionGrid(menuActions),

              SizedBox(height: AppSize.defaultPadding * 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsKPIs() {
    return Consumer<AdminActionProvider>(
      builder: (context, adminProvider, child) {
        // Si los datos están cargando, mostrar un indicador
        if (adminProvider.isLoading) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Obtener las estadísticas actuales
        final kpiData = adminProvider.getReportsStatistics();

        return ReportsStatsRow(
          resueltos: kpiData['resueltos']!,
          sinAtender: kpiData['sinAtender']!,
          enProceso: kpiData['enProceso']!,
          enEspera: kpiData['enEspera']!,
        );
      },
    );
  }

  Widget _buildActionGrid(List<MenuAction> menuActions) {
    final visibleActions = menuActions
        .where((action) => action.isVisible)
        .toList();

    return Center(
      child: Wrap(
        spacing: AppSize.defaultPaddingHorizontal,
        runSpacing: AppSize.defaultPadding,
        alignment: WrapAlignment.center,
        children: visibleActions
            .map(
              (action) => ActionCard(
                icon: action.icon,
                label: action.label,
                onTap: action.onTap,
              ),
            )
            .toList(),
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.soporteTecnico:
        return 'Soporte Técnico';
      case UserRole.usuario:
        return 'Usuario';
      case UserRole.pendiente:
        return 'Cuenta Pendiente';
    }
  }
}
