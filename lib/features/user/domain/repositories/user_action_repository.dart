import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/area.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/estado_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/prioridad.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/reporte_incidencia.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/tipo_reporte.dart';

abstract class UserActionRepository {
  //Reporte
  Future<String?> createReporte(ReporteIncidencia reporte);
  Future<void> updateReporte(ReporteIncidencia reporte);
  Future<List<ReporteIncidencia>> getReporte();
  Future<ReporteIncidencia> getReporteById({required String id});
  Future<List<ReporteIncidencia>> getReporteByUserId({required String userId});

  //area
  Future<List<Area>> getArea();
  Future<Area> getAreaById({required String id});

  //Prioridad
  Future<List<Prioridad>> getPrioridad();
  Future<Prioridad> getPrioridadById({required String id});

  //Estado Reporte
  Future<List<EstadoReporte>> getEstadoReporte();
  Future<EstadoReporte> getEstadoReporteById({required String id});

  //Tipo Reporte
  Future<List<TipoReporte>> getTipoReporte();
  Future<TipoReporte> getTipoReporteById({required String id});

  Future<DetalleReporte?> getDetalleReporteByReporteId({
    required String reporteId,
  });
  // Usuario Público
  Future<List<UsuarioPublico>> getUsuariosPublicos();
  Future<UsuarioPublico?> getUsuarioPublicoById({required String id});
}
