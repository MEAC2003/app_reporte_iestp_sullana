import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/widgets/widgets.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: _SignInView());
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  _SignInViewState createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      child: const Text('¿Olvidaste tu contraseña?'),
      onPressed: () async {
        final email = _emailController.text;
        if (email.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa tu email')),
          );
          return;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: AppSize.defaultPadding * 5),
            Image.asset(AppAssets.logo, width: 120.w),
            SizedBox(height: AppSize.defaultPadding),
            Text(
              'Bienvenido',
              style: AppStyles.h1(
                color: AppColors.darkColor,
                fontWeight: FontWeight.w900,
              ).copyWith(letterSpacing: -1.5),
            ),
            SizedBox(height: AppSize.defaultPadding * 0.5),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.defaultPaddingHorizontal * 2,
              ),
              child: Text(
                'Reporta fallos técnicos y colabora con el equipo de soporte para una solución rápida.',
                style: AppStyles.h3(
                  color: AppColors.darkColor50,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSize.defaultPadding * 4),
            SocialMediaButton(
              imgPath: AppAssets.googleIcon,
              text: ' Iniciar sesión con Google',
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                final result = await authProvider.signInWithGoogle();

                //implementar esto if (authProvider.isAuthenticated &&
                //     authProvider.hasRole(UserRole.admin.name)) {
                //   initialLocation = dashboard;
                // } else if (authProvider.isAuthenticated &&
                //     authProvider.hasRole(UserRole.pending.name)) {
                //   initialLocation = userPending;
                // } else if (authProvider.isAuthenticated &&
                //     authProvider.hasRole(UserRole.user.name)) {
                //   initialLocation = home;
                // } else {
                //   initialLocation =
                //       home; // Por defecto, envía a "home" si no se cumplen condiciones previas
                // }
                if (result.success) {
                  if (authProvider.hasRole(UserRole.administrador.name)) {
                    context.go(AppRouter.home);
                  } else if (authProvider.hasRole(UserRole.pendiente.name)) {
                    context.go(AppRouter.userPending);
                  } else if (authProvider.hasRole(UserRole.usuario.name)) {
                    context.go(AppRouter.homeUser);
                  } else {
                    context.go(AppRouter.home);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.error ?? 'Error de autenticación con Google',
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: AppSize.defaultPadding * 0.5),
            const OrAccess(),
            SizedBox(height: AppSize.defaultPadding * 0.5),
            CustomCTAButton(
              text: 'Crear cuenta',
              onPressed: () => context.go(AppRouter.signUp),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
