import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/user/presentation/providers/user_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/user/presentation/widgets/widget.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ReportHistoryScreen extends StatelessWidget {
  const ReportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.defaultPaddingHorizontal * 1.5.w,
          ),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Historial de Reportes',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const _ReportHistoryView(),
    );
  }
}

class _ReportHistoryView extends StatefulWidget {
  const _ReportHistoryView();

  @override
  State<_ReportHistoryView> createState() => _ReportHistoryViewState();
}

class _ReportHistoryViewState extends State<_ReportHistoryView> {
  @override
  void initState() {
    super.initState();
    // Cargar los datos cuando se inicializa la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final userActionProvider = context.read<UserActionProvider>();

      // Obtener el ID del usuario actual
      final currentUserId = authProvider.currentUser?.id;

      if (currentUserId != null) {
        // Cargar los reportes específicos del usuario
        userActionProvider.loadUserReports(currentUserId);
      } else {
        // Si no hay usuario logueado, solo cargar datos iniciales
        userActionProvider.loadInitialData();
      }
    });
  }

  Color _getStatusColor(String estadoReporteId) {
    // Mapeo de los IDs de estado a colores
    switch (estadoReporteId) {
      case "29e11cdf-fcf7-4c36-a7fd-f363dcaf864c": // Nuevo
        return Colors.blue;
      case "60af230d-a751-4dbe-9ecb-b101ffcb828b": // Asignado
        return Colors.orange;
      case "cb56bfbe-6fd4-4d0b-ad5b-3bb31194e223": // En proceso
        return Colors.yellow;
      case "afab4980-5c12-4457-88a2-c3cd0bb198e1": // En espera
        return Colors.purple;
      case "52c2b7bc-194c-4759-b83c-3913625da86d": // Resuelto
        return Colors.green;
      case "d2d0cc74-0a47-4626-9571-adc8c07a8be0": // Cerrado
        return Colors.grey;
      case "1d7db7fb-5bbe-4c5a-a24e-2930fdc8289e": // Cancelado
        return Colors.red;
      default:
        return Colors.blue;
    }
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

  // Verificar si el reporte se puede cancelar
  bool _canCancelReport(String estadoReporteId) {
    // Solo se puede cancelar si está en estado "Nuevo" o "Asignado"
    return estadoReporteId == "29e11cdf-fcf7-4c36-a7fd-f363dcaf864c" || // Nuevo
        estadoReporteId == "60af230d-a751-4dbe-9ecb-b101ffcb828b"; // Asignado
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserActionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.reportes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: AppSize.defaultPadding),
                Text(
                  'No hay reportes disponibles',
                  style: AppStyles.h4(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(AppSize.defaultPadding),
          child: RefreshIndicator(
            onRefresh: () async {
              final authProvider = context.read<AuthProvider>();
              final currentUserId = authProvider.currentUser?.id;

              if (currentUserId != null) {
                // Refrescar los reportes del usuario específico
                await provider.loadUserReports(currentUserId);
              } else {
                await provider.loadInitialData();
              }
            },
            child: ListView.builder(
              itemCount: provider.reportes.length,
              itemBuilder: (context, index) {
                final reporte = provider.reportes[index];
                final canCancel = _canCancelReport(reporte.idEstadoReporte);

                return Padding(
                  padding: EdgeInsets.only(bottom: AppSize.defaultPadding),
                  child: ReportCard(
                    id: reporte.id ?? 'Sin ID',
                    imageUrl: reporte.urlImg,
                    description: reporte.descripcion,
                    date: _formatDate(reporte.createdAt),
                    statusColor: _getStatusColor(reporte.idEstadoReporte),
                    onDetalle: () {
                      // Navegar a la pantalla de detalles
                      context.push('${AppRouter.reportDetail}/${reporte.id}');
                    },
                    onCancelar: canCancel
                        ? () => _showCancelDialog(
                            context,
                            reporte.id ?? '',
                            provider,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Método separado y seguro para cancelar reporte
  Future<void> _cancelReporte(
    String reporteId,
    UserActionProvider provider,
  ) async {
    try {
      final reporte = await provider.getReporteById(reporteId);
      final reporteActualizado = reporte.copyWith(
        idEstadoReporte: "1d7db7fb-5bbe-4c5a-a24e-2930fdc8289e", // Cancelado
      );
      await provider.updateReporte(reporteActualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte cancelado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cancelar el reporte: $e')),
        );
      }
    }
  }

  void _showCancelDialog(
    BuildContext context,
    String reporteId,
    UserActionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar Reporte'),
          content: const Text(
            '¿Estás seguro de que deseas cancelar este reporte?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _cancelReporte(reporteId, provider);
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }
}
