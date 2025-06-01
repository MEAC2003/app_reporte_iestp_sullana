import 'package:app_reporte_iestp_sullana/features/auth/data/datasources/supabase_auth_data_source.dart';

abstract class AuthRepository {
  Future<AuthResult> signInWithGoogle();
  Future<void> signOut();
  bool isSignedIn();
}
