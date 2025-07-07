import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';

class AdminEstadoManagement extends StatelessWidget {
  final String estadoActual;
  final Color estadoColor;
  final VoidCallback onCambiarEstado;
  final bool puedeModificar;

  const AdminEstadoManagement({
    super.key,
    required this.estadoActual,
    required this.estadoColor,
    required this.onCambiarEstado,
    required this.puedeModificar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado actual
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
          decoration: BoxDecoration(
            color: estadoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: estadoColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
                decoration: BoxDecoration(
                  color: estadoColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assignment, color: Colors.white, size: 20),
              ),
              SizedBox(width: AppSize.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado Actual:',
                      style: AppStyles.h5(
                        color: AppColors.darkColor50,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppSize.defaultPadding * 0.25),
                    Text(
                      estadoActual,
                      style: AppStyles.h4(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: AppSize.defaultPadding),

        // Botón para cambiar estado
        if (puedeModificar) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCambiarEstado,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Actualizar Estado del Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: AppSize.defaultPadding * 0.75,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSize.defaultPadding * 0.5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Expanded(
                  child: Text(
                    'Actualiza el estado según el progreso del trabajo realizado.',
                    style: AppStyles.h5(color: Colors.blue),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, color: Colors.orange, size: 16),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Expanded(
                  child: Text(
                    'No se puede modificar el estado del ticket (estado: $estadoActual)',
                    style: AppStyles.h5(color: Colors.orange),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
