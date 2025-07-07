import 'package:app_reporte_iestp_sullana/features/auth/data/datasources/supabase_auth_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/repositories/auth_repository.dart';

import 'package:app_reporte_iestp_sullana/services/notification_utils.dart';
import 'package:app_reporte_iestp_sullana/services/realtime_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  String? _userRole;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  bool hasRole(String role) => _userRole == role;

  AuthProvider(this._authRepository) {
    _initializeSession();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _initializeSession() async {
    _currentUser = Supabase.instance.client.auth.currentUser;
    if (_currentUser != null) {
      await fetchUserRole();
      _isAuthenticated = true;

      // Verificar reportes pendientes al inicializar sesión existente
      await _initializeNotificationsAndCheckReports();
    }
    notifyListeners();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        await fetchUserRole();
        _isAuthenticated = true;
      } else {
        _userRole = null;
        _isAuthenticated = false;
        RealtimeNotificationService.disconnect();
      }
      notifyListeners();
    });
  }

  UserRole get userRole => UserRole.values.firstWhere(
    (role) => role.toString().split('.').last == _userRole,
    orElse: () => UserRole.usuario,
  );

  Future<AuthResult> signInWithGoogle() async {
    return _performAuthAction(() => _authRepository.signInWithGoogle());
  }

  Future<void> signOut() async {
    try {
      RealtimeNotificationService.disconnect();
      await _authRepository.signOut();
      _currentUser = null;
      _userRole = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  Future<AuthResult> _performAuthAction(
    Future<AuthResult> Function() action,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await action();
      if (result.success) {
        _currentUser = Supabase.instance.client.auth.currentUser;
        await fetchUserRole();
        _isAuthenticated = true;

        // Inicializar notificaciones y verificar reportes al hacer login
        await _initializeNotificationsAndCheckReports();

        print('Usuario autenticado y notificaciones configuradas');
      } else {
        _errorMessage = result.error ?? "Authentication failed";
        _isAuthenticated = false;
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _isAuthenticated = false;
      notifyListeners();
      return AuthResult(success: false, isNewUser: false, error: _errorMessage);
    }
  }

  // MÉTODO PRIVADO PARA INICIALIZAR NOTIFICACIONES Y VERIFICAR REPORTES (ACTUALIZADO)
  Future<void> _initializeNotificationsAndCheckReports() async {
    if (_userRole == null) return;

    // UNA SOLA LÍNEA EN LUGAR DE TODO EL CÓDIGO ANTERIOR
    await NotificationUtils.initializeForUser(_userRole!);
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email o contraseña incorrectos';
        case 'Email not confirmed':
          return 'Por favor, confirme su email antes de iniciar sesión';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return 'Ocurrió un error inesperado';
  }

  Future<void> fetchUserRole() async {
    if (_currentUser == null) return;

    try {
      final response = await Supabase.instance.client
          .from('usuario_publico')
          .select('rol(nombre)')
          .eq('id', _currentUser!.id)
          .single();

      final rolData = response['rol'] as Map<String, dynamic>?;
      _userRole = rolData?['nombre'] as String?;
      notifyListeners();
    } catch (e) {
      print('Error fetching user role: $e');
      _userRole = 'usuario';
    }
    print('Fetched user role: $_userRole');
  }

  Future<void> checkAuthStatus() async {
    _currentUser = Supabase.instance.client.auth.currentUser;
    if (_currentUser != null) {
      await fetchUserRole();
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<void> initializeUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _currentUser = user;
        await fetchUserRole();
        _isAuthenticated = true;

        // Inicializar notificaciones y verificar reportes
        await _initializeNotificationsAndCheckReports();
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      print('Error initializing user: $e');
      _isAuthenticated = false;
    }
    notifyListeners();
  }
}
