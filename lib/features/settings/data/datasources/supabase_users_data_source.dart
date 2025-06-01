import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUsersDataSourceImpl {
  final SupabaseClient _supabaseClient;

  SupabaseUsersDataSourceImpl(this._supabaseClient);

  Future<UsuarioPublico?> getCurrentUser() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabaseClient
        .from('usuario_publico')
        .select()
        .eq('id', userId)
        .single();

    return UsuarioPublico.fromJson(response);
  }

  Future<void> updateUser(UsuarioPublico user) async {
    await _supabaseClient
        .from('usuario_publico')
        .update(user.toJson())
        .eq('id', user.id);
  }
}
