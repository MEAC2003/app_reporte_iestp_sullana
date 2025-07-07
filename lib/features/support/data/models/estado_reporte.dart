// To parse this JSON data, do
//
//     final estadoReporte = estadoReporteFromJson(jsonString);

import 'dart:convert';

List<EstadoReporte> estadoReporteFromJson(String str) =>
    List<EstadoReporte>.from(
      json.decode(str).map((x) => EstadoReporte.fromJson(x)),
    );

String estadoReporteToJson(List<EstadoReporte> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EstadoReporte {
  String id;
  String createdAt;
  String nombre;
  String descripcion;

  EstadoReporte({
    required this.id,
    required this.createdAt,
    required this.nombre,
    required this.descripcion,
  });

  EstadoReporte copyWith({
    String? id,
    String? createdAt,
    String? nombre,
    String? descripcion,
  }) => EstadoReporte(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
  );

  factory EstadoReporte.fromJson(Map<String, dynamic> json) => EstadoReporte(
    id: json["id"],
    createdAt: json["created_at"],
    nombre: json["nombre"],
    descripcion: json["descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt,
    "nombre": nombre,
    "descripcion": descripcion,
  };
}
