import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/widgets/widgets.dart';
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

  Future<void> _handleGoogleSignIn({bool isSignUp = false}) async {
    // Prevenir múltiples clics
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.signInWithGoogle();

      if (!mounted) return;

      if (result.success) {
        // Navegación basada en el rol del usuario
        if (authProvider.hasRole(UserRole.administrador.name)) {
          context.go(AppRouter.homeAdmin);
        } else if (authProvider.hasRole(UserRole.pendiente.name)) {
          context.go(AppRouter.userPending);
        } else if (authProvider.hasRole(UserRole.usuario.name)) {
          context.go(AppRouter.homeUser);
        } else if (authProvider.hasRole(UserRole.soporteTecnico.name)) {
          context.go(AppRouter.homeSupport);
        } else {
          context.go(AppRouter.home);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.error ?? 'Error de autenticación con Google',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Métodos auxiliares síncronos que no retornan null
  void _handleSignIn() {
    if (!_isLoading) {
      _handleGoogleSignIn();
    }
  }

  void _handleSignUp() {
    if (!_isLoading) {
      _handleGoogleSignIn(isSignUp: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
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
                  // Crear botones condicionales con opacidad
                  Opacity(
                    opacity: _isLoading ? 0.5 : 1.0,
                    child: SocialMediaButton(
                      imgPath: AppAssets.googleIcon,
                      text: ' Iniciar sesión con Google',
                      onPressed: _handleSignIn,
                    ),
                  ),
                  SizedBox(height: AppSize.defaultPadding * 0.5),
                  const OrAccess(),
                  SizedBox(height: AppSize.defaultPadding * 0.5),
                  Opacity(
                    opacity: _isLoading ? 0.5 : 1.0,
                    child: SocialMediaButton(
                      imgPath: AppAssets.googleIcon,
                      text: ' Crear cuenta con Google',
                      onPressed: _handleSignUp,
                    ),
                  ),
                  SizedBox(height: AppSize.defaultPadding * 2),
                ],
              ),
            ),
          ),
          // Overlay de carga que bloquea toda la pantalla
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Autenticando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
