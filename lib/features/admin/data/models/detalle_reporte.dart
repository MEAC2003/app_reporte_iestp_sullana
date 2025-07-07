// To parse this JSON data, do
//
//     final detalleReporte = detalleReporteFromJson(jsonString);

import 'dart:convert';

List<DetalleReporte> detalleReporteFromJson(String str) =>
    List<DetalleReporte>.from(
      json.decode(str).map((x) => DetalleReporte.fromJson(x)),
    );

String detalleReporteToJson(List<DetalleReporte> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DetalleReporte {
  String id;
  String createdAt;
  String idReporteIncidencia;
  String? idSoporteAsignado;
  dynamic descripcion;
  dynamic observaciones;
  String? fechaAsignacion;
  String? fechaSolucion;
  String? repuestosRequeridos;
  String? justificacionRepuestos;

  DetalleReporte({
    required this.id,
    required this.createdAt,
    required this.idReporteIncidencia,
    this.idSoporteAsignado,
    required this.descripcion,
    required this.observaciones,
    this.fechaAsignacion,
    this.fechaSolucion,
    this.repuestosRequeridos,
    this.justificacionRepuestos,
  });

  DetalleReporte copyWith({
    String? id,
    String? createdAt,
    String? idReporteIncidencia,
    String? idSoporteAsignado,
    dynamic descripcion,
    dynamic observaciones,
    String? fechaAsignacion,
    String? fechaSolucion,
  }) => DetalleReporte(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    idReporteIncidencia: idReporteIncidencia ?? this.idReporteIncidencia,
    idSoporteAsignado: idSoporteAsignado ?? this.idSoporteAsignado,
    descripcion: descripcion ?? this.descripcion,
    observaciones: observaciones ?? this.observaciones,
    fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
    fechaSolucion: fechaSolucion ?? this.fechaSolucion,
    repuestosRequeridos: repuestosRequeridos ?? repuestosRequeridos,
    justificacionRepuestos: justificacionRepuestos ?? justificacionRepuestos,
  );

  factory DetalleReporte.fromJson(Map<String, dynamic> json) => DetalleReporte(
    id: json["id"],
    createdAt: json["created_at"],
    idReporteIncidencia: json["id_reporte_incidencia"],
    idSoporteAsignado: json["id_soporte_asignado"],
    descripcion: json["descripcion"],
    observaciones: json["observaciones"],
    fechaAsignacion: json["fecha_asignacion"],
    fechaSolucion: json["fecha_solucion"],
    repuestosRequeridos: json["repuestos_requeridos"],
    justificacionRepuestos: json["justificacion_repuestos"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt,
    "id_reporte_incidencia": idReporteIncidencia,
    "id_soporte_asignado": idSoporteAsignado,
    "descripcion": descripcion,
    "observaciones": observaciones,
    "fecha_asignacion": fechaAsignacion,
    "fecha_solucion": fechaSolucion,
    "repuestos_requeridos": repuestosRequeridos,
    "justificacion_repuestos": justificacionRepuestos,
  };
}
