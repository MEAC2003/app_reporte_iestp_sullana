import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/datasources/supabase_user_action_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/area.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/estado_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/prioridad.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/reporte_incidencia.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/tipo_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/user/domain/repositories/user_action_repository.dart';

class UserActionRepositoryImpl implements UserActionRepository {
  final UserActionDataSource _userActionDataSource;
  UserActionRepositoryImpl(this._userActionDataSource);

  //Reporte
  @override
  Future<String?> createReporte(ReporteIncidencia reporte) {
    return _userActionDataSource.createReporte(reporte);
  }

  @override
  Future<void> updateReporte(ReporteIncidencia reporte) {
    return _userActionDataSource.updateReporte(reporte);
  }

  @override
  Future<List<ReporteIncidencia>> getReporte() {
    return _userActionDataSource.getReporte();
  }

  @override
  Future<ReporteIncidencia> getReporteById({required String id}) {
    return _userActionDataSource.getReporteById(id: id);
  }

  @override
  Future<List<ReporteIncidencia>> getReporteByUserId({required String userId}) {
    return _userActionDataSource.getReporteByUserId(userId: userId);
  }

  //Area
  @override
  Future<List<Area>> getArea() {
    return _userActionDataSource.getArea();
  }

  @override
  Future<Area> getAreaById({required String id}) {
    return _userActionDataSource.getAreaById(id: id);
  }

  // Prioridad
  @override
  Future<List<Prioridad>> getPrioridad() {
    return _userActionDataSource.getPrioridad();
  }

  @override
  Future<Prioridad> getPrioridadById({required String id}) {
    return _userActionDataSource.getPrioridadById(id: id);
  }

  // Estado Reporte
  @override
  Future<List<EstadoReporte>> getEstadoReporte() {
    return _userActionDataSource.getEstadoReporte();
  }

  @override
  Future<EstadoReporte> getEstadoReporteById({required String id}) {
    return _userActionDataSource.getEstadoReporteById(id: id);
  }

  // Tipo Reporte
  @override
  Future<List<TipoReporte>> getTipoReporte() {
    return _userActionDataSource.getTipoReporte();
  }

  @override
  Future<TipoReporte> getTipoReporteById({required String id}) {
    return _userActionDataSource.getTipoReporteById(id: id);
  }

  // Detalle Reporte
  @override
  Future<DetalleReporte?> getDetalleReporteByReporteId({
    required String reporteId,
  }) {
    return _userActionDataSource.getDetalleReporteByReporteId(
      reporteId: reporteId,
    );
  }

  // Usuario Público
  @override
  Future<List<UsuarioPublico>> getUsuariosPublicos() {
    return _userActionDataSource.getUsuariosPublicos();
  }

  @override
  Future<UsuarioPublico?> getUsuarioPublicoById({required String id}) {
    return _userActionDataSource.getUsuarioPublicoById(id: id);
  }
}
