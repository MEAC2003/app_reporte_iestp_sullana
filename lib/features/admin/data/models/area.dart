// To parse this JSON data, do
//
//     final area = areaFromJson(jsonString);

import 'dart:convert';

List<Area> areaFromJson(String str) =>
    List<Area>.from(json.decode(str).map((x) => Area.fromJson(x)));

String areaToJson(List<Area> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Area {
  String id;
  String? createdAt;
  String nombre;

  Area({required this.id, this.createdAt, required this.nombre});

  Area copyWith({String? id, String? createdAt, String? nombre}) => Area(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    nombre: nombre ?? this.nombre,
  );

  factory Area.fromJson(Map<String, dynamic> json) => Area(
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
