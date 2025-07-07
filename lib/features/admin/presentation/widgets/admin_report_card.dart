import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';

class AdminReportCard extends StatelessWidget {
  final String id;
  final String description;
  final String date;
  final String? imageUrl;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const AdminReportCard({
    super.key,
    required this.id,
    required this.description,
    required this.date,
    this.imageUrl,
    required this.status,
    this.statusColor = Colors.blue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSize.defaultPadding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Id-reporte: $id',
                      style: AppStyles.h5(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.defaultPadding),

              // Contenido principal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  Container(
                    width: 100.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primaryGrey,
                    ),
                    child: imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSize.defaultRadius * 0.5,
                            ),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            ),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  SizedBox(width: AppSize.defaultPaddingHorizontal * 0.69),

                  // Descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descripción:',
                          style: AppStyles.h4(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkColor,
                          ),
                        ),
                        SizedBox(height: AppSize.defaultPadding * 0.2),
                        Text(
                          description,
                          style: AppStyles.h5(color: AppColors.darkColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.defaultPadding * 0.5),

              // Footer con fecha y estado - CENTRADO
              // ...existing code...

              // Footer con fecha y estado - Solo cambiar esta sección
              Row(
                children: [
                  // Fecha - CON EXPANDED PARA EVITAR OVERFLOW
                  Expanded(
                    child: Text(
                      'Fecha: $date',
                      style: AppStyles.h5(
                        color: AppColors.darkColor50,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(width: AppSize.defaultPaddingHorizontal * 0.5),

                  // Estado del reporte - CENTRADO EN SU ESPACIO
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 100, // TAMAÑO FIJO
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppSize.defaultRadius * 1.5,
                          ),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: AppStyles.h5(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.computer, color: Colors.grey, size: 30),
    );
  }

  // Método helper para obtener el color según el estado
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'nuevo':
        return Colors.blue;
      case 'en proceso':
        return Colors.orange;
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Método helper para obtener el texto del estado
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'nuevo':
        return 'NUEVO';
      case 'en proceso':
        return 'EN PROCESO';
      case 'completado':
        return 'COMPLETADO';
      case 'cancelado':
        return 'CANCELADO';
      default:
        return 'DESCONOCIDO';
    }
  }
}
