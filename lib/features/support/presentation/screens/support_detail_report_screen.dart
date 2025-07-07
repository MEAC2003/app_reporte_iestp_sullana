import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/reporte_incidencia.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SupportDetailReportScreen extends StatelessWidget {
  final String reportId;
  const SupportDetailReportScreen({super.key, required this.reportId});

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
      body: _SupportDetailReportView(productId: reportId),
    );
  }
}

class _SupportDetailReportView extends StatefulWidget {
  final String productId;
  const _SupportDetailReportView({required this.productId});

  @override
  State<_SupportDetailReportView> createState() =>
      _SupportDetailReportViewState();
}

class _SupportDetailReportViewState extends State<_SupportDetailReportView> {
  ReporteIncidencia? reporte;
  DetalleReporte? detalleReporte;
  bool isLoading = true;
  String? error;
  UserRole? currentUserRole;

  // Controladores para los campos de edición
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

  Future<void> _loadReporteDetail() async {
    try {
      final provider = context.read<AdminActionProvider>();
      final userProvider = context.read<UserProvider>();

      await provider.loadInitialData();
      await userProvider.getUsers();
      await provider.loadUsuariosPublicos();

      // Obtener el rol del usuario actual
      currentUserRole = await _getCurrentUserRole(provider);

      final reporteData = await provider.getReporteById(widget.productId);
      final detalleData = await provider.getDetalleReporteByReporteId(
        widget.productId,
      );

      if (mounted) {
        setState(() {
          reporte = reporteData;
          detalleReporte = detalleData;

          // Llenar los controladores con los datos existentes
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

  Future<UserRole?> _getCurrentUserRole(AdminActionProvider provider) async {
    try {
      // Aquí deberías obtener el ID del usuario actual desde tu sistema de autenticación
      final currentUserId = await _getCurrentUserId();

      if (currentUserId != null) {
        final usuarioActual = provider.usuariosPublicos.firstWhere(
          (u) => u.id == currentUserId,
          orElse: () => throw Exception('Usuario no encontrado'),
        );

        return _roleMapping[usuarioActual.rol];
      }
    } catch (e) {
      print('Error obteniendo rol del usuario: $e');
    }
    return UserRole.soporteTecnico; // Por defecto soporte para esta pantalla
  }

  Future<String?> _getCurrentUserId() async {
    // IMPLEMENTAR según tu sistema de autenticación
    // Por ejemplo: return SharedPreferences.getInstance().then((prefs) => prefs.getString('user_id'));
    return null;
  }

  bool _isAdmin() => currentUserRole == UserRole.administrador;
  bool _isSupport() => currentUserRole == UserRole.soporteTecnico;

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    await _loadReporteDetail();
  }

  Future<void> _guardarInformacionTecnica() async {
    if (reporte == null) return;

    // Mostrar diálogo de confirmación
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.save_outlined, color: AppColors.primaryColor),
            SizedBox(width: AppSize.defaultPadding * 0.5),
            Text(
              'Guardar Información',
              style: AppStyles.h4(
                color: AppColors.darkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Deseas guardar la información técnica del reporte?\n\n'
          'Se actualizarán todos los campos completados.',
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

    if (confirmacion != true) return;

    // Mostrar loading
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

    try {
      final provider = context.read<AdminActionProvider>();

      final success = await provider.actualizarInformacionTecnica(
        reporteId: reporte!.id!,
        descripcion: _descripcionController.text.trim(),
        observaciones: _observacionesController.text.trim(),
        repuestosRequeridos: _repuestosController.text.trim(),
        justificacionRepuestos: _justificacionController.text.trim(),
      );

      Navigator.pop(context); // Cerrar loading

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
        await _refreshData();
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
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cambiarEstado(String nuevoEstadoId) async {
    if (reporte == null) return;

    try {
      final provider = context.read<AdminActionProvider>();

      final success = await provider.cambiarEstadoReporte(
        reporteId: reporte!.id!,
        nuevoEstadoId: nuevoEstadoId,
      );

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
        await _refreshData();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
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
              'Cargando detalle del reporte...',
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
                'No se encontró el ticket',
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
        } catch (e) {
          print('Error finding estado reporte: $e');
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

        bool puedeModificarEstado = _puedeModificarEstado(estadoReporteNombre);

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

              // Descripción del problema
              InfoCard(
                title: 'Descripción del Problema',
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

              // Gestión de Estado para Soporte
              InfoCard(
                title: 'Gestión del Ticket',
                icon: Icons.engineering_outlined,
                children: [
                  _SupportTicketManagement(
                    estadoReporte: estadoReporteNombre,
                    puedeModificar: puedeModificarEstado,
                    userRole: currentUserRole,
                    onCambiarEstado: _cambiarEstado,
                    estadosDisponibles: provider.estadosReporte,
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Información Técnica del Soporte (Formulario Editable)
              InfoCard(
                title: 'Información Técnica del Soporte',
                icon: Icons.build_outlined,
                children: [
                  _SupportTechnicalInfo(
                    detalleReporte: detalleReporte,
                    nombreSoporte: nombreSoporteAsignado,
                    descripcionController: _descripcionController,
                    observacionesController: _observacionesController,
                    repuestosController: _repuestosController,
                    justificacionController: _justificacionController,
                    onGuardar: _guardarInformacionTecnica,
                    userRole: currentUserRole,
                    estadoReporte: estadoReporteNombre,
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding * 2),
            ],
          ),
        );
      },
    );
  }

  bool _puedeModificarEstado(String estado) {
    final estadosNoModificables = ['cancelado', 'cerrado', 'finalizado'];

    return !estadosNoModificables.any(
      (estadoNoMod) => estado.toLowerCase().contains(estadoNoMod),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'en espera (repuestos)':
        return Colors.purple;
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

  static final Map<String, UserRole> _roleMapping = {
    '6cf8bda6-1726-495e-9c6a-917f474e1081': UserRole.pendiente,
    '3f685a86-8b62-4a8b-ac73-092a06bf7961': UserRole.usuario,
    'd761f72b-3a0f-4c4a-bcec-1ad5bd79b7e1': UserRole.administrador,
    'f0c11c95-a587-44ad-bd1f-3b6cfcf661cd': UserRole.soporteTecnico,
  };
}

// Widget para gestión de estado por parte del soporte
class _SupportTicketManagement extends StatelessWidget {
  final String estadoReporte;
  final bool puedeModificar;
  final UserRole? userRole;
  final Function(String) onCambiarEstado;
  final List<dynamic> estadosDisponibles;

  const _SupportTicketManagement({
    required this.estadoReporte,
    required this.puedeModificar,
    required this.userRole,
    required this.onCambiarEstado,
    required this.estadosDisponibles,
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
            color: _getEstadoColor(estadoReporte).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getEstadoColor(estadoReporte).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
                decoration: BoxDecoration(
                  color: _getEstadoColor(estadoReporte),
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
                      estadoReporte,
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
              onPressed: () => _mostrarDialogoCambiarEstado(context),
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
                    'No se puede modificar el estado del ticket (estado: $estadoReporte)',
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

  void _mostrarDialogoCambiarEstado(BuildContext context) {
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
              final isCurrentState = estado.nombre == estadoReporte;

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
                      : () {
                          Navigator.pop(context);
                          onCambiarEstado(estado.id);
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

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'en espera (repuestos)':
        return Colors.purple;
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return AppColors.darkColor50;
    }
  }
}

// Widget para información técnica editable del soporte
// Widget para información técnica editable del soporte
class _SupportTechnicalInfo extends StatefulWidget {
  final DetalleReporte? detalleReporte;
  final String nombreSoporte;
  final TextEditingController descripcionController;
  final TextEditingController observacionesController;
  final TextEditingController repuestosController;
  final TextEditingController justificacionController;
  final VoidCallback onGuardar;
  final UserRole? userRole;
  final String estadoReporte; // ← PARÁMETRO AGREGADO

  const _SupportTechnicalInfo({
    required this.detalleReporte,
    required this.nombreSoporte,
    required this.descripcionController,
    required this.observacionesController,
    required this.repuestosController,
    required this.justificacionController,
    required this.onGuardar,
    required this.userRole,
    required this.estadoReporte,
  });

  @override
  State<_SupportTechnicalInfo> createState() => _SupportTechnicalInfoState();
}

class _SupportTechnicalInfoState extends State<_SupportTechnicalInfo> {
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Solo agregar listeners si el ticket es editable
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

  // MÉTODO PARA VERIFICAR SI EL TICKET ES EDITABLE
  bool _esEditable() {
    final estadosNoEditables = [
      'completado',
      'finalizado',
      'cerrado',
      'cancelado',
      'terminado',
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
        // Información del técnico
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
                    Icons.person_outline,
                    color: esEditable ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: AppSize.defaultPadding * 0.5),
                  Expanded(
                    child: Text(
                      'Técnico Asignado: ${widget.nombreSoporte}',
                      style: AppStyles.h4(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // INDICADOR DE ESTADO
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.defaultPadding * 0.5,
                      vertical: AppSize.defaultPadding * 0.25,
                    ),
                    decoration: BoxDecoration(
                      color: esEditable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: esEditable
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          esEditable ? Icons.edit : Icons.lock_outline,
                          color: esEditable ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: AppSize.defaultPadding * 0.25),
                        Text(
                          esEditable ? 'Editable' : 'Solo lectura',
                          style: AppStyles.h5(
                            color: esEditable ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

        // MOSTRAR INFORMACIÓN TÉCNICA
        if (esEditable)
          _buildFormularioTecnico()
        else
          _buildInformacionSoloLectura(),

        SizedBox(height: AppSize.defaultPadding),

        // BOTONES DE ACCIÓN - Solo mostrar si es editable
        if (esEditable) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasChanges ? widget.onGuardar : null,
                  icon: Icon(Icons.save_outlined),
                  label: Text(
                    'Guardar Inf.',
                    style: AppStyles.h4(fontWeight: FontWeight.w600),
                  ),
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
                label: Text(
                  'Limpiar',
                  style: AppStyles.h4(fontWeight: FontWeight.w600),
                ),
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
                      'Tienes cambios sin guardar. No olvides guardar tu trabajo.',
                      style: AppStyles.h5(color: Colors.amber[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ] else ...[
          // MENSAJE PARA TICKETS CERRADOS
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
                    'Este ticket está ${widget.estadoReporte.toLowerCase()} y no puede ser modificado.',
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
            'Ticket Sin Asignar',
            style: AppStyles.h4(
              color: AppColors.darkColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSize.defaultPadding * 0.25),
          Text(
            'Este ticket aún no ha sido asignado a un técnico de soporte.',
            style: AppStyles.h5(color: AppColors.darkColor50),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // MÉTODO PARA MOSTRAR INFORMACIÓN COMO SOLO LECTURA
  Widget _buildInformacionSoloLectura() {
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

  // MÉTODO PARA CAMPOS DE SOLO LECTURA
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

  Widget _buildFormularioTecnico() {
    return Column(
      children: [
        // Descripción del trabajo realizado
        _buildCampoTexto(
          titulo: 'Descripción del Trabajo Realizado',
          icono: Icons.construction_outlined,
          controller: widget.descripcionController,
          placeholder: 'Describe detalladamente el trabajo realizado...',
          maxLines: 4,
          esRequerido: true,
        ),

        SizedBox(height: AppSize.defaultPadding),

        // Observaciones técnicas
        _buildCampoTexto(
          titulo: 'Observaciones Técnicas',
          icono: Icons.note_outlined,
          controller: widget.observacionesController,
          placeholder:
              'Agrega observaciones importantes sobre el problema y la solución...',
          maxLines: 3,
        ),

        SizedBox(height: AppSize.defaultPadding),

        // Repuestos requeridos
        _buildCampoTexto(
          titulo: 'Repuestos Requeridos',
          icono: Icons.build_outlined,
          controller: widget.repuestosController,
          placeholder: 'Lista los repuestos necesarios (si aplica)...',
          maxLines: 3,
          esImportante: true,
        ),

        SizedBox(height: AppSize.defaultPadding),

        // Justificación de repuestos
        _buildCampoTexto(
          titulo: 'Justificación de Repuestos',
          icono: Icons.description_outlined,
          controller: widget.justificacionController,
          placeholder:
              'Justifica por qué son necesarios los repuestos solicitados...',
          maxLines: 3,
          esImportante: true,
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
            style: AppStyles.h5(
              color: AppColors.darkColor,
              fontWeight: FontWeight.normal,
            ),
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
