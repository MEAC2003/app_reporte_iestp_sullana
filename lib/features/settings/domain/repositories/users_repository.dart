import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';

abstract class UsersRepository {
  Future<UsuarioPublico?> getCurrentUser();
  Future<List<UsuarioPublico>> getUsers();
  Future<void> updateUser(UsuarioPublico user);
  Future<void> updateUserRole(String userId, String roleId);
}
