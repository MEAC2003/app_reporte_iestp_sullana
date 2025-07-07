import 'package:app_reporte_iestp_sullana/features/support/presentation/providers/support_provider.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';

class SupportTicketCard extends StatelessWidget {
  final dynamic ticket;
  final SupportProvider provider;
  final VoidCallback onTap;

  const SupportTicketCard({
    super.key,
    required this.ticket,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final areaNombre = provider.areasMap[ticket.idArea] ?? 'Sin área';
    final prioridadNombre =
        provider.prioridadesMap[ticket.idPrioridad] ?? 'Sin prioridad';
    final estadoNombre =
        provider.estadosMap[ticket.idEstadoReporte] ?? 'Sin estado';
    final usuarioNombre =
        provider.usuariosMap[ticket.idUsuario] ?? 'Sin usuario';
    final tipoReporteNombre =
        provider.tiposReporteMap[ticket.idTipoReporte] ?? 'Sin tipo';

    return Container(
      margin: EdgeInsets.only(
        bottom: AppSize.defaultPadding,
        right: AppSize.defaultPadding,
        left: AppSize.defaultPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSize.defaultRadius),
        child: Padding(
          padding: EdgeInsets.all(AppSize.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado y prioridad
              Row(
                children: [
                  // Estado
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.defaultPadding * 0.75,
                      vertical: AppSize.defaultPadding * 0.25,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(estadoNombre),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      estadoNombre,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.h5(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Prioridad
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.defaultPadding * 0.75,
                      vertical: AppSize.defaultPadding * 0.25,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                        prioridadNombre,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getPriorityColor(
                          prioridadNombre,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.priority_high,
                          color: _getPriorityColor(prioridadNombre),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          prioridadNombre,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.h5(
                            color: _getPriorityColor(prioridadNombre),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Descripción
              Text(
                ticket.descripcion,
                style: AppStyles.h4(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: AppSize.defaultPadding * 0.75),

              // Información del ticket
              Column(
                children: [
                  // Usuario y área
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          usuarioNombre,
                          style: AppStyles.h5(color: AppColors.darkColor50),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSize.defaultPadding),
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 6),
                      Text(
                        areaNombre,
                        style: AppStyles.h5(color: AppColors.darkColor50),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSize.defaultPadding * 0.5),

                  // Tipo de reporte y fecha
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tipoReporteNombre,
                          style: AppStyles.h5(color: AppColors.darkColor50),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSize.defaultPadding),
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        _formatDate(ticket.createdAt),
                        style: AppStyles.h5(color: AppColors.darkColor50),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Botón de ver detalle
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: Icon(Icons.visibility, size: 18),
                  label: Text('Ver Detalle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: AppSize.defaultPadding * 0.75,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSize.defaultRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('nuevo')) return Colors.blue;
    if (statusLower.contains('asignado')) return Colors.orange;
    if (statusLower.contains('proceso')) return Colors.purple;
    if (statusLower.contains('espera')) return Colors.amber;
    if (statusLower.contains('resuelto')) return Colors.green;
    return Colors.grey;
  }

  Color _getPriorityColor(String priority) {
    final priorityLower = priority.toLowerCase();
    if (priorityLower.contains('alta')) return Colors.red;
    if (priorityLower.contains('media')) return Colors.orange;
    if (priorityLower.contains('baja')) return Colors.green;
    return Colors.grey;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Sin fecha';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
