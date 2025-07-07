import 'dart:io';

import 'package:app_reporte_iestp_sullana/features/admin/data/models/adjuntar_archivo_requerimiento.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/models.dart';
import 'package:app_reporte_iestp_sullana/features/admin/domain/repositories/admin_action_repository.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/services/cloudinary_service.dart';
import 'package:app_reporte_iestp_sullana/services/excel_service.dart';
import 'package:app_reporte_iestp_sullana/services/pdf_service.dart';
import 'package:flutter/material.dart';

class AdminActionProvider extends ChangeNotifier {
  final AdminActionRepository _adminActionRepository;
  AdminActionProvider(this._adminActionRepository);

  final PdfService _pdfService = PdfService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  List<ReporteIncidencia> _reportes = [];
  List<Area> _areas = [];
  List<EstadoReporte> _estadosReporte = [];
  List<TipoReporte> _tiposReporte = [];
  List<Prioridad> _prioridades = [];
  List<UsuarioPublico> _usuariosPublicos = [];

  // Agregar listas filtradas
  List<ReporteIncidencia> _filteredReportes = [];
  List<Area> _filteredAreas = [];
  List<EstadoReporte> _filteredEstadosReporte = [];
  List<TipoReporte> _filteredTiposReporte = [];
  List<Prioridad> _filteredPrioridades = [];

  String _reporteSearchQuery = '';
  String _areaSearchQuery = '';
  String _estadoSearchQuery = '';
  String _tipoReporteSearchQuery = '';
  String _prioridadSearchQuery = '';

  String _selectedStatusFilter = 'todos';
  String _selectedPriorityFilter = 'todos';
  DateTimeRange? _dateRange;

  List<ReporteIncidencia> get reportes => _reportes;
  List<Area> get areas => _areas;
  List<EstadoReporte> get estadosReporte => _estadosReporte;
  List<TipoReporte> get tiposReporte => _tiposReporte;
  List<Prioridad> get prioridades => _prioridades;
  List<UsuarioPublico> get usuariosPublicos => _usuariosPublicos;

  List<ReporteIncidencia> get filteredReportes => _filteredReportes;
  List<Area> get filteredAreas => _filteredAreas;
  List<EstadoReporte> get filteredEstadosReporte => _filteredEstadosReporte;
  List<TipoReporte> get filteredTiposReporte => _filteredTiposReporte;
  List<Prioridad> get filteredPrioridades => _filteredPrioridades;

  String get selectedStatusFilter => _selectedStatusFilter;
  String get selectedPriorityFilter => _selectedPriorityFilter;
  DateTimeRange? get dateRange => _dateRange;

  String? get selectedDateRange {
    if (_dateRange == null) return null;
    return '${formatDate(_dateRange!.start.toIso8601String())} - ${formatDate(_dateRange!.end.toIso8601String())}';
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Cargar reportes específicamente
  Future<void> loadReportes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reportes = await _adminActionRepository.getReporte();
      _applyReportFilters(); // Aplicar filtros después de cargar
    } catch (e) {
      print('Error loading reportes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  Filtrar por prioridad
  void filterReportesByPriority(String priorityId) {
    _selectedPriorityFilter = priorityId;
    _applyReportFilters();
  }

  //  Filtrar por rango de fechas
  void filterReportesByDateRange(DateTimeRange range) {
    _dateRange = range;
    _applyReportFilters();
  }

  // Limpiar filtro de fecha
  void clearDateFilter() {
    _dateRange = null;
    _applyReportFilters();
  }

  void searchReportes(String query) {
    _reporteSearchQuery = query.toLowerCase();
    _applyReportFilters();
  }

  //  Limpiar todos los filtros
  void clearAllFilters() {
    _selectedStatusFilter = 'todos';
    _selectedPriorityFilter = 'todos';
    _dateRange = null;
    _reporteSearchQuery = '';
    _applyReportFilters();
  }

  //  Filtrar reportes por estado
  void filterReportesByStatus(String statusId) {
    _selectedStatusFilter = statusId;
    _applyReportFilters();
  }

  // Aplicar todos los filtros a reportes
  void _applyReportFilters() {
    List<ReporteIncidencia> filtered = _reportes;

    // Aplicar filtro de búsqueda
    if (_reporteSearchQuery.isNotEmpty) {
      filtered = filtered.where((reporte) {
        return reporte.descripcion.toLowerCase().contains(
              _reporteSearchQuery,
            ) ||
            (reporte.id?.toLowerCase().contains(_reporteSearchQuery) ?? false);
      }).toList();
    }

    // Aplicar filtro de estado
    if (_selectedStatusFilter != 'todos' && _selectedStatusFilter.isNotEmpty) {
      filtered = filtered.where((reporte) {
        return reporte.idEstadoReporte == _selectedStatusFilter;
      }).toList();
    }

    // Aplicar filtro de prioridad
    if (_dateRange != null) {
      filtered = filtered.where((reporte) {
        if (reporte.createdAt == null) return false;
        try {
          final reportDate = DateTime.parse(reporte.createdAt!);

          // Obtener solo la fecha (sin hora) para comparación exacta
          final reportDateOnly = DateTime(
            reportDate.year,
            reportDate.month,
            reportDate.day,
          );
          final startDateOnly = DateTime(
            _dateRange!.start.year,
            _dateRange!.start.month,
            _dateRange!.start.day,
          );
          final endDateOnly = DateTime(
            _dateRange!.end.year,
            _dateRange!.end.month,
            _dateRange!.end.day,
          );

          // Verificar si la fecha del reporte está dentro del rango (inclusive)
          return (reportDateOnly.isAtSameMomentAs(startDateOnly) ||
                  reportDateOnly.isAfter(startDateOnly)) &&
              (reportDateOnly.isAtSameMomentAs(endDateOnly) ||
                  reportDateOnly.isBefore(endDateOnly));
        } catch (e) {
          print('Error parsing date: ${reporte.createdAt}');
          return false;
        }
      }).toList();
    }

    _filteredReportes = filtered;
    notifyListeners();
  }

  // Obtener color según estado ID

  Color getStatusColor(String estadoReporteId) {
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

  // Obtener nombre del estado por ID
  String getStatusName(String statusId) {
    final estado = _estadosReporte.firstWhere(
      (e) => e.id == statusId,
      orElse: () => EstadoReporte(
        id: '',
        nombre: 'Desconocido',
        descripcion: '',
        createdAt: '',
      ),
    );
    return estado.nombre;
  }

  //  Formatear fecha
  String formatDate(String? dateString) {
    if (dateString == null) return 'Sin fecha';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reportes = await _adminActionRepository.getReporte();
      _areas = await _adminActionRepository.getArea();
      _estadosReporte = await _adminActionRepository.getEstadoReporte();
      _tiposReporte = await _adminActionRepository.getTipoReporte();
      _prioridades = await _adminActionRepository.getPrioridad();

      // Inicializar listas filtradas
      _filteredReportes = _reportes;
      _filteredAreas = _areas;
      _filteredEstadosReporte = _estadosReporte;
      _filteredTiposReporte = _tiposReporte;
      _filteredPrioridades = _prioridades;
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  Métodos de carga individual
  Future<void> loadAreas() async {
    _isLoading = true;
    notifyListeners();
    try {
      _areas = await _adminActionRepository.getArea();
      _filteredAreas = _areas;
    } catch (e) {
      print('Error loading areas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEstadosReporte() async {
    _isLoading = true;
    notifyListeners();
    try {
      _estadosReporte = await _adminActionRepository.getEstadoReporte();
      _filteredEstadosReporte = _estadosReporte;
    } catch (e) {
      print('Error loading estados reporte: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTiposReporte() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tiposReporte = await _adminActionRepository.getTipoReporte();
      _filteredTiposReporte = _tiposReporte;
    } catch (e) {
      print('Error loading tipos reporte: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPrioridades() async {
    _isLoading = true;
    notifyListeners();
    try {
      _prioridades = await _adminActionRepository.getPrioridad();
      _filteredPrioridades = _prioridades;
    } catch (e) {
      print('Error loading prioridades: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  Métodos de búsqueda
  void searchAreas(String query) {
    _areaSearchQuery = query.toLowerCase();
    if (_areaSearchQuery.isEmpty) {
      _filteredAreas = _areas;
    } else {
      _filteredAreas = _areas.where((area) {
        return area.nombre.toLowerCase().contains(_areaSearchQuery);
      }).toList();
    }
    notifyListeners();
  }

  void searchEstadosReporte(String query) {
    _estadoSearchQuery = query.toLowerCase();
    if (_estadoSearchQuery.isEmpty) {
      _filteredEstadosReporte = _estadosReporte;
    } else {
      _filteredEstadosReporte = _estadosReporte.where((estado) {
        return estado.nombre.toLowerCase().contains(_estadoSearchQuery) ||
            (estado.descripcion.toLowerCase().contains(_estadoSearchQuery) ??
                false);
      }).toList();
    }
    notifyListeners();
  }

  void searchTiposReporte(String query) {
    _tipoReporteSearchQuery = query.toLowerCase();
    if (_tipoReporteSearchQuery.isEmpty) {
      _filteredTiposReporte = _tiposReporte;
    } else {
      _filteredTiposReporte = _tiposReporte.where((tipo) {
        return tipo.nombre.toLowerCase().contains(_tipoReporteSearchQuery) ||
            (tipo.descripcion.toLowerCase().contains(_tipoReporteSearchQuery) ??
                false);
      }).toList();
    }
    notifyListeners();
  }

  void searchPrioridades(String query) {
    _prioridadSearchQuery = query.toLowerCase();
    if (_prioridadSearchQuery.isEmpty) {
      _filteredPrioridades = _prioridades;
    } else {
      _filteredPrioridades = _prioridades.where((prioridad) {
        return prioridad.nombre.toLowerCase().contains(_prioridadSearchQuery);
      }).toList();
    }
    notifyListeners();
  }

  Future<bool> createArea({required String name}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final tempArea = Area(id: '', nombre: name);
      final id = await _adminActionRepository.createArea(tempArea);

      if (id != null) {
        final newArea = tempArea.copyWith(id: id);
        _areas.add(newArea);
        _filteredAreas = _areas;
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating area: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateArea({required String id, required String name}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final area = Area(id: id, nombre: name, createdAt: '');
      await _adminActionRepository.updateArea(area);

      final index = _areas.indexWhere((a) => a.id == id);
      if (index != -1) {
        _areas[index] = area;
        _filteredAreas = _areas;
      }
      return true;
    } catch (e) {
      print('Error updating area: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteArea(String areaId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminActionRepository.deleteArea(areaId);
      _areas.removeWhere((a) => a.id == areaId);
      _filteredAreas = _areas;
      return true;
    } catch (e) {
      print('Error deleting area: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos CRUD para Estados de Reporte
  Future<bool> createEstadoReporte({
    required String name,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final estado = EstadoReporte(
        nombre: name,
        descripcion: description ?? '',
        id: '',
        createdAt: '',
      );
      final id = await _adminActionRepository.createEstadoReporte(estado);
      if (id != null) {
        final newEstado = estado.copyWith(id: id);
        _estadosReporte.add(newEstado);
        _filteredEstadosReporte = _estadosReporte;
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating estado reporte: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEstadoReporte({
    required String id,
    required String name,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final estado = EstadoReporte(
        id: id,
        nombre: name,
        descripcion: description ?? '',
        createdAt: '',
      );
      await _adminActionRepository.updateEstadoReporte(estado);

      final index = _estadosReporte.indexWhere((e) => e.id == id);
      if (index != -1) {
        _estadosReporte[index] = estado;
        _filteredEstadosReporte = _estadosReporte;
      }
      return true;
    } catch (e) {
      print('Error updating estado reporte: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEstadoReporte(String estadoId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminActionRepository.deleteEstadoReporte(estadoId);
      _estadosReporte.removeWhere((e) => e.id == estadoId);
      _filteredEstadosReporte = _estadosReporte;
      return true;
    } catch (e) {
      print('Error deleting estado reporte: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos CRUD para Tipos de Reporte
  Future<bool> createTipoReporte({
    required String name,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final tipo = TipoReporte(
        nombre: name,
        descripcion: description ?? '',
        id: '',
        createdAt: '',
      );
      final id = await _adminActionRepository.createTipoReporte(tipo);
      if (id != null) {
        final newTipo = tipo.copyWith(id: id);
        _tiposReporte.add(newTipo);
        _filteredTiposReporte = _tiposReporte;
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating tipo reporte: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTipoReporte({
    required String id,
    required String name,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final tipo = TipoReporte(
        id: id,
        nombre: name,
        descripcion: description ?? '',
        createdAt: '',
      );
      await _adminActionRepository.updateTipoReporte(tipo);

      final index = _tiposReporte.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tiposReporte[index] = tipo;
        _filteredTiposReporte = _tiposReporte;
      }
      return true;
    } catch (e) {
      print('Error updating tipo reporte: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTipoReporte(String tipoId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminActionRepository.deleteTipoReporte(tipoId);
      _tiposReporte.removeWhere((t) => t.id == tipoId);
      _filteredTiposReporte = _tiposReporte;
      return true;
    } catch (e) {
      print('Error deleting tipo reporte: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  Métodos CRUD para Prioridades
  Future<bool> createPrioridad({required String name}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prioridad = Prioridad(nombre: name, id: '', createdAt: '');
      final id = await _adminActionRepository.createPrioridad(prioridad);
      if (id != null) {
        final newPrioridad = prioridad.copyWith(id: id);
        _prioridades.add(newPrioridad);
        _filteredPrioridades = _prioridades;
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating prioridad: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePrioridad({
    required String id,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prioridad = Prioridad(id: id, nombre: name, createdAt: '');
      await _adminActionRepository.updatePrioridad(prioridad);

      final index = _prioridades.indexWhere((p) => p.id == id);
      if (index != -1) {
        _prioridades[index] = prioridad;
        _filteredPrioridades = _prioridades;
      }
      return true;
    } catch (e) {
      print('Error updating prioridad: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePrioridad(String prioridadId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminActionRepository.deletePrioridad(prioridadId);
      _prioridades.removeWhere((p) => p.id == prioridadId);
      _filteredPrioridades = _prioridades;
      return true;
    } catch (e) {
      print('Error deleting prioridad: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos existentes del reporte (mantener como están)
  Future<String?> createReporte(ReporteIncidencia reporte) async {
    _isLoading = true;
    notifyListeners();
    try {
      final id = await _adminActionRepository.createReporte(reporte);
      if (id != null) {
        _reportes.add(reporte.copyWith(id: id));
      }
      return id;
    } catch (e) {
      print('Error creating reporte: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createReporteWithParams({
    required String descripcion,
    required String imageUrl,
    required String areaId,
    required String tipoReporteId,
    required String prioridadId,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final reporte = ReporteIncidencia(
        descripcion: descripcion,
        urlImg: imageUrl,
        idArea: areaId,
        idTipoReporte: tipoReporteId,
        idPrioridad: prioridadId,
        idUsuario: userId,
        idEstadoReporte: "29e11cdf-fcf7-4c36-a7fd-f363dcaf864c",
      );

      final id = await createReporte(reporte);
      return id;
    } catch (e) {
      print('Error creating reporte with params: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReporte(ReporteIncidencia reporte) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminActionRepository.updateReporte(reporte);
      final index = _reportes.indexWhere((r) => r.id == reporte.id);
      if (index != -1) {
        _reportes[index] = reporte;
      }
    } catch (e) {
      print('Error updating reporte: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReporte(String reporteId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminActionRepository.deleteReporte(reporteId);
      _reportes.removeWhere((r) => r.id == reporteId);
    } catch (e) {
      print('Error deleting reporte: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReporteIncidencia> getReporteById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final reporte = await _adminActionRepository.getReporteById(id: id);
      return reporte;
    } catch (e) {
      print('Error getting reporte by id: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Area> getAreaById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final area = await _adminActionRepository.getAreaById(id: id);
      return area;
    } catch (e) {
      print('Error getting area by id: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Prioridad> getPrioridadById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prioridad = await _adminActionRepository.getPrioridadById(id: id);
      return prioridad;
    } catch (e) {
      print('Error getting prioridad by id: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<EstadoReporte> getEstadoReporteById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final estadoReporte = await _adminActionRepository.getEstadoReporteById(
        id: id,
      );
      return estadoReporte;
    } catch (e) {
      print('Error getting estado reporte by id: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TipoReporte> getTipoReporteById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final tipoReporte = await _adminActionRepository.getTipoReporteById(
        id: id,
      );
      return tipoReporte;
    } catch (e) {
      print('Error getting tipo reporte by id: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  MÉTODO PARA CARGAR USUARIOS PÚBLICOS
  Future<void> loadUsuariosPublicos() async {
    try {
      _usuariosPublicos = await _adminActionRepository.getUsuariosPublicos();
      notifyListeners();
    } catch (e) {
      print('Error loading usuarios publicos: $e');
    }
  }

  // MÉTODO PARA OBTENER DETALLE DE REPORTE
  Future<DetalleReporte?> getDetalleReporteByReporteId(String reporteId) async {
    try {
      final detalle = await _adminActionRepository.getDetalleReporteByReporteId(
        reporteId: reporteId,
      );
      return detalle;
    } catch (e) {
      print('Error getting detalle reporte: $e');
      return null;
    }
  }

  // MÉTODO PARA ASIGNAR SOPORTE
  Future<bool> asignarSoporte({
    required String reporteId,
    required String soporteId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Primero buscar si existe un detalle_reporte
      DetalleReporte? detalleActual = await _adminActionRepository
          .getDetalleReporteByReporteId(reporteId: reporteId);

      if (detalleActual == null) {
        final nuevoDetalle = DetalleReporte(
          id: '', // Se generará automáticamente en Supabase
          createdAt: DateTime.now().toIso8601String(),
          idReporteIncidencia: reporteId,
          idSoporteAsignado: soporteId,
          descripcion: null,
          observaciones: null,
          fechaAsignacion: DateTime.now().toIso8601String(),
          fechaSolucion: null, // null por defecto
        );

        final nuevoId = await _adminActionRepository.createDetalleReporte(
          nuevoDetalle,
        );
        return nuevoId != null;
      } else {
        // Si existe, actualizarlo
        final detalleActualizado = detalleActual.copyWith(
          idSoporteAsignado: soporteId,
          fechaAsignacion: DateTime.now().toIso8601String(),
        );

        await _adminActionRepository.updateDetalleReporte(detalleActualizado);
        return true;
      }
    } catch (e) {
      print('Error asignando soporte: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MÉTODO HELPER PARA BUSCAR NOMBRE DEL SOPORTE
  String getNombreSoporteAsignado(String? idSoporte) {
    if (idSoporte == null) return 'Sin asignar';

    try {
      final usuario = _usuariosPublicos.firstWhere((u) => u.id == idSoporte);
      return usuario.nombre;
    } catch (e) {
      return 'Soporte no encontrado';
    }
  }

  // MÉTODO PARA GENERAR Y SUBIR REQUERIMIENTO PDF
  Future<bool> generarRequerimientoPDF({required String reporteId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Obtener el reporte completo
      final reporte = await getReporteById(reporteId);

      // 2. Obtener datos relacionados
      String areaNombre = 'No disponible';
      String tipoReporteNombre = 'No disponible';
      String prioridadNombre = 'No disponible';
      String nombreUsuario = 'No disponible';
      String nombreSoporte = 'Sin asignar';

      try {
        final area = _areas.firstWhere((a) => a.id == reporte.idArea);
        areaNombre = area.nombre;
      } catch (e) {}

      try {
        final tipoReporte = _tiposReporte.firstWhere(
          (t) => t.id == reporte.idTipoReporte,
        );
        tipoReporteNombre = tipoReporte.nombre;
      } catch (e) {}

      try {
        final prioridad = _prioridades.firstWhere(
          (p) => p.id == reporte.idPrioridad,
        );
        prioridadNombre = prioridad.nombre;
      } catch (e) {}

      try {
        final usuario = _usuariosPublicos.firstWhere(
          (u) => u.id == reporte.idUsuario,
        );
        nombreUsuario = usuario.nombre;
      } catch (e) {}

      // Obtener nombre del soporte si está asignado
      final detalleReporte = await getDetalleReporteByReporteId(reporteId);
      if (detalleReporte?.idSoporteAsignado != null) {
        nombreSoporte = getNombreSoporteAsignado(
          detalleReporte!.idSoporteAsignado,
        );
      }

      // 3. Generar PDF
      final File pdfFile = await _pdfService.generarReportePDF(
        reporte: reporte,
        detalleReporte: detalleReporte,
        areaNombre: areaNombre,
        tipoReporteNombre: tipoReporteNombre,
        prioridadNombre: prioridadNombre,
        nombreUsuario: nombreUsuario,
        nombreSoporte: nombreSoporte,
      );

      // 4. Subir a Cloudinary
      final String? pdfUrl = await _cloudinaryService.uploadPDF(pdfFile);
      if (pdfUrl == null) {
        throw Exception('Error al subir el PDF');
      }

      // 5. Guardar en base de datos
      final archivoRequerimiento = AdjuntarArchivoRequerimiento(
        id: '',
        createdAt: DateTime.now().toIso8601String(),
        pdfUrl: pdfUrl,
        idReporte: reporteId,
      );

      final archivoId = await _adminActionRepository.createArchivoRequerimiento(
        archivoRequerimiento,
      );
      if (archivoId == null) {
        throw Exception('Error al guardar el archivo en la base de datos');
      }

      // 6. Cambiar estado del reporte a "En espera (Repuestos)"
      await _cambiarEstadoReporte(reporteId, 'En espera (Repuestos)');

      // 7. Limpiar archivo temporal
      await pdfFile.delete();

      return true;
    } catch (e) {
      print('Error generando requerimiento PDF: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MÉTODO PRIVADO PARA CAMBIAR ESTADO DEL REPORTE
  Future<void> _cambiarEstadoReporte(
    String reporteId,
    String nuevoEstado,
  ) async {
    try {
      // Buscar el ID del estado "En espera (Repuestos)"
      final estadoEspera = _estadosReporte.firstWhere(
        (estado) =>
            estado.nombre.toLowerCase().contains('espera') &&
            estado.nombre.toLowerCase().contains('repuesto'),
        orElse: () =>
            throw Exception('No se encontró el estado "En espera (Repuestos)"'),
      );

      // Obtener el reporte actual
      final reporteActual = await getReporteById(reporteId);

      // Actualizar el reporte con el nuevo estado
      final reporteActualizado = reporteActual.copyWith(
        idEstadoReporte: estadoEspera.id,
      );

      await _adminActionRepository.updateReporte(reporteActualizado);
    } catch (e) {
      print('Error cambiando estado del reporte: $e');
      rethrow;
    }
  }

  // MÉTODO PARA VERIFICAR SI YA EXISTE UN REQUERIMIENTO
  Future<bool> tieneRequerimientoPDF(String reporteId) async {
    try {
      final archivo = await _adminActionRepository
          .getArchivoRequerimientoByReporteId(reporteId);
      return archivo != null;
    } catch (e) {
      return false;
    }
  }

  Future<AdjuntarArchivoRequerimiento?> getArchivoRequerimientoByReporteId(
    String reporteId,
  ) async {
    try {
      return await _adminActionRepository.getArchivoRequerimientoByReporteId(
        reporteId,
      );
    } catch (e) {
      print('Error getting archivo requerimiento: $e');
      return null;
    }
  }

  // En lib/features/admin/presentation/providers/admin_action_provider.dart
  Future<bool> actualizarInformacionTecnica({
    required String reporteId,
    required String descripcion,
    required String observaciones,
    required String repuestosRequeridos,
    required String justificacionRepuestos,
  }) async {
    try {
      return await _adminActionRepository.actualizarInformacionTecnica(
        reporteId: reporteId,
        descripcion: descripcion,
        observaciones: observaciones,
        repuestosRequeridos: repuestosRequeridos,
        justificacionRepuestos: justificacionRepuestos,
      );
    } catch (e) {
      print('Error actualizando información técnica: $e');
      return false;
    }
  }

  Future<bool> cambiarEstadoReporte({
    required String reporteId,
    required String nuevoEstadoId,
  }) async {
    try {
      return await _adminActionRepository.cambiarEstadoReporte(
        reporteId: reporteId,
        nuevoEstadoId: nuevoEstadoId,
      );
    } catch (e) {
      print('Error cambiando estado del reporte: $e');
      return false;
    }
  }

  Future<List<ReporteIncidencia>> getReportesBySoporteId(
    String soporteId,
  ) async {
    try {
      return await _adminActionRepository.getReportesBySoporteId(soporteId);
    } catch (e) {
      print('Error obteniendo reportes del soporte: $e');
      return [];
    }
  }

  // Método para obtener estadísticas de reportes
  Map<String, int> getReportsStatistics() {
    if (_reportes.isEmpty) {
      return {'resueltos': 0, 'sinAtender': 0, 'enProceso': 0, 'enEspera': 0};
    }

    int resueltos = 0;
    int sinAtender = 0;
    int enProceso = 0;
    int enEspera = 0;

    for (final reporte in _reportes) {
      switch (reporte.idEstadoReporte) {
        case "52c2b7bc-194c-4759-b83c-3913625da86d": // Resuelto
          resueltos++;
          break;
        case "29e11cdf-fcf7-4c36-a7fd-f363dcaf864c": // Nuevo (sin atender)
          sinAtender++;
          break;
        case "cb56bfbe-6fd4-4d0b-ad5b-3bb31194e223": // En proceso
          enProceso++;
          break;
        case "afab4980-5c12-4457-88a2-c3cd0bb198e1": // En espera
          enEspera++;
          break;
        default:
          print('Estado desconocido: ${reporte.idEstadoReporte}');
          break;
      }
    }

    return {
      'resueltos': resueltos,
      'sinAtender': sinAtender,
      'enProceso': enProceso,
      'enEspera': enEspera,
    };
  }

  // Método para obtener estadísticas con nombres de estados dinámicos
  Map<String, int> getReportsStatisticsByName() {
    if (_reportes.isEmpty || _estadosReporte.isEmpty) {
      return {
        'Resueltos': 0,
        'Sin Atender': 0,
        'En Proceso': 0,
        'En Espera': 0,
      };
    }

    Map<String, int> estadisticas = {};

    // Inicializar contadores
    for (final estado in _estadosReporte) {
      estadisticas[estado.nombre] = 0;
    }

    // Contar reportes por estado
    for (final reporte in _reportes) {
      final estado = _estadosReporte.firstWhere(
        (e) => e.id == reporte.idEstadoReporte,
        orElse: () => EstadoReporte(
          id: '',
          nombre: 'Desconocido',
          descripcion: '',
          createdAt: '',
        ),
      );

      if (estadisticas.containsKey(estado.nombre)) {
        estadisticas[estado.nombre] = estadisticas[estado.nombre]! + 1;
      }
    }

    return estadisticas;
  }

  // Método para obtener el total de reportes
  int getTotalReports() {
    return _reportes.length;
  }

  // Método para obtener reportes del último mes
  int getReportsThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _reportes.where((reporte) {
      if (reporte.createdAt == null) return false;
      try {
        final reportDate = DateTime.parse(reporte.createdAt!);
        return reportDate.isAfter(startOfMonth);
      } catch (e) {
        return false;
      }
    }).length;
  }

  // Método para obtener reportes de hoy
  int getReportsToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _reportes.where((reporte) {
      if (reporte.createdAt == null) return false;
      try {
        final reportDate = DateTime.parse(reporte.createdAt!);
        return reportDate.isAfter(today) && reportDate.isBefore(tomorrow);
      } catch (e) {
        return false;
      }
    }).length;
  }

  Future<bool> generateMonthlyExcelReport(int month, int year) async {
    try {
      // Asegurar que todos los datos estén cargados
      await loadInitialData();
      await loadReportes();
      await loadDetallesReporte();

      // Crear mapas para facilitar la búsqueda
      final areasMap = <String, String>{};
      for (var area in areas) {
        areasMap[area.id] = area.nombre;
      }

      final tiposReporteMap = <String, String>{};
      for (var tipo in tiposReporte) {
        tiposReporteMap[tipo.id] = tipo.nombre;
      }

      final estadosMap = <String, String>{};
      for (var estado in estadosReporte) {
        estadosMap[estado.id] = estado.nombre;
      }

      final prioridadesMap = <String, String>{};
      for (var prioridad in prioridades) {
        prioridadesMap[prioridad.id] = prioridad.nombre;
      }

      final usuariosMap = <String, String>{};
      for (var usuario in usuariosPublicos) {
        usuariosMap[usuario.id] = usuario.nombre;
      }

      // Generar el reporte Excel
      return await ExcelReportService.generateMonthlyReport(
        reportes: reportes,
        detalles: detallesReporte,
        areas: areasMap,
        tiposReporte: tiposReporteMap,
        estados: estadosMap,
        prioridades: prioridadesMap,
        usuarios: usuariosMap,
        month: month,
        year: year,
      );
    } catch (e) {
      print('Error generando reporte Excel: $e');
      return false;
    }
  }

  // Método para obtener reportes de un mes específico
  List<ReporteIncidencia> getReportesByMonth(int month, int year) {
    return reportes.where((reporte) {
      if (reporte.createdAt == null) return false;
      try {
        final fecha = DateTime.parse(reporte.createdAt!);
        return fecha.month == month && fecha.year == year;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Método para obtener estadísticas de un mes específico
  Map<String, int> getMonthlyStatistics(int month, int year) {
    final reportesMes = getReportesByMonth(month, year);

    return {
      'total': reportesMes.length,
      'pendientes': reportesMes
          .where((r) => r.idEstadoReporte.contains('pendiente'))
          .length,
      'enProceso': reportesMes
          .where((r) => r.idEstadoReporte.contains('proceso'))
          .length,
      'completados': reportesMes
          .where((r) => r.idEstadoReporte.contains('completado'))
          .length,
      'cancelados': reportesMes
          .where((r) => r.idEstadoReporte.contains('cancelado'))
          .length,
    };
  }

  Map<String, int> getAnalyticsMonthlyStatistics(int month, int year) {
    final reportesMes = getReportesByMonth(month, year);

    if (reportesMes.isEmpty) {
      return {
        'total': 0,
        'resueltos': 0,
        'sinAtender': 0,
        'enProceso': 0,
        'enEspera': 0,
      };
    }

    int resueltos = 0;
    int sinAtender = 0;
    int enProceso = 0;
    int enEspera = 0;

    for (final reporte in reportesMes) {
      switch (reporte.idEstadoReporte) {
        case "52c2b7bc-194c-4759-b83c-3913625da86d": // Resuelto
          resueltos++;
          break;
        case "29e11cdf-fcf7-4c36-a7fd-f363dcaf864c": // Nuevo (sin atender)
          sinAtender++;
          break;
        case "cb56bfbe-6fd4-4d0b-ad5b-3bb31194e223": // En proceso
          enProceso++;
          break;
        case "afab4980-5c12-4457-88a2-c3cd0bb198e1": // En espera
          enEspera++;
          break;
        default:
          // Estados desconocidos se consideran "sin atender"
          sinAtender++;
          break;
      }
    }

    return {
      'total': reportesMes.length,
      'resueltos': resueltos,
      'sinAtender': sinAtender,
      'enProceso': enProceso,
      'enEspera': enEspera,
    };
  }

  List<DetalleReporte> _detallesReporte = [];

  List<DetalleReporte> get detallesReporte => _detallesReporte;

  Future<void> loadDetallesReporte() async {
    _isLoading = true;
    notifyListeners();
    try {
      _detallesReporte = await _adminActionRepository.getDetallesReporte();
    } catch (e) {
      print('Error loading detalles reporte: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> asignarSoporteConEstado({
    required String reporteId,
    required String soporteId,
  }) async {
    try {
      print('Asignando soporte con cambio automático de estado...');

      // PASO 1: Asignar el soporte
      final successAsignacion = await asignarSoporte(
        reporteId: reporteId,
        soporteId: soporteId,
      );

      if (!successAsignacion) {
        print('Error en la asignación de soporte');
        return false;
      }

      // PASO 2: Buscar el estado "Asignado"
      String? estadoAsignadoId;
      try {
        final estadoAsignado = estadosReporte.firstWhere(
          (estado) => estado.nombre.toLowerCase().contains('asignado'),
        );
        estadoAsignadoId = estadoAsignado.id;
      } catch (e) {
        // Fallback al ID conocido
        estadoAsignadoId = "60af230d-a751-4dbe-9ecb-b101ffcb828b";
      }

      // PASO 3: Cambiar el estado automáticamente
      final successEstado = await cambiarEstadoReporte(
        reporteId: reporteId,
        nuevoEstadoId: estadoAsignadoId,
      );

      if (successEstado) {
        print('Soporte asignado y estado actualizado automáticamente');
        notifyListeners();
        return true;
      } else {
        print('Soporte asignado pero no se pudo actualizar el estado');
        return true; // Consideramos exitoso porque la asignación sí funcionó
      }
    } catch (e) {
      print('Error en asignarSoporteConEstado: $e');
      return false;
    }
  }
}
