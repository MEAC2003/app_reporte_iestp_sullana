import 'dart:convert';

List<AdjuntarArchivoRequerimiento> adjuntarArchivoRequerimientoFromJson(
  String str,
) => List<AdjuntarArchivoRequerimiento>.from(
  json.decode(str).map((x) => AdjuntarArchivoRequerimiento.fromJson(x)),
);

String adjuntarArchivoRequerimientoToJson(
  List<AdjuntarArchivoRequerimiento> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdjuntarArchivoRequerimiento {
  String id;
  String createdAt;
  String? pdfUrl;
  String? idReporte;

  AdjuntarArchivoRequerimiento({
    required this.id,
    required this.createdAt,
    this.pdfUrl,
    this.idReporte,
  });

  AdjuntarArchivoRequerimiento copyWith({
    String? id,
    String? createdAt,
    String? pdfUrl,
    String? idReporte,
  }) => AdjuntarArchivoRequerimiento(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    pdfUrl: pdfUrl ?? this.pdfUrl,
    idReporte: idReporte ?? this.idReporte,
  );

  factory AdjuntarArchivoRequerimiento.fromJson(Map<String, dynamic> json) =>
      AdjuntarArchivoRequerimiento(
        id: json["id"],
        createdAt: json["created_at"],
        pdfUrl: json["pdf_url"],
        idReporte: json["id_reporte"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt,
    "pdf_url": pdfUrl,
    "id_reporte": idReporte,
  };
}
