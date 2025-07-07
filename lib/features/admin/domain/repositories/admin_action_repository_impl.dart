import 'package:app_reporte_iestp_sullana/features/admin/data/datasources/supabase_admin_action_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/adjuntar_archivo_requerimiento.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/models.dart';
import 'package:app_reporte_iestp_sullana/features/admin/domain/repositories/admin_action_repository.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';

class AdminActionRepositoryImpl implements AdminActionRepository {
  final AdminActionDataSource _userActionDataSource;
  AdminActionRepositoryImpl(this._userActionDataSource);

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
  Future<void> deleteReporte(String reporteId) {
    return _userActionDataSource.deleteReporte(reporteId);
  }

  @override
  Future<List<ReporteIncidencia>> getReporte() {
    return _userActionDataSource.getReporte();
  }

  @override
  Future<ReporteIncidencia> getReporteById({required String id}) {
    return _userActionDataSource.getReporteById(id: id);
  }

  //Area
  @override
  Future<String?> createArea(Area area) {
    return _userActionDataSource.createArea(area);
  }

  @override
  Future<void> updateArea(Area area) {
    return _userActionDataSource.updateArea(area);
  }

  @override
  Future<void> deleteArea(String areaId) {
    return _userActionDataSource.deleteArea(areaId);
  }

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
  Future<String?> createPrioridad(Prioridad prioridad) {
    return _userActionDataSource.createPrioridad(prioridad);
  }

  @override
  Future<void> updatePrioridad(Prioridad prioridad) {
    return _userActionDataSource.updatePrioridad(prioridad);
  }

  @override
  Future<void> deletePrioridad(String prioridadId) {
    return _userActionDataSource.deletePrioridad(prioridadId);
  }

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
  Future<String?> createEstadoReporte(EstadoReporte estadoReporte) {
    return _userActionDataSource.createEstadoReporte(estadoReporte);
  }

  @override
  Future<void> updateEstadoReporte(EstadoReporte estadoReporte) {
    return _userActionDataSource.updateEstadoReporte(estadoReporte);
  }

  @override
  Future<void> deleteEstadoReporte(String estadoReporteId) {
    return _userActionDataSource.deleteEstadoReporte(estadoReporteId);
  }

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
  Future<String?> createTipoReporte(TipoReporte tipoReporte) {
    return _userActionDataSource.createTipoReporte(tipoReporte);
  }

  @override
  Future<void> updateTipoReporte(TipoReporte tipoReporte) {
    return _userActionDataSource.updateTipoReporte(tipoReporte);
  }

  @override
  Future<void> deleteTipoReporte(String tipoReporteId) {
    return _userActionDataSource.deleteTipoReporte(tipoReporteId);
  }

  @override
  Future<List<TipoReporte>> getTipoReporte() {
    return _userActionDataSource.getTipoReporte();
  }

  @override
  Future<TipoReporte> getTipoReporteById({required String id}) {
    return _userActionDataSource.getTipoReporteById(id: id);
  }

  // IMPLEMENTACIÓN DE DETALLE REPORTE
  @override
  Future<DetalleReporte?> getDetalleReporteByReporteId({
    required String reporteId,
  }) {
    return _userActionDataSource.getDetalleReporteByReporteId(
      reporteId: reporteId,
    );
  }

  @override
  Future<void> updateDetalleReporte(DetalleReporte detalleReporte) {
    return _userActionDataSource.updateDetalleReporte(detalleReporte);
  }

  @override
  Future<String?> createDetalleReporte(DetalleReporte detalleReporte) {
    return _userActionDataSource.createDetalleReporte(detalleReporte);
  }

  // IMPLEMENTACIÓN DE USUARIOS PÚBLICOS
  @override
  Future<List<UsuarioPublico>> getUsuariosPublicos() {
    return _userActionDataSource.getUsuariosPublicos();
  }

  @override
  Future<String?> createArchivoRequerimiento(
    AdjuntarArchivoRequerimiento archivo,
  ) {
    return _userActionDataSource.createArchivoRequerimiento(archivo);
  }

  @override
  Future<AdjuntarArchivoRequerimiento?> getArchivoRequerimientoByReporteId(
    String reporteId,
  ) {
    return _userActionDataSource.getArchivoRequerimientoByReporteId(reporteId);
  }

  @override
  Future<List<ReporteIncidencia>> getReportesBySoporteId(String soporteId) {
    return _userActionDataSource.getReportesBySoporteId(soporteId);
  }

  @override
  Future<bool> actualizarInformacionTecnica({
    required String reporteId,
    required String descripcion,
    required String observaciones,
    required String repuestosRequeridos,
    required String justificacionRepuestos,
  }) async {
    try {
      return await _userActionDataSource.actualizarInformacionTecnica(
        reporteId: reporteId,
        descripcion: descripcion,
        observaciones: observaciones,
        repuestosRequeridos: repuestosRequeridos,
        justificacionRepuestos: justificacionRepuestos,
      );
    } catch (e) {
      throw Exception('Error actualizando información técnica: $e');
    }
  }

  @override
  Future<bool> cambiarEstadoReporte({
    required String reporteId,
    required String nuevoEstadoId,
  }) async {
    try {
      return await _userActionDataSource.cambiarEstadoReporte(
        reporteId: reporteId,
        nuevoEstadoId: nuevoEstadoId,
      );
    } catch (e) {
      throw Exception('Error cambiando estado del reporte: $e');
    }
  }

  @override
  Future<List<DetalleReporte>> getDetallesReporte() async {
    return await _userActionDataSource.getDetallesReporte();
  }
}
