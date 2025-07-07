import 'package:app_reporte_iestp_sullana/features/admin/data/models/adjuntar_archivo_requerimiento.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/widgets/widget.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/reporte_incidencia.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminDetailReportScreen extends StatelessWidget {
  final String reportId;
  const AdminDetailReportScreen({super.key, required this.reportId});

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
      body: _AdminDetailReportView(productId: reportId),
    );
  }
}

class _AdminDetailReportView extends StatefulWidget {
  final String productId;
  const _AdminDetailReportView({required this.productId});

  @override
  State<_AdminDetailReportView> createState() => _AdminDetailReportViewState();
}

class _AdminDetailReportViewState extends State<_AdminDetailReportView> {
  ReporteIncidencia? reporte;
  DetalleReporte? detalleReporte;
  bool isLoading = true;
  String? error;

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  final TextEditingController _repuestosController = TextEditingController();
  final TextEditingController _justificacionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReporteDetail();
    });
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _observacionesController.dispose();
    _repuestosController.dispose();
    _justificacionController.dispose();
    super.dispose();
  }

  // Método para guardar información técnica como admin
  Future<void> _guardarInformacionTecnica() async {
    if (reporte == null || !mounted) return;

    // Mostrar diálogo de confirmación
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppColors.primaryColor),
            SizedBox(width: AppSize.defaultPadding * 0.5),
            Text(
              'Guardar Como Administrador',
              style: AppStyles.h4(
                color: AppColors.darkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Como administrador, puedes editar la información técnica del reporte.\n\n'
          '¿Deseas guardar los cambios realizados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmacion != true || !mounted) return;

    // Variable para controlar el diálogo de loading
    bool loadingDialogShown = false;

    try {
      // Mostrar loading solo si el widget está montado
      if (mounted) {
        loadingDialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: AppSize.defaultPadding),
                Text('Guardando información técnica...'),
              ],
            ),
          ),
        );
      }

      final provider = context.read<AdminActionProvider>();

      final success = await provider.actualizarInformacionTecnica(
        reporteId: reporte!.id!,
        descripcion: _descripcionController.text.trim(),
        observaciones: _observacionesController.text.trim(),
        repuestosRequeridos: _repuestosController.text.trim(),
        justificacionRepuestos: _justificacionController.text.trim(),
      );

      // Verificar que el widget esté montado antes de usar context
      if (!mounted) return;

      // Cerrar loading si fue mostrado
      if (loadingDialogShown) {
        Navigator.pop(context);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Expanded(
                  child: Text(
                    'Información técnica guardada correctamente',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        if (mounted) {
          await _refreshData();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Text('Error al guardar la información técnica'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Verificar que el widget esté montado antes de usar context en catch
      if (!mounted) return;

      // Cerrar loading si fue mostrado
      if (loadingDialogShown) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cambiarEstadoReporte() async {
    if (reporte == null) return;

    final provider = context.read<AdminActionProvider>();

    // Obtener estados disponibles
    final estadosDisponibles = provider.estadosReporte.toList();

    if (estadosDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay estados disponibles para cambiar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar diálogo usando el mismo estilo que el soporte
    _mostrarDialogoCambiarEstado(provider, estadosDisponibles);
  }

  // Método para mostrar el diálogo usando el mismo estilo del soporte
  void _mostrarDialogoCambiarEstado(
    AdminActionProvider provider,
    List<dynamic> estadosDisponibles,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_outlined, color: Colors.blue),
            SizedBox(width: AppSize.defaultPadding * 0.5),
            Text('Actualizar Estado'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: estadosDisponibles.length,
            itemBuilder: (context, index) {
              final estado = estadosDisponibles[index];
              final isCurrentState = estado.id == reporte!.idEstadoReporte;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                color: isCurrentState ? Colors.blue.withOpacity(0.1) : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getEstadoColor(estado.nombre),
                    child: Icon(
                      isCurrentState
                          ? Icons.check
                          : Icons.radio_button_unchecked,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    estado.nombre,
                    style: AppStyles.h5(
                      color: AppColors.darkColor,
                      fontWeight: isCurrentState
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: isCurrentState
                      ? Text(
                          'Estado actual',
                          style: AppStyles.h5(color: Colors.blue),
                        )
                      : null,
                  trailing: isCurrentState
                      ? Icon(Icons.check_circle, color: Colors.blue)
                      : Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                  onTap: isCurrentState
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await _cambiarEstado(estado.id);
                        },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  // Método para confirmar el cambio de estado (similar al del soporte)
  Future<void> _cambiarEstado(String nuevoEstadoId) async {
    if (reporte == null || !mounted) return;

    try {
      final provider = context.read<AdminActionProvider>();

      final success = await provider.cambiarEstadoReporte(
        reporteId: reporte!.id!,
        nuevoEstadoId: nuevoEstadoId,
      );

      // Verificar que el widget esté montado antes de usar context
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Expanded(
                  child: Text(
                    'Estado del reporte actualizado correctamente',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) {
          await _refreshData();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Text('Error al cambiar el estado del reporte'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Verificar que el widget esté montado antes de usar context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _generarRequerimientoPDF(AdminActionProvider provider) async {
    if (reporte == null) return;

    // NUEVA VALIDACIÓN: Verificar que los campos de repuestos estén completados
    final repuestosCompletos = _repuestosController.text.trim().isNotEmpty;
    final justificacionCompleta = _justificacionController.text
        .trim()
        .isNotEmpty;

    if (!repuestosCompletos || !justificacionCompleta) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange),
              SizedBox(width: AppSize.defaultPadding * 0.5),
              Text('Información Incompleta'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Para generar el requerimiento PDF, es necesario completar los siguientes campos:',
                style: AppStyles.h4(color: AppColors.darkColor),
              ),
              SizedBox(height: AppSize.defaultPadding),
              if (!repuestosCompletos)
                Row(
                  children: [
                    Icon(Icons.build_outlined, color: Colors.red, size: 20),
                    SizedBox(width: AppSize.defaultPadding * 0.5),
                    Text(
                      'Repuestos Requeridos',
                      style: AppStyles.h5(color: Colors.red),
                    ),
                  ],
                ),
              if (!justificacionCompleta) ...[
                SizedBox(height: AppSize.defaultPadding * 0.5),
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: AppSize.defaultPadding * 0.5),
                    Text(
                      'Justificación de Repuestos',
                      style: AppStyles.h5(color: Colors.red),
                    ),
                  ],
                ),
              ],
              SizedBox(height: AppSize.defaultPadding),
              Container(
                padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Text(
                  'Completa estos campos en la sección "Información Técnica del Soporte" y luego intenta generar el PDF nuevamente.',
                  style: AppStyles.h5(color: Colors.blue),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    // Si los campos están completos, proceder con la generación del PDF
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar Requerimiento PDF'),
        content: const Text(
          '¿Estás seguro de que deseas generar un requerimiento de repuestos para este reporte? '
          'Esto cambiará el estado del reporte a "En espera (Repuestos)" y enviará la solicitud al director.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generar PDF'),
          ),
        ],
      ),
    );

    // VERIFICACIÓN CRÍTICA: Si el usuario cancela o el widget no está montado
    if (confirmar != true || !mounted) return;

    // Variable para controlar el diálogo de loading
    bool loadingDialogShown = false;

    try {
      // Mostrar loading solo si el widget está montado
      if (mounted) {
        loadingDialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: AppSize.defaultPadding),
                const Text('Generando PDF...'),
              ],
            ),
          ),
        );
      }

      // Ejecutar la operación asíncrona
      final success = await provider.generarRequerimientoPDF(
        reporteId: reporte!.id!,
      );

      // VERIFICACIÓN CRÍTICA antes de usar context
      if (!mounted) return;

      // Cerrar el diálogo de loading si fue mostrado
      if (loadingDialogShown) {
        Navigator.pop(context);
        loadingDialogShown = false;
      }

      // Mostrar resultado
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Requerimiento PDF generado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Solo refrescar si el widget está montado
        if (mounted) {
          await _refreshData();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al generar el requerimiento PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // VERIFICACIÓN CRÍTICA antes de usar context en catch
      if (!mounted) return;

      // Cerrar el diálogo de loading si fue mostrado
      if (loadingDialogShown) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadReporteDetail() async {
    try {
      final provider = context.read<AdminActionProvider>();
      final userProvider = context.read<UserProvider>();

      await provider.loadInitialData();
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

          // Llenar controladores con datos existentes
          if (detalleData != null) {
            _descripcionController.text = detalleData.descripcion ?? '';
            _observacionesController.text = detalleData.observaciones ?? '';
            _repuestosController.text = detalleData.repuestosRequeridos ?? '';
            _justificacionController.text =
                detalleData.justificacionRepuestos ?? '';
          }

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

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    await _loadReporteDetail();
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
                onPressed: _refreshData,
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

    return Consumer2<AdminActionProvider, UserProvider>(
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
        } catch (e) {
          print('Error finding area: $e');
        }

        try {
          final tipoReporte = provider.tiposReporte.firstWhere(
            (t) => t.id == reporte!.idTipoReporte,
          );
          tipoReporteNombre = tipoReporte.nombre;
        } catch (e) {
          print('Error finding tipoReporte: $e');
        }

        try {
          final estadoReporte = provider.estadosReporte.firstWhere(
            (e) => e.id == reporte!.idEstadoReporte,
          );
          estadoReporteNombre = estadoReporte.nombre;
          estadoColor = _getEstadoColor(estadoReporteNombre);
          print('Estado encontrado: $estadoReporteNombre');
        } catch (e) {
          print('Error finding estado reporte: $e');
          print('Buscando estado con ID: ${reporte!.idEstadoReporte}');
          print(
            'Estados disponibles: ${provider.estadosReporte.map((e) => '${e.id}: ${e.nombre}').toList()}',
          );
        }

        try {
          final prioridad = provider.prioridades.firstWhere(
            (p) => p.id == reporte!.idPrioridad,
          );
          prioridadNombre = prioridad.nombre;
          prioridadColor = _getPrioridadColor(prioridadNombre);
        } catch (e) {
          print('Error finding prioridad: $e');
        }

        try {
          final usuarioReporte = userProvider.users.firstWhere(
            (u) => u.id == reporte!.idUsuario,
          );
          nombreUsuario = usuarioReporte.nombre;
        } catch (e) {
          print('Error finding usuario: $e');
        }

        String nombreSoporteAsignado = provider.getNombreSoporteAsignado(
          detalleReporte?.idSoporteAsignado,
        );

        // Verificar si el estado permite asignación
        bool puedeAsignarSoporte = _puedeModificarSoporte(estadoReporteNombre);
        print(
          '¿Puede asignar soporte? $puedeAsignarSoporte para estado: $estadoReporteNombre',
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
                fechaCreacion: reporte!.createdAt ?? '',
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
                  // Botón para cambiar estado como admin
                  SizedBox(height: AppSize.defaultPadding),
                  AdminEstadoManagement(
                    estadoActual: estadoReporteNombre,
                    estadoColor: estadoColor,
                    onCambiarEstado: _cambiarEstadoReporte,
                    puedeModificar: !estadoReporteNombre.toLowerCase().contains(
                      'cancelado',
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Soporte Asignado con funcionalidades de admin
              InfoCard(
                title: 'Gestión de Soporte Técnico',
                icon: Icons.support_agent_outlined,
                children: [
                  _AdminSoporteManagement(
                    nombreSoporte: nombreSoporteAsignado,
                    detalleReporte: detalleReporte,
                    usuariosPublicos: provider.usuariosPublicos,
                    puedeAsignar: puedeAsignarSoporte,
                    estadoReporte: estadoReporteNombre,
                    onAsignar: (soporteId) =>
                        _asignarSoporte(provider, soporteId),
                    onRefresh: _refreshData,
                    onGenerarPDF: () => _generarRequerimientoPDF(provider),
                    // PARÁMETROS PARA VALIDACIÓN DE PDF
                    repuestosController: _repuestosController,
                    justificacionController: _justificacionController,
                  ),
                ],
              ),
              SizedBox(height: AppSize.defaultPadding),

              // MODIFICADA: Información Técnica del Soporte (ahora editable para admin)
              if (!estadoReporteNombre.toLowerCase().contains('cancelado'))
                InfoCard(
                  title: 'Información Técnica del Soporte',
                  icon: Icons.engineering_outlined,
                  children: [
                    _AdminInformacionTecnicaWidget(
                      detalleReporte: detalleReporte,
                      nombreSoporte: nombreSoporteAsignado,
                      descripcionController: _descripcionController,
                      observacionesController: _observacionesController,
                      repuestosController: _repuestosController,
                      justificacionController: _justificacionController,
                      onGuardar: _guardarInformacionTecnica,
                      onRefresh: _refreshData,
                      estadoReporte: estadoReporteNombre,
                    ),
                  ],
                ),
              SizedBox(height: AppSize.defaultPadding),

              // Mostrar PDF generado si existe
              FutureBuilder<AdjuntarArchivoRequerimiento?>(
                future: context
                    .read<AdminActionProvider>()
                    .getArchivoRequerimientoByReporteId(widget.productId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return InfoCard(
                      title: 'Requerimiento PDF Generado',
                      icon: Icons.picture_as_pdf_outlined,
                      children: [
                        RequerimientoPDFWidget(
                          archivoRequerimiento: snapshot.data!,
                        ),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: AppSize.defaultPadding * 2),
            ],
          ),
        );
      },
    );
  }

  bool _puedeModificarSoporte(String estado) {
    // Si el estado es "No disponible", permitir modificación por defecto
    if (estado == 'No disponible') {
      print('Estado no disponible, permitiendo modificación por defecto');
      return true;
    }

    final estadosNoModificables = [
      'cancelado',
      'resuelto',
      'cerrado',
      'completado',
      'finalizado',
    ];

    final puedeModificar = !estadosNoModificables.any(
      (estadoNoMod) => estado.toLowerCase().contains(estadoNoMod),
    );

    print('Estado: $estado, Puede modificar: $puedeModificar');
    return puedeModificar;
  }

  Future<void> _asignarSoporte(
    AdminActionProvider provider,
    String soporteId,
  ) async {
    if (reporte == null || !mounted) return;

    // Variable para controlar el diálogo de loading
    bool loadingDialogShown = false;

    try {
      // Mostrar loading solo si el widget está montado
      if (mounted) {
        loadingDialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: AppSize.defaultPadding),
                Text('Asignando soporte técnico...'),
              ],
            ),
          ),
        );
      }

      // PASO 1: Asignar el soporte técnico
      final successAsignacion = await provider.asignarSoporte(
        reporteId: reporte!.id!,
        soporteId: soporteId,
      );

      if (!successAsignacion) {
        // Verificar que el widget esté montado antes de usar context
        if (!mounted) return;

        // Cerrar loading si fue mostrado
        if (loadingDialogShown) {
          Navigator.pop(context);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Text('Error al asignar soporte'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // PASO 2: Buscar el ID del estado "Asignado"
      String? estadoAsignadoId;
      try {
        final estadoAsignado = provider.estadosReporte.firstWhere(
          (estado) => estado.nombre.toLowerCase().contains('asignado'),
        );
        estadoAsignadoId = estadoAsignado.id;
        print('Estado "Asignado" encontrado con ID: $estadoAsignadoId');
      } catch (e) {
        print('No se encontró el estado "Asignado": $e');
        // Si no se encuentra, usar el ID exacto que conocemos
        estadoAsignadoId = "60af230d-a751-4dbe-9ecb-b101ffcb828b";
        print('Usando ID de estado "Asignado" por defecto: $estadoAsignadoId');
      }

      // PASO 3: Cambiar automáticamente el estado a "Asignado"
      final successEstado = await provider.cambiarEstadoReporte(
        reporteId: reporte!.id!,
        nuevoEstadoId: estadoAsignadoId,
      );

      // Verificar que el widget esté montado antes de usar context
      if (!mounted) return;

      // Cerrar loading si fue mostrado
      if (loadingDialogShown) {
        Navigator.pop(context);
      }

      // PASO 4: Mostrar resultado basado en el éxito de ambas operaciones
      if (successEstado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Expanded(
                  child: Text(
                    'Soporte asignado y estado actualizado a "Asignado"',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Expanded(
                  child: Text(
                    'Soporte asignado, pero no se pudo actualizar el estado automáticamente',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // PASO 5: Refrescar los datos para mostrar los cambios
      if (mounted) {
        await _refreshData();
      }
    } catch (e) {
      // Verificar que el widget esté montado antes de usar context en catch
      if (!mounted) return;

      // Cerrar loading si fue mostrado
      if (loadingDialogShown) {
        Navigator.pop(context);
      }

      print('Error en _asignarSoporte: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: AppSize.defaultPadding * 0.5),
              Expanded(
                child: Text(
                  'Error al asignar soporte: $e',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
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

// Widget para gestión de soporte del admin
class _AdminSoporteManagement extends StatelessWidget {
  final String nombreSoporte;
  final DetalleReporte? detalleReporte;
  final List<UsuarioPublico> usuariosPublicos;
  final bool puedeAsignar;
  final String estadoReporte;
  final Function(String) onAsignar;
  final Function() onRefresh;
  final Function() onGenerarPDF;
  final TextEditingController repuestosController;
  final TextEditingController justificacionController;

  const _AdminSoporteManagement({
    required this.nombreSoporte,
    required this.detalleReporte,
    required this.usuariosPublicos,
    required this.puedeAsignar,
    required this.estadoReporte,
    required this.onAsignar,
    required this.onRefresh,
    required this.onGenerarPDF,
    required this.repuestosController,
    required this.justificacionController,
  });

  // MAPEO AQUÍ
  static final Map<String, UserRole> _roleMapping = {
    '6cf8bda6-1726-495e-9c6a-917f474e1081': UserRole.pendiente,
    '3f685a86-8b62-4a8b-ac73-092a06bf7961': UserRole.usuario,
    'd761f72b-3a0f-4c4a-bcec-1ad5bd79b7e1': UserRole.administrador,
    'f0c11c95-a587-44ad-bd1f-3b6cfcf661cd': UserRole.soporteTecnico,
  };

  String _getMensajeNoAsignable() {
    if (estadoReporte == 'No disponible') {
      return 'Estado del reporte no disponible';
    }

    final estadoLower = estadoReporte.toLowerCase();

    if (estadoLower.contains('cancelado')) {
      return 'No se puede asignar soporte (reporte cancelado)';
    } else if (estadoLower.contains('resuelto')) {
      return 'No se puede modificar soporte (reporte resuelto)';
    } else if (estadoLower.contains('cerrado')) {
      return 'No se puede modificar soporte (reporte cerrado)';
    } else if (estadoLower.contains('completado')) {
      return 'No se puede modificar soporte (reporte completado)';
    } else {
      return 'No se puede modificar el soporte técnico (estado: $estadoReporte)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool tieneSoporte = nombreSoporte != 'Sin asignar';
    // NUEVA VALIDACIÓN PARA EL BOTÓN DE PDF
    final bool puedeGenerarPDF =
        tieneSoporte &&
        repuestosController.text.trim().isNotEmpty &&
        justificacionController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado actual del soporte
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
          decoration: BoxDecoration(
            color: tieneSoporte
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: tieneSoporte
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
                decoration: BoxDecoration(
                  color: tieneSoporte ? Colors.green : Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tieneSoporte ? Icons.person : Icons.person_off,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSize.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tieneSoporte ? 'Asignado a:' : 'Estado:',
                      style: AppStyles.h5(
                        color: AppColors.darkColor50,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppSize.defaultPadding * 0.25),
                    Text(
                      nombreSoporte,
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

        if (puedeAsignar) ...[
          SizedBox(height: AppSize.defaultPadding),
          // Botones de acción para admin
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarDialogoAsignar(context),
                  icon: Icon(
                    tieneSoporte ? Icons.swap_horiz : Icons.person_add,
                  ),
                  label: Text(tieneSoporte ? 'Reasignar' : 'Asignar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
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
            ],
          ),
          if (tieneSoporte) ...[
            SizedBox(height: AppSize.defaultPadding * 0.5),
            // BOTÓN DE PDF CON VALIDACIÓN MEJORADA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: puedeGenerarPDF
                    ? () => _generarRequerimientoPDF(context)
                    : null,
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: puedeGenerarPDF ? Colors.white : Colors.grey,
                ),
                label: Text(
                  'Generar Requerimiento PDF',
                  style: TextStyle(
                    color: puedeGenerarPDF ? Colors.white : Colors.grey,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: puedeGenerarPDF
                      ? Colors.orange
                      : Colors.grey[300],
                  disabledBackgroundColor: Colors.grey[300],
                  padding: EdgeInsets.symmetric(
                    vertical: AppSize.defaultPadding * 0.75,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // MENSAJE DE AYUDA PARA EL PDF
            if (!puedeGenerarPDF) ...[
              SizedBox(height: AppSize.defaultPadding * 0.5),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 16),
                    SizedBox(width: AppSize.defaultPadding * 0.5),
                    Expanded(
                      child: Text(
                        'Para generar el PDF, completa los campos "Repuestos Requeridos" y "Justificación de Repuestos" en la información técnica.',
                        style: AppStyles.h5(color: Colors.amber[700]),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ] else ...[
          SizedBox(height: AppSize.defaultPadding * 0.5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.block, color: Colors.red, size: 16),
                  SizedBox(width: AppSize.defaultPadding * 0.5),
                  Expanded(
                    child: Text(
                      _getMensajeNoAsignable(),
                      style: AppStyles.h5(color: Colors.red),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _generarRequerimientoPDF(BuildContext context) {
    // VALIDACIÓN MEJORADA ANTES DEL DIÁLOGO
    final bool repuestosCompletos = repuestosController.text.trim().isNotEmpty;
    final bool justificacionCompleta = justificacionController.text
        .trim()
        .isNotEmpty;

    if (!repuestosCompletos || !justificacionCompleta) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Completa los campos de repuestos requeridos y justificación antes de generar el PDF.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar Requerimiento PDF'),
        content: const Text(
          '¿Estás seguro de que deseas generar un requerimiento de repuestos para este reporte? '
          'Esto cambiará el estado del reporte a "En espera (Repuestos)" y enviará la solicitud al director.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onGenerarPDF();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generar PDF'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAsignar(BuildContext context) {
    // FILTRO PARA SOPORTE Y ADMIN
    final usuariosSoporte = usuariosPublicos.where((u) {
      final userRole = _roleMapping[u.rol];
      return userRole == UserRole.soporteTecnico ||
          userRole == UserRole.administrador;
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar Soporte Técnico'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: usuariosSoporte.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.support_agent_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay usuarios de soporte disponibles',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: usuariosSoporte.length,
                  itemBuilder: (context, index) {
                    final usuario = usuariosSoporte[index];
                    final isSelected =
                        detalleReporte?.idSoporteAsignado == usuario.id;
                    final userRole = _roleMapping[usuario.rol];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          backgroundImage:
                              usuario.avatarUrl != null &&
                                  usuario.avatarUrl!.isNotEmpty
                              ? NetworkImage(usuario.avatarUrl!)
                              : null,
                          child:
                              usuario.avatarUrl == null ||
                                  usuario.avatarUrl!.isEmpty
                              ? Text(
                                  usuario.nombre.isNotEmpty
                                      ? usuario.nombre
                                            .substring(0, 1)
                                            .toUpperCase()
                                      : 'S',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          usuario.nombre,
                          style: AppStyles.h5(
                            color: AppColors.darkColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(usuario.correo),
                            SizedBox(height: 2),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatRoleName(userRole),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: isSelected
                            ? Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                        onTap: () {
                          Navigator.pop(context);
                          onAsignar(usuario.id);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  String _formatRoleName(UserRole? rol) {
    if (rol == null) return 'SIN ROL';

    switch (rol) {
      case UserRole.soporteTecnico:
        return 'SOPORTE TÉCNICO';
      case UserRole.administrador:
        return 'ADMINISTRADOR';
      case UserRole.usuario:
        return 'USUARIO';
      case UserRole.pendiente:
        return 'PENDIENTE';
    }
  }
}

class _AdminInformacionTecnicaWidget extends StatefulWidget {
  final DetalleReporte? detalleReporte;
  final String nombreSoporte;
  final TextEditingController descripcionController;
  final TextEditingController observacionesController;
  final TextEditingController repuestosController;
  final TextEditingController justificacionController;
  final VoidCallback onGuardar;
  final VoidCallback onRefresh;
  final String estadoReporte;

  const _AdminInformacionTecnicaWidget({
    required this.detalleReporte,
    required this.nombreSoporte,
    required this.descripcionController,
    required this.observacionesController,
    required this.repuestosController,
    required this.justificacionController,
    required this.onGuardar,
    required this.onRefresh,
    required this.estadoReporte,
  });

  @override
  State<_AdminInformacionTecnicaWidget> createState() =>
      _AdminInformacionTecnicaWidgetState();
}

class _AdminInformacionTecnicaWidgetState
    extends State<_AdminInformacionTecnicaWidget> {
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (_esEditable()) {
      _addListeners();
    }
  }

  @override
  void dispose() {
    if (_esEditable()) {
      _removeListeners();
    }
    super.dispose();
  }

  void _addListeners() {
    widget.descripcionController.addListener(_onTextChanged);
    widget.observacionesController.addListener(_onTextChanged);
    widget.repuestosController.addListener(_onTextChanged);
    widget.justificacionController.addListener(_onTextChanged);
  }

  void _removeListeners() {
    widget.descripcionController.removeListener(_onTextChanged);
    widget.observacionesController.removeListener(_onTextChanged);
    widget.repuestosController.removeListener(_onTextChanged);
    widget.justificacionController.removeListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  bool _esEditable() {
    final estadosNoEditables = [
      'completado',
      'finalizado',
      'cerrado',
      'cancelado',
    ];
    return !estadosNoEditables.any(
      (estado) => widget.estadoReporte.toLowerCase().contains(estado),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.detalleReporte == null) {
      return _buildSinDetalles();
    }

    final esEditable = _esEditable();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con información del técnico y modo admin
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
          decoration: BoxDecoration(
            color: esEditable
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: esEditable
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: AppSize.defaultPadding * 0.5),
                  Expanded(
                    child: Text(
                      'Modo Administrador - Técnico: ${widget.nombreSoporte}',
                      style: AppStyles.h4(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.defaultPadding * 0.5,
                      vertical: AppSize.defaultPadding * 0.25,
                    ),
                    decoration: BoxDecoration(
                      color: esEditable ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      esEditable ? 'Editable' : 'Solo lectura',
                      style: AppStyles.h5(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.detalleReporte!.fechaAsignacion != null) ...[
                SizedBox(height: AppSize.defaultPadding * 0.25),
                Text(
                  'Asignado: ${_formatDate(widget.detalleReporte!.fechaAsignacion!)}',
                  style: AppStyles.h5(color: AppColors.darkColor50),
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: AppSize.defaultPadding),

        // Formulario o vista de solo lectura
        if (esEditable) _buildFormularioEditable() else _buildVistaLectura(),

        SizedBox(height: AppSize.defaultPadding),

        // Botones de acción para admin
        if (esEditable) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasChanges ? widget.onGuardar : null,
                  icon: Icon(Icons.save_outlined),
                  label: Text('Guardar Cambios'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasChanges
                        ? AppColors.primaryColor
                        : Colors.grey,
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
              SizedBox(width: AppSize.defaultPadding * 0.5),
              OutlinedButton.icon(
                onPressed: _limpiarFormulario,
                icon: Icon(Icons.refresh_outlined),
                label: Text('Limpiar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                  padding: EdgeInsets.symmetric(
                    vertical: AppSize.defaultPadding * 0.75,
                    horizontal: AppSize.defaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          if (_hasChanges) ...[
            SizedBox(height: AppSize.defaultPadding * 0.5),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.amber,
                    size: 16,
                  ),
                  SizedBox(width: AppSize.defaultPadding * 0.5),
                  Expanded(
                    child: Text(
                      'Tienes cambios sin guardar como administrador.',
                      style: AppStyles.h5(color: Colors.amber[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ] else ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Expanded(
                  child: Text(
                    'Este reporte está ${widget.estadoReporte.toLowerCase()} y no puede ser modificado.',
                    style: AppStyles.h5(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSinDetalles() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: Colors.orange),
          SizedBox(height: AppSize.defaultPadding * 0.5),
          Text(
            'Sin Información Técnica',
            style: AppStyles.h4(
              color: AppColors.darkColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSize.defaultPadding * 0.25),
          Text(
            'El técnico asignado aún no ha completado los detalles técnicos del reporte.',
            style: AppStyles.h5(color: AppColors.darkColor50),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioEditable() {
    return Column(
      children: [
        _buildCampoTexto(
          titulo: 'Descripción del Trabajo Realizado',
          icono: Icons.construction_outlined,
          controller: widget.descripcionController,
          placeholder: 'Describe detalladamente el trabajo realizado...',
          maxLines: 4,
          esRequerido: true,
        ),
        SizedBox(height: AppSize.defaultPadding),
        _buildCampoTexto(
          titulo: 'Observaciones Técnicas',
          icono: Icons.note_outlined,
          controller: widget.observacionesController,
          placeholder:
              'Observaciones importantes sobre el problema y la solución...',
          maxLines: 3,
        ),
        SizedBox(height: AppSize.defaultPadding),
        _buildCampoTexto(
          titulo: 'Repuestos Requeridos',
          icono: Icons.build_outlined,
          controller: widget.repuestosController,
          placeholder: 'Lista los repuestos necesarios...',
          maxLines: 3,
          esImportante: true,
        ),
        SizedBox(height: AppSize.defaultPadding),
        _buildCampoTexto(
          titulo: 'Justificación de Repuestos',
          icono: Icons.description_outlined,
          controller: widget.justificacionController,
          placeholder: 'Justifica la necesidad de los repuestos...',
          maxLines: 3,
          esImportante: true,
        ),
      ],
    );
  }

  Widget _buildVistaLectura() {
    return Column(
      children: [
        _buildCampoSoloLectura(
          titulo: 'Descripción del Trabajo Realizado',
          icono: Icons.construction_outlined,
          contenido: widget.descripcionController.text.isEmpty
              ? 'No se registró información'
              : widget.descripcionController.text,
          esVacio: widget.descripcionController.text.isEmpty,
        ),
        SizedBox(height: AppSize.defaultPadding),
        _buildCampoSoloLectura(
          titulo: 'Observaciones Técnicas',
          icono: Icons.note_outlined,
          contenido: widget.observacionesController.text.isEmpty
              ? 'No se registraron observaciones'
              : widget.observacionesController.text,
          esVacio: widget.observacionesController.text.isEmpty,
        ),
        SizedBox(height: AppSize.defaultPadding),
        _buildCampoSoloLectura(
          titulo: 'Repuestos Requeridos',
          icono: Icons.build_outlined,
          contenido: widget.repuestosController.text.isEmpty
              ? 'No se requirieron repuestos'
              : widget.repuestosController.text,
          esVacio: widget.repuestosController.text.isEmpty,
        ),
        SizedBox(height: AppSize.defaultPadding),
        _buildCampoSoloLectura(
          titulo: 'Justificación de Repuestos',
          icono: Icons.description_outlined,
          contenido: widget.justificacionController.text.isEmpty
              ? 'No se registró justificación'
              : widget.justificacionController.text,
          esVacio: widget.justificacionController.text.isEmpty,
        ),
      ],
    );
  }

  Widget _buildCampoTexto({
    required String titulo,
    required IconData icono,
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
    bool esRequerido = false,
    bool esImportante = false,
  }) {
    final tieneContenido = controller.text.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
      decoration: BoxDecoration(
        color: esImportante
            ? (tieneContenido
                  ? Colors.green.withOpacity(0.1)
                  : Colors.amber.withOpacity(0.1))
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esImportante
              ? (tieneContenido
                    ? Colors.green.withOpacity(0.3)
                    : Colors.amber.withOpacity(0.3))
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icono,
                color: esImportante
                    ? (tieneContenido ? Colors.green : Colors.amber)
                    : Colors.grey,
                size: 20,
              ),
              SizedBox(width: AppSize.defaultPadding * 0.5),
              Expanded(
                child: Text(
                  titulo,
                  style: AppStyles.h5(
                    color: AppColors.darkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (esRequerido)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.defaultPadding * 0.5,
                    vertical: AppSize.defaultPadding * 0.25,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Requerido',
                    style: AppStyles.h5(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSize.defaultPadding * 0.5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppStyles.h5(color: AppColors.darkColor),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppStyles.h5(color: AppColors.darkColor50),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoSoloLectura({
    required String titulo,
    required IconData icono,
    required String contenido,
    required bool esVacio,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
      decoration: BoxDecoration(
        color: esVacio
            ? Colors.grey.withOpacity(0.05)
            : Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esVacio
              ? Colors.grey.withOpacity(0.2)
              : Colors.green.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icono,
                color: esVacio ? Colors.grey : Colors.green,
                size: 20,
              ),
              SizedBox(width: AppSize.defaultPadding * 0.5),
              Expanded(
                child: Text(
                  titulo,
                  style: AppStyles.h5(
                    color: AppColors.darkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.lock_outline, color: Colors.grey, size: 16),
            ],
          ),
          SizedBox(height: AppSize.defaultPadding * 0.5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Text(
              contenido,
              style: AppStyles.h5(
                color: esVacio ? AppColors.darkColor50 : AppColors.darkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange),
            SizedBox(width: AppSize.defaultPadding * 0.5),
            Text('Limpiar Formulario'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas limpiar todos los campos? '
          'Se perderán todos los cambios no guardados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.descripcionController.clear();
              widget.observacionesController.clear();
              widget.repuestosController.clear();
              widget.justificacionController.clear();

              if (mounted) {
                setState(() {
                  _hasChanges = false;
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
