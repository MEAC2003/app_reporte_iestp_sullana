// To parse this JSON data, do
//
//     final tipoReporte = tipoReporteFromJson(jsonString);

import 'dart:convert';

List<TipoReporte> tipoReporteFromJson(String str) => List<TipoReporte>.from(
  json.decode(str).map((x) => TipoReporte.fromJson(x)),
);

String tipoReporteToJson(List<TipoReporte> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TipoReporte {
  String id;
  String createdAt;
  String nombre;
  String descripcion;

  TipoReporte({
    required this.id,
    required this.createdAt,
    required this.nombre,
    required this.descripcion,
  });

  TipoReporte copyWith({
    String? id,
    String? createdAt,
    String? nombre,
    String? descripcion,
  }) => TipoReporte(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
  );

  factory TipoReporte.fromJson(Map<String, dynamic> json) => TipoReporte(
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
