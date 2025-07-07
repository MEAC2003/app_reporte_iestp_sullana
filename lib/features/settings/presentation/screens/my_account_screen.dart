import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/widgets/widgets.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _ConfigView());
  }
}

class _ConfigView extends StatefulWidget {
  @override
  State<_ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<_ConfigView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UsuarioPublico? user = userProvider.user;
    // Handle loading and error states
    if (userProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (userProvider.error != null) {
      return Center(child: Text('Error: ${userProvider.error}'));
    }

    // If user is null, show a message
    if (user == null) {
      return Center(child: Text('No user data available'));
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.defaultPadding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          user.nombre
                              .split(' ')
                              .map(
                                (word) =>
                                    word.substring(0, 1).toUpperCase() +
                                    word.substring(1).toLowerCase(),
                              )
                              .join(' '),
                          style: AppStyles.h3p5(
                            color: AppColors.darkColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
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
              SizedBox(height: AppSize.defaultPadding * 2),
              Text(
                'Datos del usuario',
                style: AppStyles.h4(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding * 1.5),
              UserInfoRow(title: 'Nombre', text: user.nombre),
              UserInfoRow(title: 'Correo electrónico', text: user.correo),
              SizedBox(height: AppSize.defaultPadding * 4),
            ],
          ),
        ),
      ),
    );
  }
}
