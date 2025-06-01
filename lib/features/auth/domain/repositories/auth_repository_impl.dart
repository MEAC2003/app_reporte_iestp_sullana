import 'package:app_reporte_iestp_sullana/features/auth/data/datasources/supabase_auth_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepositoryImpl(this._authDataSource);

  @override
  Future<AuthResult> signInWithGoogle() {
    return _authDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _authDataSource.signOut();
  }

  @override
  bool isSignedIn() {
    return _authDataSource.isSignedIn();
  }
}
