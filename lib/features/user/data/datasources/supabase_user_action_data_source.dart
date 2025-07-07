import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/area.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/estado_reporte.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/prioridad.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/reporte_incidencia.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/models/tipo_reporte.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class UserActionDataSource {
  //Reportes
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
  //Detalle Reporte
  Future<DetalleReporte?> getDetalleReporteByReporteId({
    required String reporteId,
  });

  // Usuario Público
  Future<List<UsuarioPublico>> getUsuariosPublicos();
  Future<UsuarioPublico?> getUsuarioPublicoById({required String id});
}

class SupabaseUserActionDataSourceImpl implements UserActionDataSource {
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

  @override
  Future<List<ReporteIncidencia>> getReporteByUserId({
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('reporte_incidencia')
          .select()
          .eq('id_usuario', userId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((item) => ReporteIncidencia.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching reportes by user ID: $e');
      return [];
    }
  }

  //Estado Reporte
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

      return response != null ? DetalleReporte.fromJson(response) : null;
    } catch (e) {
      print('Error fetching detalle reporte: $e');
      return null;
    }
  }

  // Usuario Público
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
  Future<UsuarioPublico?> getUsuarioPublicoById({required String id}) async {
    try {
      final response = await _supabase
          .from('usuario_publico')
          .select()
          .eq('id', id)
          .limit(1)
          .maybeSingle();

      return response != null ? UsuarioPublico.fromJson(response) : null;
    } catch (e) {
      print('Error fetching usuario publico by id: $e');
      return null;
    }
  }
}
