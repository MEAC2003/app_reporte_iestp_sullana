import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthResult {
  final bool success;
  final bool isNewUser;
  final String? error;
  final String? avatarUrl;

  AuthResult({
    required this.success,
    required this.isNewUser,
    this.error,
    this.avatarUrl,
  });
}

abstract class AuthDataSource {
  Future<AuthResult> signInWithGoogle();
  Future<void> signOut();
  bool isSignedIn();
}

class SupabaseAuthDataSourceImpl implements AuthDataSource {
  final _supabase = Supabase.instance.client;

  // CORRECCIÓN: Solo usar serverClientId para Supabase
  final _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID']!, // Solo este
    // Remover clientId completamente
  );

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      print('Iniciando Google Sign-In...');

      // Limpiar sesiones anteriores para evitar conflictos
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Usuario canceló el sign-in');
        return AuthResult(
          success: false,
          isNewUser: false,
          error: 'Google sign in was cancelled',
        );
      }

      print('Usuario Google obtenido: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        print('Error: Tokens no obtenidos');
        return AuthResult(
          success: false,
          isNewUser: false,
          error: 'Failed to get Google authentication tokens',
        );
      }

      print('Tokens obtenidos correctamente');
      print('Autenticando con Supabase...');

      final AuthResponse res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (res.user == null) {
        print('Error: Usuario null después de auth');
        return AuthResult(
          success: false,
          isNewUser: false,
          error: 'Authentication failed',
        );
      }

      print('Autenticación exitosa: ${res.user!.email}');

      // Verificar si es un usuario nuevo
      final isNewUser =
          res.session?.user.appMetadata['provider'] == 'google' &&
          res.session?.user.appMetadata['providers']?.length == 1;

      // Obtener avatar URL del perfil de Google
      final avatarUrl = res.user!.userMetadata?['avatar_url'];

      print('Usuario nuevo: $isNewUser');

      return AuthResult(
        success: true,
        isNewUser: isNewUser,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      print('Error completo en signInWithGoogle: $e');
      print('Tipo de error: ${e.runtimeType}');

      // Manejo específico de errores comunes
      String errorMessage = e.toString();
      if (errorMessage.contains('ApiException: 10')) {
        errorMessage =
            'Error de configuración de Google. Por favor contacta al administrador.';
      } else if (errorMessage.contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet.';
      }

      return AuthResult(success: false, isNewUser: false, error: errorMessage);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
      print('Sign out exitoso');
    } catch (e) {
      print('Error en sign out: $e');
    }
  }

  @override
  bool isSignedIn() => _supabase.auth.currentUser != null;
}
