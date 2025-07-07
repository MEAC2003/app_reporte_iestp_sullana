import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final String id;
  final String description;
  final String date;
  final String? imageUrl;
  final Color statusColor;
  final VoidCallback? onDetalle;
  final VoidCallback? onCancelar;

  const ReportCard({
    super.key,
    required this.id,
    required this.description,
    required this.date,
    this.imageUrl,
    this.statusColor = Colors.blue,
    this.onDetalle,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  width: 80.w,
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

            // Footer con fecha y botones
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fecha: $date',
                    style: AppStyles.h5(
                      color: AppColors.darkColor50,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: AppSize.defaultPaddingHorizontal * 0.5),

                // Botones
                ElevatedButton(
                  onPressed: onDetalle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySkyBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    minimumSize: const Size(70, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSize.defaultRadius * 0.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Detalle',
                    style: AppStyles.h5(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: AppSize.defaultPaddingHorizontal * 0.5),
                ElevatedButton(
                  onPressed: onCancelar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: const Size(70, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSize.defaultRadius * 0.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: AppStyles.h5(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
}
