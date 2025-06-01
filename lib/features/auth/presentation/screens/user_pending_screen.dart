import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserPendingScreen extends StatelessWidget {
  const UserPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primarySkyBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícono
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      padding: const EdgeInsets.all(20),
                      // ignore: prefer_const_constructors
                      child: Icon(
                        Icons.access_time_filled,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Mensaje principal
                    Text(
                      "¡Estamos procesando tu registro!",
                      textAlign: TextAlign.center,
                      style: AppStyles.h2(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Mensaje secundario
                    Text(
                      "Gracias por registrarte. Cierra sesión y vuelve más tarde para verificar el estado de tu cuenta.",
                      textAlign: TextAlign.center,
                      style: AppStyles.h4(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).signOut();
                        context.go(AppRouter.signIn);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        "Cerrar sesión",
                        style: AppStyles.h4(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
