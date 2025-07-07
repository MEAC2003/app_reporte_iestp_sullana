import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/settings/domain/repositories/users_repository.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  final UsersRepository _repository;
  AuthProvider _authProvider;
  List<UsuarioPublico> _users = [];
  UsuarioPublico? _user;
  bool _isLoading = false;
  String? _error;

  UserProvider(this._repository, {required AuthProvider authProvider})
    : _authProvider = authProvider {
    print('UserProvider initialized');
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  UsuarioPublico? get user => _user;
  List<UsuarioPublico> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateAuthProvider(AuthProvider authProvider) {
    print('Updating AuthProvider');
    if (_authProvider != authProvider) {
      print('New AuthProvider provided, updating listeners');
      _authProvider.removeListener(_onAuthStateChanged);
      _authProvider = authProvider;
      _authProvider.addListener(_onAuthStateChanged);
      _onAuthStateChanged();
    } else {
      print('AuthProvider unchanged');
    }
  }

  void _onAuthStateChanged() {
    print(
      'Auth state changed. isAuthenticated: ${_authProvider.isAuthenticated}',
    );
    if (_authProvider.isAuthenticated) {
      print('User is authenticated, getting current user');
      getCurrentUser();
    } else {
      print('User is not authenticated, clearing user data');
      clearUser();
    }
  }

  Future<void> getCurrentUser() async {
    print('getCurrentUser called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching current user from repository');
      _user = await _repository.getCurrentUser();
      print('User fetched: ${_user?.toJson()}');
    } catch (e) {
      print('Error fetching user: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> updateUser(UsuarioPublico user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateUser(user);
      _user = user;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  Future<void> getUsers() async {
    print('getUsers called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching all users from repository');
      _users = await _repository.getUsers();
      _isLoading = false;
      print('Users fetched: ${_users.length} users');
    } catch (e) {
      print('Error fetching users: $e');
      _error = e.toString();
      _isLoading = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateUserRole(userId, newRole);

      // Actualizar el rol del usuario en la lista local si es el usuario actual
      if (_user != null && _user!.id == userId) {
        _user = _user!.copyWith(rol: newRole);
      }

      // Recargar la lista de usuarios
      await getUsers();

      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}
