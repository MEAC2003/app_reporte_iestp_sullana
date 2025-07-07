import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:flutter/material.dart';

class HomeSupportScreen extends StatelessWidget {
  const HomeSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseHomeScreen(userRole: UserRole.soporteTecnico);
  }
}
