// To parse this JSON data, do
//
//     final reporteIncidencia = reporteIncidenciaFromJson(jsonString);

import 'dart:convert';

List<ReporteIncidencia> reporteIncidenciaFromJson(String str) =>
    List<ReporteIncidencia>.from(
      json.decode(str).map((x) => ReporteIncidencia.fromJson(x)),
    );

String reporteIncidenciaToJson(List<ReporteIncidencia> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReporteIncidencia {
  String? id;
  String? createdAt;
  String descripcion;
  String idUsuario;
  String idTipoReporte;
  String idArea;
  String idEstadoReporte;
  String idPrioridad;
  String urlImg;

  ReporteIncidencia({
    this.id,
    this.createdAt,
    required this.descripcion,
    required this.idUsuario,
    required this.idTipoReporte,
    required this.idArea,
    required this.idEstadoReporte,
    required this.idPrioridad,
    required this.urlImg,
  });

  ReporteIncidencia copyWith({
    String? id,
    String? createdAt,
    String? descripcion,
    String? idUsuario,
    String? idTipoReporte,
    String? idArea,
    String? idEstadoReporte,
    String? idPrioridad,
    String? urlImg,
  }) => ReporteIncidencia(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    descripcion: descripcion ?? this.descripcion,
    idUsuario: idUsuario ?? this.idUsuario,
    idTipoReporte: idTipoReporte ?? this.idTipoReporte,
    idArea: idArea ?? this.idArea,
    idEstadoReporte: idEstadoReporte ?? this.idEstadoReporte,
    idPrioridad: idPrioridad ?? this.idPrioridad,
    urlImg: urlImg ?? this.urlImg,
  );

  factory ReporteIncidencia.fromJson(Map<String, dynamic> json) =>
      ReporteIncidencia(
        id: json["id"],
        createdAt: json["created_at"],
        descripcion: json["descripcion"],
        idUsuario: json["id_usuario"],
        idTipoReporte: json["id_tipo_reporte"],
        idArea: json["id_area"],
        idEstadoReporte: json["id_estado_reporte"],
        idPrioridad: json["id_prioridad"],
        urlImg: json["url_img"],
      );

  Map<String, dynamic> toJson() => {
    "descripcion": descripcion,
    "id_usuario": idUsuario,
    "id_tipo_reporte": idTipoReporte,
    "id_area": idArea,
    "id_estado_reporte": idEstadoReporte,
    "id_prioridad": idPrioridad,
    "url_img": urlImg,
  };
}
