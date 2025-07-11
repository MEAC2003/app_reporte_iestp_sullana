import 'package:app_reporte_iestp_sullana/features/settings/data/datasources/supabase_users_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/settings/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final SupabaseUsersDataSourceImpl _dataSource;

  UsersRepositoryImpl(this._dataSource);

  @override
  Future<UsuarioPublico?> getCurrentUser() => _dataSource.getCurrentUser();

  @override
  Future<List<UsuarioPublico>> getUsers() async {
    return await _dataSource.getUsers();
  }

  @override
  Future<void> updateUser(UsuarioPublico user) async {
    await _dataSource.updateUser(user);
  }

  @override
  Future<void> updateUserRole(String userId, String roleId) async {
    await _dataSource.updateUserRole(userId, roleId);
  }
}
