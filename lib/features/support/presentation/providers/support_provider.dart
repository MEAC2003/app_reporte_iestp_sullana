import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/models.dart';
import 'package:app_reporte_iestp_sullana/features/admin/domain/repositories/admin_action_repository.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:flutter/material.dart';

class SupportProvider extends ChangeNotifier {
  final AdminActionRepository _adminActionRepository;
  final AuthProvider _authProvider;

  SupportProvider({
    required AdminActionRepository adminActionRepository,
    required AuthProvider authProvider,
  }) : _adminActionRepository = adminActionRepository,
       _authProvider = authProvider;

  // Estados
  bool _isLoading = false;
  bool _isLoadingTickets = false;
  String? _error;

  // Listas de reportes
  List<ReporteIncidencia> _ticketsAsignados = [];
  List<ReporteIncidencia> _historialTickets = [];

  // Mapas para datos relacionados (reutilizando la misma lógica del admin)
  Map<String, String> _areasMap = {};
  Map<String, String> _tiposReporteMap = {};
  Map<String, String> _prioridadesMap = {};
  Map<String, String> _estadosMap = {};
  Map<String, String> _usuariosMap = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingTickets => _isLoadingTickets;
  String? get error => _error;
  List<ReporteIncidencia> get ticketsAsignados => _ticketsAsignados;
  List<ReporteIncidencia> get historialTickets => _historialTickets;
  Map<String, String> get areasMap => _areasMap;
  Map<String, String> get tiposReporteMap => _tiposReporteMap;
  Map<String, String> get prioridadesMap => _prioridadesMap;
  Map<String, String> get estadosMap => _estadosMap;
  Map<String, String> get usuariosMap => _usuariosMap;

  // CARGAR TICKETS ASIGNADOS (ACTIVOS)
  Future<void> loadTicketsAsignados() async {
    _isLoadingTickets = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authProvider.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Obtener reportes asignados al soporte técnico actual
      final reportes = await _adminActionRepository.getReportesBySoporteId(
        userId,
      );

      // Filtrar solo los que NO estén cerrados/finalizados
      _ticketsAsignados = reportes.where((reporte) {
        // Obtener nombre del estado
        final estadoNombre = _estadosMap[reporte.idEstadoReporte] ?? '';
        final estadoLower = estadoNombre.toLowerCase();

        // Excluir estados finalizados
        return !estadoLower.contains('cerrado') &&
            !estadoLower.contains('finalizado') &&
            !estadoLower.contains('completado') &&
            !estadoLower.contains('cancelado');
      }).toList();

      // Ordenar por prioridad y fecha
      _ticketsAsignados.sort((a, b) {
        // Primero por prioridad (alta primero)
        final prioridadA = _prioridadesMap[a.idPrioridad] ?? '';
        final prioridadB = _prioridadesMap[b.idPrioridad] ?? '';

        if (prioridadA.toLowerCase().contains('alta') &&
            !prioridadB.toLowerCase().contains('alta')) {
          return -1;
        } else if (!prioridadA.toLowerCase().contains('alta') &&
            prioridadB.toLowerCase().contains('alta')) {
          return 1;
        }

        // Luego por fecha (más reciente primero)
        return DateTime.parse(
          b.createdAt!,
        ).compareTo(DateTime.parse(a.createdAt!));
      });
    } catch (e) {
      _error = 'Error al cargar tickets asignados: $e';
      print(_error);
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  // CARGAR HISTORIAL COMPLETO
  Future<void> loadHistorialTickets() async {
    _isLoadingTickets = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authProvider.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Obtener TODOS los reportes asignados al soporte técnico
      _historialTickets = await _adminActionRepository.getReportesBySoporteId(
        userId,
      );

      // Ordenar por fecha (más reciente primero)
      _historialTickets.sort(
        (a, b) => DateTime.parse(
          b.createdAt!,
        ).compareTo(DateTime.parse(a.createdAt!)),
      );
    } catch (e) {
      _error = 'Error al cargar historial: $e';
      print(_error);
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  // CARGAR DATOS RELACIONADOS (reutilizando métodos del admin)
  Future<void> loadRelatedData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar todos los datos de referencia en paralelo
      final futures = await Future.wait([
        _adminActionRepository.getArea(),
        _adminActionRepository.getTipoReporte(),
        _adminActionRepository.getPrioridad(),
        _adminActionRepository.getEstadoReporte(),
        _adminActionRepository.getUsuariosPublicos(),
      ]);

      // Convertir a mapas para fácil acceso
      final areas = futures[0] as List<Area>;
      final tiposReporte = futures[1] as List<TipoReporte>;
      final prioridades = futures[2] as List<Prioridad>;
      final estadosReporte = futures[3] as List<EstadoReporte>;
      final usuarios = futures[4] as List<UsuarioPublico>;

      _areasMap = {for (var area in areas) area.id: area.nombre};
      _tiposReporteMap = {for (var tipo in tiposReporte) tipo.id: tipo.nombre};
      _prioridadesMap = {
        for (var prioridad in prioridades) prioridad.id: prioridad.nombre,
      };
      _estadosMap = {
        for (var estado in estadosReporte) estado.id: estado.nombre,
      };
      _usuariosMap = {for (var usuario in usuarios) usuario.id: usuario.nombre};
    } catch (e) {
      _error = 'Error al cargar datos relacionados: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // OBTENER DETALLE DE REPORTE
  Future<ReporteIncidencia?> getReporteById(String reporteId) async {
    try {
      return await _adminActionRepository.getReporteById(id: reporteId);
    } catch (e) {
      print('Error obteniendo reporte: $e');
      return null;
    }
  }

  // OBTENER DETALLE DE REPORTE (con datos del soporte)
  Future<DetalleReporte?> getDetalleReporteByReporteId(String reporteId) async {
    try {
      return await _adminActionRepository.getDetalleReporteByReporteId(
        reporteId: reporteId,
      );
    } catch (e) {
      print('Error obteniendo detalle reporte: $e');
      return null;
    }
  }

  // ACTUALIZAR DETALLE DE REPORTE (soporte completa información)
  Future<bool> updateDetalleReporte(DetalleReporte detalleReporte) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _adminActionRepository.updateDetalleReporte(detalleReporte);

      // Recargar tickets para reflejar cambios
      await loadTicketsAsignados();

      return true;
    } catch (e) {
      _error = 'Error al actualizar detalle: $e';
      print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CAMBIAR ESTADO DE REPORTE
  Future<bool> cambiarEstadoReporte(
    String reporteId,
    String nuevoEstadoId,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Obtener el reporte actual
      final reporteActual = await _adminActionRepository.getReporteById(
        id: reporteId,
      );

      // Actualizar con el nuevo estado
      final reporteActualizado = reporteActual.copyWith(
        idEstadoReporte: nuevoEstadoId,
      );

      await _adminActionRepository.updateReporte(reporteActualizado);

      // Recargar tickets para reflejar cambios
      await loadTicketsAsignados();
      await loadHistorialTickets();

      return true;
    } catch (e) {
      _error = 'Error al cambiar estado: $e';
      print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // INICIALIZAR PROVIDER
  Future<void> initialize() async {
    await loadRelatedData();
    await loadTicketsAsignados();
  }

  // REFRESCAR DATOS
  Future<void> refresh() async {
    await loadRelatedData();
    await loadTicketsAsignados();
  }

  // LIMPIAR ERROR
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ESTADÍSTICAS RÁPIDAS
  int get totalTicketsAsignados => _ticketsAsignados.length;
  int get totalHistorial => _historialTickets.length;

  int get ticketsAltaPrioridad => _ticketsAsignados.where((ticket) {
    final prioridad = _prioridadesMap[ticket.idPrioridad] ?? '';
    return prioridad.toLowerCase().contains('alta');
  }).length;

  int get ticketsEnProceso => _ticketsAsignados.where((ticket) {
    final estado = _estadosMap[ticket.idEstadoReporte] ?? '';
    return estado.toLowerCase().contains('proceso') ||
        estado.toLowerCase().contains('asignado');
  }).length;
}
