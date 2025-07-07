import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:app_reporte_iestp_sullana/features/user/presentation/providers/user_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/reporte_incidencia.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserDetailReportScreen extends StatelessWidget {
  final String productId;
  const UserDetailReportScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.defaultPaddingHorizontal * 1.5.w,
          ),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.darkColor),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Detalle del Reporte',
          style: AppStyles.h3p5(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _UserDetailReportView(productId: productId),
    );
  }
}

class _UserDetailReportView extends StatefulWidget {
  final String productId;
  const _UserDetailReportView({required this.productId});

  @override
  State<_UserDetailReportView> createState() => _UserDetailReportViewState();
}

class _UserDetailReportViewState extends State<_UserDetailReportView> {
  ReporteIncidencia? reporte;
  DetalleReporte? detalleReporte;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReporteDetail();
    });
  }

  Future<void> _loadReporteDetail() async {
    try {
      final provider = context.read<UserActionProvider>();
      final userProvider = context.read<UserProvider>();

      await provider.loadUserReports(userProvider.user!.id);
      await userProvider.getUsers();
      await provider.loadUsuariosPublicos();

      final reporteData = await provider.getReporteById(widget.productId);
      final detalleData = await provider.getDetalleReporteByReporteId(
        widget.productId,
      );

      if (mounted) {
        setState(() {
          reporte = reporteData;
          detalleReporte = detalleData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Error al cargar el reporte: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: AppSize.defaultPadding),
            Text(
              'Cargando detalle...',
              style: AppStyles.h4(color: AppColors.darkColor50),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSize.defaultPadding * 1.5,
          ),
          padding: EdgeInsets.all(AppSize.defaultPadding * 1.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              SizedBox(height: AppSize.defaultPadding),
              Text(
                'Error al cargar',
                style: AppStyles.h3(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding * 0.5),
              Text(
                error!,
                style: AppStyles.h4(color: AppColors.darkColor50),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSize.defaultPadding),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    error = null;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadReporteDetail();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.defaultPadding * 1.5,
                    vertical: AppSize.defaultPadding * 0.75,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (reporte == null) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSize.defaultPadding * 1.5,
          ),
          padding: EdgeInsets.all(AppSize.defaultPadding * 1.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.darkColor50),
              SizedBox(height: AppSize.defaultPadding),
              Text(
                'No se encontró el reporte',
                style: AppStyles.h3(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer2<UserActionProvider, UserProvider>(
      builder: (context, provider, userProvider, child) {
        // Buscar datos relacionados
        String areaNombre = 'No disponible';
        String tipoReporteNombre = 'No disponible';
        String estadoReporteNombre = 'No disponible';
        String prioridadNombre = 'No disponible';
        String nombreUsuario = 'No disponible';
        Color estadoColor = AppColors.darkColor50;
        Color prioridadColor = AppColors.darkColor50;

        try {
          final area = provider.areas.firstWhere(
            (a) => a.id == reporte!.idArea,
          );
          areaNombre = area.nombre;
        } catch (e) {}

        try {
          final tipoReporte = provider.tiposReporte.firstWhere(
            (t) => t.id == reporte!.idTipoReporte,
          );
          tipoReporteNombre = tipoReporte.nombre;
        } catch (e) {}

        try {
          final estadoReporte = provider.estadosReporte.firstWhere(
            (e) => e.id == reporte!.idEstadoReporte,
          );
          estadoReporteNombre = estadoReporte.nombre;
          estadoColor = _getEstadoColor(estadoReporteNombre);
        } catch (e) {}

        try {
          final prioridad = provider.prioridades.firstWhere(
            (p) => p.id == reporte!.idPrioridad,
          );
          prioridadNombre = prioridad.nombre;
          prioridadColor = _getPrioridadColor(prioridadNombre);
        } catch (e) {}

        try {
          final usuarioReporte = userProvider.users.firstWhere(
            (u) => u.id == reporte!.idUsuario,
          );
          nombreUsuario = usuarioReporte.nombre;
        } catch (e) {}

        String nombreSoporteAsignado = provider.getNombreSoporteAsignado(
          detalleReporte?.idSoporteAsignado,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.defaultPadding * 1.5,
            vertical: AppSize.defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card con ID y Estado
              HeaderCard(
                reporteId: reporte!.id ?? widget.productId,
                estado: estadoReporteNombre,
                estadoColor: estadoColor,
                fechaCreacion: reporte!.createdAt,
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Imagen del reporte
              if (reporte!.urlImg.isNotEmpty) ...[
                ImageCard(imageUrl: reporte!.urlImg),
                SizedBox(height: AppSize.defaultPadding),
              ],

              // Información Principal
              InfoCard(
                title: 'Información Principal',
                icon: Icons.info_outline,
                children: [
                  InfoRow(
                    icon: Icons.person_outline,
                    label: 'Docente',
                    value: nombreUsuario,
                  ),
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Área',
                    value: areaNombre,
                  ),
                  InfoRow(
                    icon: Icons.category_outlined,
                    label: 'Tipo de Reporte',
                    value: tipoReporteNombre,
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Descripción
              InfoCard(
                title: 'Descripción',
                icon: Icons.description_outlined,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reporte!.descripcion,
                      style: AppStyles.h4(color: AppColors.darkColor),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Estado y Prioridad
              InfoCard(
                title: 'Estado y Prioridad',
                icon: Icons.flag_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatusChip(
                          label: estadoReporteNombre,
                          color: estadoColor,
                          icon: Icons.radio_button_checked,
                        ),
                      ),
                      SizedBox(width: AppSize.defaultPadding * 0.5),
                      Expanded(
                        child: StatusChip(
                          label: prioridadNombre,
                          color: prioridadColor,
                          icon: Icons.priority_high,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Soporte Asignado
              InfoCard(
                title: 'Soporte Técnico',
                icon: Icons.support_agent_outlined,
                children: [SoporteInfo(nombreSoporte: nombreSoporteAsignado)],
              ),

              SizedBox(height: AppSize.defaultPadding * 2),
            ],
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return AppColors.darkColor50;
    }
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return AppColors.darkColor50;
    }
  }
}
