import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/models/usuario_publico.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/enums/user_role.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  // Mapeo de UUIDs a roles basado en tu tabla
  final Map<String, UserRole> _roleMapping = {
    '6cf8bda6-1726-495e-9c6a-917f474e1081': UserRole.pendiente,
    '3f685a86-8b62-4a8b-ac73-092a06bf7961': UserRole.usuario,
    'd761f72b-3a0f-4c4a-bcec-1ad5bd79b7e1': UserRole.administrador,
    'f0c11c95-a587-44ad-bd1f-3b6cfcf661cd': UserRole.soporteTecnico,
  };

  // Mapeo inverso de roles a UUIDs
  final Map<UserRole, String> _roleToIdMapping = {
    UserRole.pendiente: '6cf8bda6-1726-495e-9c6a-917f474e1081',
    UserRole.usuario: '3f685a86-8b62-4a8b-ac73-092a06bf7961',
    UserRole.administrador: 'd761f72b-3a0f-4c4a-bcec-1ad5bd79b7e1',
    UserRole.soporteTecnico: 'f0c11c95-a587-44ad-bd1f-3b6cfcf661cd',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().getUsers());
  }

  // Convertir enum a nombre legible
  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.usuario:
        return 'Usuario';
      case UserRole.pendiente:
        return 'Pendiente';
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.soporteTecnico:
        return 'Soporte Técnico';
    }
  }

  // Convertir UUID del rol a enum
  UserRole _uuidToUserRole(String? roleUuid) {
    if (roleUuid == null) {
      return UserRole.pendiente;
    }

    final role = _roleMapping[roleUuid];
    if (role != null) {
      return role;
    } else {
      return UserRole.pendiente;
    }
  }

  // Convertir enum de rol a UUID
  String _userRoleToUuid(UserRole role) {
    return _roleToIdMapping[role] ?? _roleToIdMapping[UserRole.pendiente]!;
  }

  void _showRoleChangeDialog(UsuarioPublico user) {
    showDialog(
      context: context,
      builder: (context) {
        UserRole selectedRole = _uuidToUserRole(user.rol);

        return AlertDialog(
          title: Text(
            'Cambiar rol de ${user.nombre.split(' ').map((name) => name[0].toUpperCase() + name.substring(1).toLowerCase()).join(' ')}',
            style: AppStyles.h3(color: AppColors.darkColor),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: UserRole.values.map((role) {
                  return RadioListTile<UserRole>(
                    title: Text(
                      _getRoleDisplayName(role),
                      style: AppStyles.h4(),
                    ),
                    value: role,
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text('Cancelar', style: AppStyles.h4()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedRole != _uuidToUserRole(user.rol)) {
                  try {
                    print('Iniciando actualización de rol');
                    print('Usuario ID: ${user.id}');
                    print('Rol actual: ${user.rol}');
                    print('Rol seleccionado: ${selectedRole.name}');

                    final roleUuid = _userRoleToUuid(selectedRole);
                    print('UUID del nuevo rol: $roleUuid');

                    await context.read<UserProvider>().updateUserRole(
                      user.id,
                      roleUuid,
                    );

                    // Verificar si el widget aún está montado antes de usar el contexto
                    if (!context.mounted) return;

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rol actualizado exitosamente'),
                        backgroundColor: AppColors.primaryColor,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    print('Error completo al actualizar rol: $e');

                    // Verificar si el widget aún está montado antes de mostrar el error
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } else {
                  // Si no hay cambios, simplemente cerrar el diálogo
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: Text('Guardar', style: AppStyles.h4(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(String? roleUuid) {
    UserRole role = _uuidToUserRole(roleUuid);
    switch (role) {
      case UserRole.pendiente:
        return Colors.orange;
      case UserRole.usuario:
        return Colors.blue;
      case UserRole.administrador:
        return Colors.green;
      case UserRole.soporteTecnico:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Gestión de Usuarios',
          style: AppStyles.h2(color: AppColors.darkColor),
        ),
        leading: IconButton(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.defaultPaddingHorizontal * 1.5,
          ),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProvider.error != null
          ? Center(child: Text('Error: ${userProvider.error}'))
          : userProvider.users.isEmpty
          ? const Center(child: Text('No hay usuarios registrados'))
          : ListView.separated(
              padding: EdgeInsets.all(AppSize.defaultPadding),
              itemCount: userProvider.users.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey.withOpacity(0.3)),
              itemBuilder: (context, index) {
                final user = userProvider.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatarUrl?.isNotEmpty == true
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl?.isNotEmpty != true
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    user.nombre
                        .split(' ')
                        .map(
                          (name) =>
                              name[0].toUpperCase() +
                              name.substring(1).toLowerCase(),
                        )
                        .take(2)
                        .join(' '),
                    style: AppStyles.h3(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    user.correo,
                    style: AppStyles.h4(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.rol).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _getRoleDisplayName(_uuidToUserRole(user.rol)),
                      style: AppStyles.h4(
                        color: _getRoleColor(user.rol),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _showRoleChangeDialog(user),
                );
              },
            ),
    );
  }
}
