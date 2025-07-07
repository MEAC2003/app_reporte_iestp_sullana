// To parse this JSON data, do
//
//     final prioridad = prioridadFromJson(jsonString);

import 'dart:convert';

List<Prioridad> prioridadFromJson(String str) =>
    List<Prioridad>.from(json.decode(str).map((x) => Prioridad.fromJson(x)));

String prioridadToJson(List<Prioridad> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Prioridad {
  String id;
  String createdAt;
  String nombre;

  Prioridad({required this.id, required this.createdAt, required this.nombre});

  Prioridad copyWith({String? id, String? createdAt, String? nombre}) =>
      Prioridad(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        nombre: nombre ?? this.nombre,
      );

  factory Prioridad.fromJson(Map<String, dynamic> json) => Prioridad(
    id: json["id"],
    createdAt: json["created_at"],
    nombre: json["nombre"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt,
    "nombre": nombre,
  };
}
