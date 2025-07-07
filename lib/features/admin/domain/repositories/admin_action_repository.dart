import 'package:app_reporte_iestp_sullana/features/admin/data/models/adjuntar_archivo_requerimiento.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/models.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';

abstract class AdminActionRepository {
  //Reporte
  Future<String?> createReporte(ReporteIncidencia reporte);
  Future<void> updateReporte(ReporteIncidencia reporte);
  Future<void> deleteReporte(String reporteId);
  Future<List<ReporteIncidencia>> getReporte();
  Future<ReporteIncidencia> getReporteById({required String id});

  //area
  Future<String?> createArea(Area area);
  Future<void> updateArea(Area area);
  Future<void> deleteArea(String areaId);
  Future<List<Area>> getArea();
  Future<Area> getAreaById({required String id});

  //Prioridad
  Future<String?> createPrioridad(Prioridad prioridad);
  Future<void> updatePrioridad(Prioridad prioridad);
  Future<void> deletePrioridad(String prioridadId);
  Future<List<Prioridad>> getPrioridad();
  Future<Prioridad> getPrioridadById({required String id});

  //Estado Reporte
  Future<String?> createEstadoReporte(EstadoReporte estadoReporte);
  Future<void> updateEstadoReporte(EstadoReporte estadoReporte);
  Future<void> deleteEstadoReporte(String estadoReporteId);
  Future<List<EstadoReporte>> getEstadoReporte();
  Future<EstadoReporte> getEstadoReporteById({required String id});

  //Tipo Reporte
  Future<String?> createTipoReporte(TipoReporte tipoReporte);
  Future<void> updateTipoReporte(TipoReporte tipoReporte);
  Future<void> deleteTipoReporte(String tipoReporteId);
  Future<List<TipoReporte>> getTipoReporte();
  Future<TipoReporte> getTipoReporteById({required String id});

  //  MÉTODOS PARA DETALLE REPORTE
  Future<DetalleReporte?> getDetalleReporteByReporteId({
    required String reporteId,
  });
  Future<void> updateDetalleReporte(DetalleReporte detalleReporte);
  Future<String?> createDetalleReporte(DetalleReporte detalleReporte);

  // MÉTODOS PARA USUARIOS PÚBLICOS
  Future<List<UsuarioPublico>> getUsuariosPublicos();

  Future<String?> createArchivoRequerimiento(
    AdjuntarArchivoRequerimiento archivo,
  );
  Future<AdjuntarArchivoRequerimiento?> getArchivoRequerimientoByReporteId(
    String reporteId,
  );

  Future<List<ReporteIncidencia>> getReportesBySoporteId(String soporteId);
  Future<bool> actualizarInformacionTecnica({
    required String reporteId,
    required String descripcion,
    required String observaciones,
    required String repuestosRequeridos,
    required String justificacionRepuestos,
  });

  Future<bool> cambiarEstadoReporte({
    required String reporteId,
    required String nuevoEstadoId,
  });

  Future<List<DetalleReporte>> getDetallesReporte();
}
