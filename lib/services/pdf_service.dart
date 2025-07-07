import 'dart:io';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/models.dart';

class PdfService {
  Future<File> generarReportePDF({
    required ReporteIncidencia reporte,
    required DetalleReporte? detalleReporte,
    required String areaNombre,
    required String tipoReporteNombre,
    required String prioridadNombre,
    required String nombreUsuario,
    required String nombreSoporte,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // ENCABEZADO
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'REQUERIMIENTO DE REPUESTOS',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'Instituto de Educación Superior Tecnológico Público Sullana',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.blue900,
                            width: 2,
                          ),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(8),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'FECHA: ${_formatDate(DateTime.now().toIso8601String())}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 2, color: PdfColors.blue900),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // INFORMACIÓN DEL REPORTE
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.grey50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'INFORMACIÓN DEL REPORTE',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            _buildInfoRow(
                              'Fecha de Creación:',
                              _formatDate(reporte.createdAt ?? ''),
                            ),
                            _buildInfoRow('Docente Reportante:', nombreUsuario),
                            _buildInfoRow('Área:', areaNombre),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            _buildInfoRow(
                              'Tipo de Reporte:',
                              tipoReporteNombre,
                            ),
                            _buildInfoRow('Prioridad:', prioridadNombre),
                            _buildInfoRow('Técnico Asignado:', nombreSoporte),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // DESCRIPCIÓN DEL PROBLEMA ORIGINAL
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.orange50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DESCRIPCIÓN DEL PROBLEMA REPORTADO',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange800,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    reporte.descripcion,
                    style: const pw.TextStyle(fontSize: 12),
                    textAlign: pw.TextAlign.justify,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // DIAGNÓSTICO TÉCNICO
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.blue50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DIAGNÓSTICO TÉCNICO',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  if (detalleReporte?.fechaAsignacion != null)
                    _buildInfoRow(
                      'Fecha de Asignación:',
                      _formatDate(detalleReporte!.fechaAsignacion!),
                    ),

                  pw.SizedBox(height: 10),

                  if (detalleReporte?.descripcion != null &&
                      detalleReporte!.descripcion!.isNotEmpty) ...[
                    pw.Text(
                      'DESCRIPCIÓN DEL TRABAJO REALIZADO:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Text(
                        detalleReporte.descripcion!,
                        style: const pw.TextStyle(fontSize: 11),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                  ] else ...[
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Text(
                        'DESCRIPCIÓN DEL TRABAJO REALIZADO:\n\n(A completar por el técnico asignado)',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 15),
                  ],

                  if (detalleReporte?.observaciones != null &&
                      detalleReporte!.observaciones!.isNotEmpty) ...[
                    pw.Text(
                      'OBSERVACIONES TÉCNICAS:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Text(
                        detalleReporte.observaciones!,
                        style: const pw.TextStyle(fontSize: 11),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ] else ...[
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Text(
                        'OBSERVACIONES TÉCNICAS:\n\n(A completar por el técnico asignado)',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // REPUESTOS REQUERIDOS
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.red400, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.red50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.red800,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Text(
                          '!',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        'REPUESTOS REQUERIDOS PARA LA REPARACIÓN',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red800,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 15),

                  pw.Text(
                    'Se requiere la aprobación del director para la adquisición de los siguientes repuestos necesarios para completar la reparación del equipo/sistema reportado:',
                    style: const pw.TextStyle(fontSize: 12),
                    textAlign: pw.TextAlign.justify,
                  ),
                  pw.SizedBox(height: 15),

                  // Lista de repuestos
                  if (detalleReporte?.repuestosRequeridos != null &&
                      detalleReporte!.repuestosRequeridos!.isNotEmpty) ...[
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(
                          color: PdfColors.red300,
                          width: 1,
                        ),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'LISTA DE REPUESTOS:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                              color: PdfColors.red800,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            detalleReporte.repuestosRequeridos!,
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 15),
                  ] else ...[
                    // Tabla vacía para llenar manualmente
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.red600),
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.red100),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'DESCRIPCIÓN DEL REPUESTO',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'CANTIDAD',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'OBSERVACIONES',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        // Filas vacías para llenar manualmente
                        for (int i = 0; i < 5; i++)
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(15),
                                child: pw.Text(''),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(15),
                                child: pw.Text(''),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(15),
                                child: pw.Text(''),
                              ),
                            ],
                          ),
                      ],
                    ),
                    pw.SizedBox(height: 15),
                  ],

                  // Justificación
                  if (detalleReporte?.justificacionRepuestos != null &&
                      detalleReporte!.justificacionRepuestos!.isNotEmpty) ...[
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(
                          color: PdfColors.red300,
                          width: 1,
                        ),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'JUSTIFICACIÓN TÉCNICA:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                              color: PdfColors.red800,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            detalleReporte.justificacionRepuestos!,
                            style: const pw.TextStyle(fontSize: 11),
                            textAlign: pw.TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    pw.Container(
                      width: double.infinity,
                      height: 80,
                      padding: const pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(
                          color: PdfColors.red300,
                          width: 1,
                        ),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Align(
                        alignment: pw.Alignment.topLeft,
                        child: pw.Text(
                          'JUSTIFICACIÓN TÉCNICA:\n\n(A completar por el técnico - explicar por qué son necesarios estos repuestos)',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // SECCIÓN DE APROBACIÓN
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.green400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.green50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SECCIÓN DE APROBACIÓN',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800,
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Jefe de oficina PAD
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Ing. Juan José Correa Ortiz',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 30),
                          pw.Container(
                            width: 180,
                            height: 1,
                            color: PdfColors.black,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'JEFE DE OFICINA PAD',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            'Firma',
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),

                      // Director
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Ing. Virgilio Huamán Ramos',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 30),
                          pw.Container(
                            width: 180,
                            height: 1,
                            color: PdfColors.black,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'DIRECTOR',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            'Firma',
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'OBSERVACIONES DE LA DIRECCIÓN:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // PIE DE PÁGINA
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Documento generado automáticamente el ${_formatDate(DateTime.now().toIso8601String())}',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Instituto de Educación Superior Tecnológico Público Sullana - Sistema de Gestión de Reportes',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Guardar el archivo
    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/requerimiento_${reporte.id ?? 'sin_id'}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
