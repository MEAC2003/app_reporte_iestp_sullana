// To parse this JSON data, do
//
//     final usuarioPublico = usuarioPublicoFromJson(jsonString);

import 'dart:convert';

List<UsuarioPublico> usuarioPublicoFromJson(String str) =>
    List<UsuarioPublico>.from(
      json.decode(str).map((x) => UsuarioPublico.fromJson(x)),
    );

String usuarioPublicoToJson(List<UsuarioPublico> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsuarioPublico {
  String id;
  String createdAt;
  String nombre;
  String correo;
  String rol;
  dynamic avatarUrl;

  UsuarioPublico({
    required this.id,
    required this.createdAt,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.avatarUrl,
  });

  UsuarioPublico copyWith({
    String? id,
    String? createdAt,
    String? nombre,
    String? correo,
    String? rol,
    dynamic avatarUrl,
  }) => UsuarioPublico(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    nombre: nombre ?? this.nombre,
    correo: correo ?? this.correo,
    rol: rol ?? this.rol,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  factory UsuarioPublico.fromJson(Map<String, dynamic> json) => UsuarioPublico(
    id: json["id"],
    createdAt: json["created_at"],
    nombre: json["nombre"],
    correo: json["correo"],
    rol: json["rol"],
    avatarUrl: json["avatar_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt,
    "nombre": nombre,
    "correo": correo,
    "rol": rol,
    "avatar_url": avatarUrl,
  };

  firstWhere(bool Function(dynamic u) param0) {}
}
