import 'package:app_reporte_iestp_sullana/features/admin/data/models/adjuntar_archivo_requerimiento.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/models.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AdminActionDataSource {
  //Reportes
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
  // MÉTODOS PARA ARCHIVO REQUERIMIENTO
  Future<String?> createArchivoRequerimiento(
    AdjuntarArchivoRequerimiento archivo,
  );
  Future<AdjuntarArchivoRequerimiento?> getArchivoRequerimientoByReporteId(
    String reporteId,
  );
  //Tipo Reporte
  Future<String?> createTipoReporte(TipoReporte tipoReporte);
  Future<void> updateTipoReporte(TipoReporte tipoReporte);
  Future<void> deleteTipoReporte(String tipoReporteId);
  Future<List<TipoReporte>> getTipoReporte();
  Future<TipoReporte> getTipoReporteById({required String id});
  //  DETALLE REPORTE
  Future<DetalleReporte?> getDetalleReporteByReporteId({
    required String reporteId,
  });
  Future<List<DetalleReporte>> getDetallesReporte();
  Future<List<ReporteIncidencia>> getReportesBySoporteId(String soporteId);
  Future<void> updateDetalleReporte(DetalleReporte detalleReporte);
  Future<String?> createDetalleReporte(DetalleReporte detalleReporte);

  //  PÚBLICOS
  Future<List<UsuarioPublico>> getUsuariosPublicos();

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
}

class SupabaseAdminActionDataSourceImpl implements AdminActionDataSource {
  final _supabase = Supabase.instance.client;

  //Reporte Incidencia
  @override
  Future<String?> createReporte(ReporteIncidencia reporte) async {
    try {
      final reponse = await _supabase
          .from('reporte_incidencia')
          .insert(reporte.toJson())
          .select()
          .single();
      return reponse['id'] as String?;
    } catch (e) {
      print('Error creating reporte: $e');
      return null;
    }
  }

  @override
  Future<void> updateReporte(ReporteIncidencia reporte) async {
    try {
      await _supabase
          .from('reporte_incidencia')
          .update(reporte.toJson())
          .eq('id', reporte.id.toString());
      print('Reporte updated successfully with ID: ${reporte.id}');
    } catch (e) {
      print('Error updating reporte: $e');
    }
  }

  @override
  Future<void> deleteReporte(String reporteId) async {
    try {
      await _supabase.from('reporte_incidencia').delete().eq('id', reporteId);
      print('Reporte deleted successfully with ID: $reporteId');
    } catch (e) {
      print('Error deleting reporte: $e');
    }
  }

  @override
  Future<List<ReporteIncidencia>> getReporte() async {
    try {
      final response = await _supabase
          .from('reporte_incidencia')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((item) => ReporteIncidencia.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching reportes: $e');
      return [];
    }
  }

  @override
  Future<ReporteIncidencia> getReporteById({required String id}) async {
    try {
      final response = await _supabase
          .from('reporte_incidencia')
          .select()
          .eq('id', id)
          .single();
      return ReporteIncidencia.fromJson(response);
    } catch (e) {
      print('Error fetching reporte by ID: $e');
      throw Exception('Error fetching reporte by ID');
    }
  }

  //Area
  @override
  Future<String?> createArea(Area area) async {
    try {
      final areaData = {'nombre': area.nombre};

      final response = await _supabase
          .from('area')
          .insert(areaData)
          .select()
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error creating area: $e');
      return null;
    }
  }

  @override
  Future<void> updateArea(Area area) async {
    try {
      await _supabase.from('area').update(area.toJson()).eq('id', area.id);
      print('Area updated successfully with ID: ${area.id}');
    } catch (e) {
      print('Error updating area: $e');
    }
  }

  @override
  Future<void> deleteArea(String areaId) async {
    try {
      await _supabase.from('area').delete().eq('id', areaId);
      print('Area deleted successfully with ID: $areaId');
    } catch (e) {
      print('Error deleting area: $e');
    }
  }

  @override
  Future<List<Area>> getArea() async {
    try {
      final response = await _supabase
          .from('area')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((item) => Area.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching areas: $e');
      return [];
    }
  }

  @override
  Future<Area> getAreaById({required String id}) async {
    try {
      final response = await _supabase
          .from('area')
          .select()
          .eq('id', id)
          .single();
      return Area.fromJson(response);
    } catch (e) {
      print('Error fetching area by ID: $e');
      throw Exception('Error fetching area by ID');
    }
  }

  //Prioridad
  @override
  Future<String?> createPrioridad(Prioridad prioridad) async {
    try {
      final prioridadData = {'nombre': prioridad.nombre};

      final response = await _supabase
          .from('prioridad')
          .insert(prioridadData)
          .select()
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error creating prioridad: $e');
      return null;
    }
  }

  @override
  Future<void> updatePrioridad(Prioridad prioridad) async {
    try {
      await _supabase
          .from('prioridad')
          .update(prioridad.toJson())
          .eq('id', prioridad.id);
      print('Prioridad updated successfully with ID: ${prioridad.id}');
    } catch (e) {
      print('Error updating prioridad: $e');
    }
  }

  @override
  Future<void> deletePrioridad(String prioridadId) async {
    try {
      await _supabase.from('prioridad').delete().eq('id', prioridadId);
      print('Prioridad deleted successfully with ID: $prioridadId');
    } catch (e) {
      print('Error deleting prioridad: $e');
    }
  }

  @override
  Future<List<Prioridad>> getPrioridad() async {
    try {
      final response = await _supabase
          .from('prioridad')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((item) => Prioridad.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching prioridades: $e');
      return [];
    }
  }

  @override
  Future<Prioridad> getPrioridadById({required String id}) async {
    try {
      final response = await _supabase
          .from('prioridad')
          .select()
          .eq('id', id)
          .single();
      return Prioridad.fromJson(response);
    } catch (e) {
      print('Error fetching prioridad by ID: $e');
      throw Exception('Error fetching prioridad by ID');
    }
  }

  //Estado Reporte
  @override
  Future<String?> createEstadoReporte(EstadoReporte estadoReporte) async {
    try {
      final estadoData = {
        'nombre': estadoReporte.nombre,
        'descripcion': estadoReporte.descripcion,
      };

      final response = await _supabase
          .from('estado_reporte')
          .insert(estadoData)
          .select()
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error creating estado reporte: $e');
      return null;
    }
  }

  @override
  Future<void> updateEstadoReporte(EstadoReporte estadoReporte) async {
    try {
      await _supabase
          .from('estado_reporte')
          .update(estadoReporte.toJson())
          .eq('id', estadoReporte.id);
      print('Estado Reporte updated successfully with ID: ${estadoReporte.id}');
    } catch (e) {
      print('Error updating estado reporte: $e');
    }
  }

  @override
  Future<void> deleteEstadoReporte(String estadoReporteId) async {
    try {
      await _supabase.from('estado_reporte').delete().eq('id', estadoReporteId);
      print('Estado Reporte deleted successfully with ID: $estadoReporteId');
    } catch (e) {
      print('Error deleting estado reporte: $e');
    }
  }

  @override
  Future<List<EstadoReporte>> getEstadoReporte() async {
    try {
      final response = await _supabase
          .from('estado_reporte')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((item) => EstadoReporte.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching estado reportes: $e');
      return [];
    }
  }

  @override
  Future<EstadoReporte> getEstadoReporteById({required String id}) async {
    try {
      final response = await _supabase
          .from('estado_reporte')
          .select()
          .eq('id', id)
          .single();
      return EstadoReporte.fromJson(response);
    } catch (e) {
      print('Error fetching estado reporte by ID: $e');
      throw Exception('Error fetching estado reporte by ID');
    }
  }

  //Tipo Reporte
  @override
  Future<String?> createTipoReporte(TipoReporte tipoReporte) async {
    try {
      final tipoData = {
        'nombre': tipoReporte.nombre,
        'descripcion': tipoReporte.descripcion,
      };

      final response = await _supabase
          .from('tipo_reporte')
          .insert(tipoData)
          .select()
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error creating tipo reporte: $e');
      return null;
    }
  }

  @override
  Future<void> updateTipoReporte(TipoReporte tipoReporte) async {
    try {
      await _supabase
          .from('tipo_reporte')
          .update(tipoReporte.toJson())
          .eq('id', tipoReporte.id);
      print('Tipo Reporte updated successfully with ID: ${tipoReporte.id}');
    } catch (e) {
      print('Error updating tipo reporte: $e');
    }
  }

  @override
  Future<void> deleteTipoReporte(String tipoReporteId) async {
    try {
      await _supabase.from('tipo_reporte').delete().eq('id', tipoReporteId);
      print('Tipo Reporte deleted successfully with ID: $tipoReporteId');
    } catch (e) {
      print('Error deleting tipo reporte: $e');
    }
  }

  @override
  Future<List<TipoReporte>> getTipoReporte() async {
    try {
      final response = await _supabase
          .from('tipo_reporte')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((item) => TipoReporte.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching tipo reportes: $e');
      return [];
    }
  }

  @override
  Future<TipoReporte> getTipoReporteById({required String id}) async {
    try {
      final response = await _supabase
          .from('tipo_reporte')
          .select()
          .eq('id', id)
          .single();
      return TipoReporte.fromJson(response);
    } catch (e) {
      print('Error fetching tipo reporte by ID: $e');
      throw Exception('Error fetching tipo reporte by ID');
    }
  }

  @override
  Future<DetalleReporte?> getDetalleReporteByReporteId({
    required String reporteId,
  }) async {
    try {
      final response = await _supabase
          .from('detalle_reporte')
          .select()
          .eq('id_reporte_incidencia', reporteId)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        print('No se encontró detalle_reporte para reporte: $reporteId');
        return null;
      }

      return DetalleReporte.fromJson(response);
    } catch (e) {
      print('Error fetching detalle reporte: $e');
      return null;
    }
  }

  @override
  Future<void> updateDetalleReporte(DetalleReporte detalleReporte) async {
    try {
      await _supabase
          .from('detalle_reporte')
          .update(detalleReporte.toJson())
          .eq('id', detalleReporte.id);
      print(
        'Detalle reporte updated successfully with ID: ${detalleReporte.id}',
      );
    } catch (e) {
      print('Error updating detalle reporte: $e');
      throw Exception('Error updating detalle reporte: $e');
    }
  }

  @override
  Future<String?> createDetalleReporte(DetalleReporte detalleReporte) async {
    try {
      final response = await _supabase
          .from('detalle_reporte')
          .insert(detalleReporte.toJson())
          .select()
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error creating detalle reporte: $e');
      return null;
    }
  }

  // IMPLEMENTACIÓN DE USUARIOS PÚBLICOS
  @override
  Future<List<UsuarioPublico>> getUsuariosPublicos() async {
    try {
      final response = await _supabase
          .from('usuario_publico')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => UsuarioPublico.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching usuarios publicos: $e');
      return [];
    }
  }

  @override
  Future<String?> createArchivoRequerimiento(
    AdjuntarArchivoRequerimiento archivo,
  ) async {
    try {
      final dataToInsert = {
        "pdf_url": archivo.pdfUrl,
        "id_reporte": archivo.idReporte,
      };

      final response = await _supabase
          .from('adjuntar_archivo_requerimiento')
          .insert(dataToInsert)
          .select()
          .single();

      return response['id'] as String?;
    } catch (e) {
      print('Error creating archivo requerimiento: $e');
      return null;
    }
  }

  @override
  Future<AdjuntarArchivoRequerimiento?> getArchivoRequerimientoByReporteId(
    String reporteId,
  ) async {
    try {
      final response = await _supabase
          .from('adjuntar_archivo_requerimiento')
          .select()
          .eq('id_reporte', reporteId)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return AdjuntarArchivoRequerimiento.fromJson(response);
    } catch (e) {
      print('Error fetching archivo requerimiento: $e');
      return null;
    }
  }

  // Método para obtener reportes asignados a un soporte técnico específico
  @override
  Future<List<ReporteIncidencia>> getReportesBySoporteId(
    String soporteId,
  ) async {
    try {
      final response = await _supabase
          .from('detalle_reporte')
          .select('''
          id_reporte_incidencia,
          reporte_incidencia:id_reporte_incidencia (
            id,
            created_at,
            descripcion,
            id_area,
            id_tipo_reporte,
            id_prioridad,
            id_estado_reporte,
            id_usuario,
            url_img
          )
        ''')
          .eq('id_soporte_asignado', soporteId);

      if (response.isEmpty) return [];

      return response
          .map((item) => ReporteIncidencia.fromJson(item['reporte_incidencia']))
          .toList();
    } catch (e) {
      print('Error getting reportes by soporte: $e');
      throw Exception('Error al obtener reportes del soporte: $e');
    }
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
      print('Actualizando información técnica para reporte: $reporteId');

      // Verificar si existe un detalle_reporte para este reporte
      final existingDetailResponse = await _supabase
          .from('detalle_reporte')
          .select('id')
          .eq('id_reporte_incidencia', reporteId)
          .maybeSingle();

      if (existingDetailResponse != null) {
        // Actualizar registro existente
        final response = await _supabase
            .from('detalle_reporte')
            .update({
              'descripcion': descripcion.isEmpty ? null : descripcion,
              'observaciones': observaciones.isEmpty ? null : observaciones,
              'repuestos_requeridos': repuestosRequeridos.isEmpty
                  ? null
                  : repuestosRequeridos,
              'justificacion_repuestos': justificacionRepuestos.isEmpty
                  ? null
                  : justificacionRepuestos,
            })
            .eq('id_reporte_incidencia', reporteId);

        print('Información técnica actualizada exitosamente');
        return true;
      } else {
        print('No se encontró detalle_reporte para el reporte: $reporteId');
        return false;
      }
    } catch (e) {
      print('Error actualizando información técnica: $e');
      return false;
    }
  }

  @override
  Future<bool> cambiarEstadoReporte({
    required String reporteId,
    required String nuevoEstadoId,
  }) async {
    try {
      print(
        'Cambiando estado del reporte: $reporteId a estado: $nuevoEstadoId',
      );

      final response = await _supabase
          .from('reporte_incidencia')
          .update({'id_estado_reporte': nuevoEstadoId})
          .eq('id', reporteId);

      print('Estado del reporte cambiado exitosamente');
      return true;
    } catch (e) {
      print('Error cambiando estado del reporte: $e');
      return false;
    }
  }

  @override
  Future<List<DetalleReporte>> getDetallesReporte() async {
    try {
      final response = await _supabase
          .from('detalle_reporte')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((detalle) => DetalleReporte.fromJson(detalle))
          .toList();
    } catch (e) {
      print('Error getting detalles reporte: $e');
      throw Exception('Error al obtener detalles de reporte: $e');
    }
  }
}
