import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/user/presentation/widgets/widget.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeUserScreen extends StatelessWidget {
  const HomeUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: _HomeUserView());
  }
}

class _HomeUserView extends StatefulWidget {
  const _HomeUserView();

  @override
  State<_HomeUserView> createState() => _HomeUserViewState();
}

class _HomeUserViewState extends State<_HomeUserView> {
  @override
  void initState() {
    super.initState();
    // Load stats when screen initializes
    // Future.microtask(
    //     () => context.read<DashboardProvider>().loadProductStats());
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

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.defaultPadding * 1.5),
          child: Column(
            children: [
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
                        Row(
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
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              user.rol == 'admin' ? 'Administrador' : 'Usuario',
                              style: AppStyles.h4(
                                color: AppColors.darkColor50,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => (context.push(AppRouter.settings)),
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              SizedBox(height: AppSize.defaultPadding * 1.25),
              Container(
                width: double.infinity,
                height: 146.h,
                margin: EdgeInsets.symmetric(vertical: AppSize.defaultPadding),
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
              SizedBox(height: AppSize.defaultPadding * 2),
              Row(
                children: [
                  // const Icon(Icons.menu, size: 30),
                  SizedBox(width: AppSize.defaultPaddingHorizontal * 0.2),
                  Text(
                    'Menú Principal',
                    style: AppStyles.h3p5(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.defaultPadding * 1.5),
              Center(
                // Centra el contenido del Wrap horizontalmente
                child: Wrap(
                  spacing: AppSize
                      .defaultPaddingHorizontal, // Espacio horizontal entre tarjetas
                  runSpacing: AppSize
                      .defaultPadding, // Espacio vertical entre filas de tarjetas
                  alignment:
                      WrapAlignment.center, // Centra las tarjetas en cada línea
                  children: [
                    ActionCard(
                      icon: Icons.person,
                      label: 'Datos del Usuario',
                      onTap: () => context.push(AppRouter.myAccount),
                    ),
                    SizedBox(height: AppSize.defaultPadding * 0.5),
                    ActionCard(
                      icon: Icons.report,
                      label: 'Nuevo reporte',
                      onTap: () => context.push(AppRouter.home),
                    ),
                    SizedBox(height: AppSize.defaultPadding * 0.5),
                    ActionCard(
                      icon: Icons.history,
                      label: 'H. de reportes',
                      onTap: () => context.push(AppRouter.home),
                    ),
                  ],
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     QuickAction(
              //       label: 'Productos',
              //       icon: Icons.grid_view,
              //       onTap: () => context.push(AppRouter.adminViewProduct),
              //     ),
              //     QuickAction(
              //       label: 'Nuevo producto',
              //       icon: Icons.group_add,
              //       onTap: () => context.push(AppRouter.adminAddProduct),
              //     ),
              //     QuickAction(
              //       label: 'Nuevo proveedor',
              //       icon: Icons.groups,
              //       onTap: () => context.push(AppRouter.adminAddSupplier),
              //     ),
              //     QuickAction(
              //       label: 'Roles',
              //       icon: Icons.manage_accounts,
              //       onTap: () => context.push(AppRouter.adminRoles),
              //     ),
              //   ],
              // ),
              // SizedBox(height: AppSize.defaultPadding * 2),
              // Row(
              //   children: [
              //     const Icon(Icons.graphic_eq),
              //     SizedBox(width: AppSize.defaultPaddingHorizontal * 0.2),
              //     Text(
              //       'Egresos mensuales',
              //       style: AppStyles.h3(
              //         fontWeight: FontWeight.w700,
              //         color: AppColors.darkColor,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
