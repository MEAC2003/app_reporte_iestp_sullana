// AGREGAR este widget al final del archivo:

import 'package:app_reporte_iestp_sullana/features/admin/data/models/adjuntar_archivo_requerimiento.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class RequerimientoPDFWidget extends StatelessWidget {
  final AdjuntarArchivoRequerimiento archivoRequerimiento;

  const RequerimientoPDFWidget({super.key, required this.archivoRequerimiento});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSize.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requerimiento de Repuestos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkColor,
                      ),
                    ),
                    Text(
                      'Generado: ${_formatDate(archivoRequerimiento.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkColor50,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSize.defaultPadding),

          // URL del PDF con fondo
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'URL del PDF:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkColor,
                  ),
                ),
                SizedBox(height: AppSize.defaultPadding * 0.25),
                SelectableText(
                  archivoRequerimiento.pdfUrl ?? 'URL no disponible',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSize.defaultPadding),

          // Botones de acción
          Row(
            children: [
              // Botón Abrir PDF
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _abrirPDF(context),
                  icon: Icon(Icons.open_in_new),
                  label: Text('Abrir PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: AppSize.defaultPadding * 0.75,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSize.defaultPadding * 0.5),
              // Botón Copiar Link
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copiarLink(context),
                  icon: Icon(Icons.copy),
                  label: Text('Copiar Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSize.defaultPadding * 0.75,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSize.defaultPadding * 0.5),

          // Botón Compartir
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _compartirPDF(context),
              icon: Icon(Icons.share),
              label: Text('Compartir PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue),
                padding: EdgeInsets.symmetric(
                  vertical: AppSize.defaultPadding * 0.75,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Abrir PDF en navegador
  Future<void> _abrirPDF(BuildContext context) async {
    if (archivoRequerimiento.pdfUrl == null) {
      _mostrarError(context, 'URL del PDF no disponible');
      return;
    }

    try {
      final Uri url = Uri.parse(archivoRequerimiento.pdfUrl!);

      // FORZAR APERTURA EN NAVEGADOR WEB
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
    } catch (e) {
      // Si falla, intentar con modo web específico
      try {
        final Uri url = Uri.parse(archivoRequerimiento.pdfUrl!);
        await launchUrl(
          url,
          mode: LaunchMode.inAppWebView, // Abre en navegador dentro de la app
        );
      } catch (e2) {
        _mostrarError(context, 'Error al abrir PDF en navegador: $e2');
      }
    }
  }

  // Copiar link al portapapeles
  Future<void> _copiarLink(BuildContext context) async {
    if (archivoRequerimiento.pdfUrl == null) {
      _mostrarError(context, 'URL del PDF no disponible');
      return;
    }

    try {
      await Clipboard.setData(
        ClipboardData(text: archivoRequerimiento.pdfUrl!),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Link copiado al portapapeles'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _mostrarError(context, 'Error al copiar link: $e');
    }
  }

  // Compartir PDF (abre opciones de compartir del sistema)
  Future<void> _compartirPDF(BuildContext context) async {
    if (archivoRequerimiento.pdfUrl == null) {
      _mostrarError(context, 'URL del PDF no disponible');
      return;
    }

    try {
      final String textoCompartir =
          '''
🏫 IESTP SULLANA - Requerimiento de Repuestos

📄 PDF: ${archivoRequerimiento.pdfUrl}

📅 Generado: ${_formatDate(archivoRequerimiento.createdAt)}

Sistema de Gestión de Reportes
      ''';

      // Para compartir, puedes usar Share.share del paquete share_plus
      // O simplemente copiar y mostrar opciones
      await Clipboard.setData(ClipboardData(text: textoCompartir));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Información copiada para compartir'),
          backgroundColor: Colors.blue,
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Información para Compartir'),
                  content: SelectableText(textoCompartir),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      _mostrarError(context, 'Error al preparar compartir: $e');
    }
  }

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red,
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
