import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/area.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/estado_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/prioridad.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/reporte_incidencia.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/tipo_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/user/domain/repositories/user_action_repository.dart';
import 'package:flutter/material.dart';

class UserActionProvider extends ChangeNotifier {
  final UserActionRepository _userActionRepository;
  UserActionProvider(this._userActionRepository);

  List<ReporteIncidencia> _reportes = [];
  List<Area> _areas = [];
  List<EstadoReporte> _estadosReporte = [];
  List<TipoReporte> _tiposReporte = [];
  List<Prioridad> _prioridades = [];

  List<UsuarioPublico> _usuariosPublicos = [];

  List<UsuarioPublico> get usuariosPublicos => _usuariosPublicos;

  List<ReporteIncidencia> get reportes => _reportes;

  // GETTERS MODIFICADOS: Ahora devuelven listas ordenadas alfabéticamente
  List<Area> get areas {
    final sortedAreas = List<Area>.from(_areas);
    sortedAreas.sort((a, b) => a.nombre.compareTo(b.nombre));
    return sortedAreas;
  }

  List<EstadoReporte> get estadosReporte {
    final sortedEstados = List<EstadoReporte>.from(_estadosReporte);
    sortedEstados.sort((a, b) => a.nombre.compareTo(b.nombre));
    return sortedEstados;
  }

  List<TipoReporte> get tiposReporte {
    final sortedTipos = List<TipoReporte>.from(_tiposReporte);
    sortedTipos.sort((a, b) => a.nombre.compareTo(b.nombre));
    return sortedTipos;
  }

  List<Prioridad> get prioridades {
    final sortedPrioridades = List<Prioridad>.from(_prioridades);
    sortedPrioridades.sort((a, b) => a.nombre.compareTo(b.nombre));
    return sortedPrioridades;
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Cargar usuarios públicos
  Future<void> loadUsuariosPublicos() async {
    try {
      _usuariosPublicos = await _userActionRepository.getUsuariosPublicos();
      // Ordenar usuarios públicos también
      _usuariosPublicos.sort((a, b) => a.nombre.compareTo(b.nombre));
      notifyListeners();
    } catch (e) {
      print('Error loading usuarios publicos: $e');
    }
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _areas = await _userActionRepository.getArea();
      _estadosReporte = await _userActionRepository.getEstadoReporte();
      _tiposReporte = await _userActionRepository.getTipoReporte();
      _prioridades = await _userActionRepository.getPrioridad();

      // OPCIONAL: Ordenar directamente las listas privadas también
      _areas.sort((a, b) => a.nombre.compareTo(b.nombre));
      _estadosReporte.sort((a, b) => a.nombre.compareTo(b.nombre));
      _tiposReporte.sort((a, b) => a.nombre.compareTo(b.nombre));
      _prioridades.sort((a, b) => a.nombre.compareTo(b.nombre));
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserReports(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Cargar solo los reportes del usuario específico
      _reportes = await _userActionRepository.getReporteByUserId(
        userId: userId,
      );

      // Cargar el resto de datos si no están cargados
      if (_areas.isEmpty) {
        _areas = await _userActionRepository.getArea();
        _estadosReporte = await _userActionRepository.getEstadoReporte();
        _tiposReporte = await _userActionRepository.getTipoReporte();
        _prioridades = await _userActionRepository.getPrioridad();

        // Ordenar las listas cargadas
        _areas.sort((a, b) => a.nombre.compareTo(b.nombre));
        _estadosReporte.sort((a, b) => a.nombre.compareTo(b.nombre));
        _tiposReporte.sort((a, b) => a.nombre.compareTo(b.nombre));
        _prioridades.sort((a, b) => a.nombre.compareTo(b.nombre));
      }
    } catch (e) {
      print('Error loading user reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //crear un reporte
  Future<String?> createReporte(ReporteIncidencia reporte) async {
    _isLoading = true;
    notifyListeners();
    try {
      final id = await _userActionRepository.createReporte(reporte);
      if (id != null) {
        _reportes.add(reporte.copyWith(id: id));
        notifyListeners();
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

  // Actualizar un reporte
  Future<void> updateReporte(ReporteIncidencia reporte) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _userActionRepository.updateReporte(reporte);
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

  Future<ReporteIncidencia> getReporteById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final reporte = await _userActionRepository.getReporteById(id: id);
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
      final area = await _userActionRepository.getAreaById(id: id);
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
      final prioridad = await _userActionRepository.getPrioridadById(id: id);
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
      final estadoReporte = await _userActionRepository.getEstadoReporteById(
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
      final tipoReporte = await _userActionRepository.getTipoReporteById(
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

  // Obtener detalle de reporte
  Future<DetalleReporte?> getDetalleReporteByReporteId(String reporteId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final detalle = await _userActionRepository.getDetalleReporteByReporteId(
        reporteId: reporteId,
      );
      return detalle;
    } catch (e) {
      print('Error getting detalle reporte: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método helper para buscar nombre del soporte
  String getNombreSoporteAsignado(String? idSoporte) {
    if (idSoporte == null) return 'Sin asignar';

    try {
      final usuario = _usuariosPublicos.firstWhere((u) => u.id == idSoporte);
      return usuario.nombre;
    } catch (e) {
      return 'Soporte no encontrado';
    }
  }

  // Obtener usuario público por ID
  Future<UsuarioPublico?> getUsuarioPublicoById(String id) async {
    try {
      final usuario = await _userActionRepository.getUsuarioPublicoById(id: id);
      return usuario;
    } catch (e) {
      print('Error getting usuario publico by id: $e');
      return null;
    }
  }
}
