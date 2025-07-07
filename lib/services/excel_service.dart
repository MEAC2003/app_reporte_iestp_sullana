import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/reporte_incidencia.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/detalle_reporte.dart';

class ExcelReportService {
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      try {
        if (await Permission.manageExternalStorage.isGranted) {
          return true;
        }

        Map<Permission, PermissionStatus> permissions = await [
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();

        print('Permisos solicitados:');
        print('   Storage: ${permissions[Permission.storage]}');
        print(
          '   ManageExternalStorage: ${permissions[Permission.manageExternalStorage]}',
        );

        // Verificar si se otorgaron los permisos
        bool granted =
            permissions[Permission.storage] == PermissionStatus.granted ||
            permissions[Permission.manageExternalStorage] ==
                PermissionStatus.granted ||
            await Permission.storage.isGranted;

        if (!granted) {
          print('Permisos denegados, intentando con permisos básicos...');
          // Intentar con permiso básico de almacenamiento
          final basicPermission = await Permission.storage.request();
          granted = basicPermission == PermissionStatus.granted;
        }

        return granted;
      } catch (e) {
        print(' Error solicitando permisos: $e');
        return false;
      }
    }
    return true;
  }

  static Future<bool> generateMonthlyReport({
    required List<ReporteIncidencia> reportes,
    required List<DetalleReporte> detalles,
    required Map<String, String> areas,
    required Map<String, String> tiposReporte,
    required Map<String, String> estados,
    required Map<String, String> prioridades,
    required Map<String, String> usuarios,
    required int month,
    required int year,
  }) async {
    try {
      print('Iniciando generación de reporte Excel...');

      // Solicitar permisos antes de generar el archivo
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        print(' Permisos de almacenamiento denegados');
        return false;
      }

      print(' Permisos otorgados, creando Excel...');

      // Crear Excel
      var excel = Excel.createExcel();

      // Eliminar la hoja por defecto
      excel.delete('Sheet1');

      // Crear hojas con datos
      await _createSummarySheet(excel, reportes, month, year);
      await _createDetailedReportsSheet(
        excel,
        reportes,
        detalles,
        areas,
        tiposReporte,
        estados,
        prioridades,
        usuarios,
        month,
        year,
      );
      await _createStatisticsSheet(
        excel,
        reportes,
        areas,
        estados,
        prioridades,
        month,
        year,
      );

      // Guardar archivo
      return await _saveFile(excel, month, year);
    } catch (e) {
      print(' Error generando reporte Excel: $e');
      return false;
    }
  }

  //  Método para guardar archivos con múltiples opciones
  static Future<bool> _saveFile(Excel excel, int month, int year) async {
    try {
      Directory? directory;
      final fileName = 'Reporte_Mensual_${_getMonthName(month)}_$year.xlsx';

      print('Buscando directorio de guardado...');

      if (Platform.isAndroid) {
        // Probar múltiples ubicaciones en orden de preferencia
        List<Directory?> possibleDirectories = [
          // 1. Directorio de descargas público
          Directory('/storage/emulated/0/Download'),
          // 2. Directorio de documentos público
          Directory('/storage/emulated/0/Documents'),
          // 3. Directorio externo de la app
          await getExternalStorageDirectory(),
          // 4. Directorio de documentos de la app
          await getApplicationDocumentsDirectory(),
        ];

        for (Directory? testDir in possibleDirectories) {
          if (testDir != null) {
            try {
              print(' Probando directorio: ${testDir.path}');

              // Crear directorio si no existe
              if (!await testDir.exists()) {
                await testDir.create(recursive: true);
                print(' Directorio creado: ${testDir.path}');
              }

              // Probar crear un archivo de prueba
              final testFile = File('${testDir.path}/test_write.txt');
              await testFile.writeAsString('test');
              await testFile.delete();

              // Si llegamos aquí, podemos escribir en este directorio
              directory = testDir;
              print(' Directorio seleccionado: ${directory.path}');
              break;
            } catch (e) {
              print(' No se puede escribir en: ${testDir.path} - Error: $e');
              continue;
            }
          }
        }

        // Si no encontramos un directorio escribible, crear uno en el almacenamiento de la app
        if (directory == null) {
          print(' Usando directorio de aplicación como respaldo...');
          final appDir = await getApplicationDocumentsDirectory();
          final customDir = Directory('${appDir.path}/Reportes_IESTP');
          if (!await customDir.exists()) {
            await customDir.create(recursive: true);
          }
          directory = customDir;
        }
      } else {
        // Para iOS
        directory = await getApplicationDocumentsDirectory();
      }

      print(' Guardando archivo en: ${directory.path}');

      final file = File('${directory.path}/$fileName');
      final bytes = excel.save();

      if (bytes == null) {
        print('Error: No se pudieron generar los bytes del Excel');
        return false;
      }

      await file.writeAsBytes(bytes);

      print(' ¡Archivo guardado exitosamente!');
      print(' Archivo: $fileName');
      print(' Ubicación: ${file.path}');
      print(' Tamaño: ${bytes.length} bytes');

      return true;
    } catch (e) {
      print(' Error guardando archivo: $e');
      return false;
    }
  }

  // ... resto de métodos sin cambios (igual que tu código actual)
  static Future<void> _createSummarySheet(
    Excel excel,
    List<ReporteIncidencia> reportes,
    int month,
    int year,
  ) async {
    var sheet = excel['Resumen'];

    // Título principal
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'REPORTE MENSUAL DE INCIDENCIAS - ${_getMonthName(month)} $year',
    );

    // Estilo corregido para el título
    var titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = titleStyle;

    // Fusionar celdas del título
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('F1'));

    // Información general
    int row = 3;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(
      'Fecha de generación:',
    );
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(
      DateTime.now().toString().split(' ')[0],
    );

    row += 2;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(
      'ESTADÍSTICAS GENERALES',
    );

    // Estilo corregido para headers
    var headerStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.lightBlue,
    );
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .cellStyle =
        headerStyle;

    row += 1;

    // Usar estadísticas corregidas
    final stats = _calculateMonthlyStats(reportes, month, year);

    final estadisticas = [
      ['Total de Reportes:', stats['total'].toString()],
      ['Sin Atender:', stats['sinAtender'].toString()],
      ['En Proceso:', stats['enProceso'].toString()],
      ['Resueltos:', stats['resueltos'].toString()],
      ['En Espera:', stats['enEspera'].toString()],
      ['Tiempo Promedio de Resolución:', '${stats['tiempoPromedio']} días'],
    ];

    for (var stat in estadisticas) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(
        stat[0],
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(
        stat[1],
      );
      row++;
    }
  }

  static Future<void> _createDetailedReportsSheet(
    Excel excel,
    List<ReporteIncidencia> reportes,
    List<DetalleReporte> detalles,
    Map<String, String> areas,
    Map<String, String> tiposReporte,
    Map<String, String> estados,
    Map<String, String> prioridades,
    Map<String, String> usuarios,
    int month,
    int year,
  ) async {
    var sheet = excel['Reportes Detallados'];

    // Filtrar reportes del mes
    final reportesMes = reportes.where((r) {
      if (r.createdAt == null || r.createdAt!.isEmpty) return false;
      try {
        final fecha = DateTime.parse(r.createdAt!);
        return fecha.month == month && fecha.year == year;
      } catch (e) {
        return false;
      }
    }).toList();

    // Headers
    final headers = [
      'ID Reporte',
      'Fecha Creación',
      'Usuario',
      'Área',
      'Tipo Reporte',
      'Descripción',
      'Estado',
      'Prioridad',
      'Técnico Asignado',
      'Descripción Trabajo',
      'Observaciones',
      'Repuestos',
      'Fecha Resolución',
    ];

    // Estilo corregido para headers
    var headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );

    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Datos
    int row = 1;
    for (var reporte in reportesMes) {
      final detalle = detalles.firstWhere(
        (d) => d.idReporteIncidencia == reporte.id,
        orElse: () => DetalleReporte(
          id: '',
          createdAt: '',
          idReporteIncidencia: reporte.id ?? '',
          descripcion: 'N/A',
          observaciones: 'N/A',
          repuestosRequeridos: 'N/A',
          justificacionRepuestos: 'N/A',
        ),
      );

      final rowData = [
        reporte.id ?? 'N/A',
        _formatDate(reporte.createdAt ?? ''),
        usuarios[reporte.idUsuario] ?? 'Usuario no encontrado',
        areas[reporte.idArea] ?? 'Área no encontrada',
        tiposReporte[reporte.idTipoReporte] ?? 'Tipo no encontrado',
        reporte.descripcion ?? 'N/A',
        estados[reporte.idEstadoReporte] ?? 'Estado no encontrado',
        prioridades[reporte.idPrioridad] ?? 'Prioridad no encontrada',
        detalle.idSoporteAsignado ?? 'Sin asignar',
        _safeToString(detalle.descripcion),
        _safeToString(detalle.observaciones),
        detalle.repuestosRequeridos ?? 'N/A',
        _formatDate(detalle.fechaSolucion ?? ''),
      ];

      for (int i = 0; i < rowData.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
            .value = TextCellValue(
          rowData[i],
        );
      }
      row++;
    }

    // Ajustar ancho de columnas
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 20);
    }
  }

  static Future<void> _createStatisticsSheet(
    Excel excel,
    List<ReporteIncidencia> reportes,
    Map<String, String> areas,
    Map<String, String> estados,
    Map<String, String> prioridades,
    int month,
    int year,
  ) async {
    var sheet = excel['Estadísticas'];

    // Filtrar reportes del mes
    final reportesMes = reportes.where((r) {
      if (r.createdAt == null || r.createdAt!.isEmpty) return false;
      try {
        final fecha = DateTime.parse(r.createdAt!);
        return fecha.month == month && fecha.year == year;
      } catch (e) {
        return false;
      }
    }).toList();

    int row = 0;

    // Título
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(
      'ESTADÍSTICAS POR CATEGORÍAS',
    );

    // Estilo corregido
    var titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.amber,
    );
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .cellStyle =
        titleStyle;

    row += 2;

    // Estilo corregido para sub-headers
    var subHeaderStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.lightBlue,
    );

    // Estadísticas por área
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(
      'Reportes por Área:',
    );
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .cellStyle =
        subHeaderStyle;
    row++;

    final reportesPorArea = <String, int>{};
    for (var reporte in reportesMes) {
      final area = areas[reporte.idArea] ?? 'Área no encontrada';
      reportesPorArea[area] = (reportesPorArea[area] ?? 0) + 1;
    }

    for (var entry in reportesPorArea.entries) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(
        entry.key,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = IntCellValue(
        entry.value,
      );
      row++;
    }

    row += 2;

    // Estadísticas por estado
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(
      'Reportes por Estado:',
    );
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .cellStyle =
        subHeaderStyle;
    row++;

    final reportesPorEstado = <String, int>{};
    for (var reporte in reportesMes) {
      final estado = estados[reporte.idEstadoReporte] ?? 'Estado no encontrado';
      reportesPorEstado[estado] = (reportesPorEstado[estado] ?? 0) + 1;
    }

    for (var entry in reportesPorEstado.entries) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(
        entry.key,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = IntCellValue(
        entry.value,
      );
      row++;
    }

    row += 2;

    // Estadísticas por prioridad
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(
      'Reportes por Prioridad:',
    );
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .cellStyle =
        subHeaderStyle;
    row++;

    final reportesPorPrioridad = <String, int>{};
    for (var reporte in reportesMes) {
      final prioridad =
          prioridades[reporte.idPrioridad] ?? 'Prioridad no encontrada';
      reportesPorPrioridad[prioridad] =
          (reportesPorPrioridad[prioridad] ?? 0) + 1;
    }

    for (var entry in reportesPorPrioridad.entries) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(
        entry.key,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = IntCellValue(
        entry.value,
      );
      row++;
    }
  }

  // Método corregido que usa los IDs específicos de tu sistema
  static Map<String, dynamic> _calculateMonthlyStats(
    List<ReporteIncidencia> reportes,
    int month,
    int year,
  ) {
    final reportesMes = reportes.where((r) {
      if (r.createdAt == null || r.createdAt!.isEmpty) return false;
      try {
        final fecha = DateTime.parse(r.createdAt!);
        return fecha.month == month && fecha.year == year;
      } catch (e) {
        return false;
      }
    }).toList();

    int resueltos = 0;
    int sinAtender = 0;
    int enProceso = 0;
    int enEspera = 0;
    int totalDias = 0;
    int reportesResueltos = 0;

    for (var reporte in reportesMes) {
      // Usar los mismos IDs que en tu provider
      switch (reporte.idEstadoReporte) {
        case "52c2b7bc-194c-4759-b83c-3913625da86d": // Resuelto
          resueltos++;
          // Calcular tiempo de resolución
          if (reporte.createdAt != null && reporte.createdAt!.isNotEmpty) {
            try {
              final fechaCreacion = DateTime.parse(reporte.createdAt!);
              final fechaResolucion = DateTime.now();
              totalDias += fechaResolucion.difference(fechaCreacion).inDays;
              reportesResueltos++;
            } catch (e) {
              print('Error calculando tiempo de resolución: $e');
            }
          }
          break;
        case "29e11cdf-fcf7-4c36-a7fd-f363dcaf864c": // Nuevo (sin atender)
          sinAtender++;
          break;
        case "cb56bfbe-6fd4-4d0b-ad5b-3bb31194e223": // En proceso
          enProceso++;
          break;
        case "afab4980-5c12-4457-88a2-c3cd0bb198e1": // En espera
          enEspera++;
          break;
        default:
          // Estados desconocidos se consideran "sin atender"
          print('Estado desconocido: ${reporte.idEstadoReporte}');
          sinAtender++;
          break;
      }
    }

    return {
      'total': reportesMes.length,
      'resueltos': resueltos,
      'sinAtender': sinAtender,
      'enProceso': enProceso,
      'enEspera': enEspera,
      'tiempoPromedio': reportesResueltos > 0
          ? (totalDias / reportesResueltos).round()
          : 0,
    };
  }

  // Método helper para manejar campos dynamic
  static String _safeToString(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String) return value.isEmpty ? 'N/A' : value;
    return value.toString();
  }

  static String _getMonthName(int month) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month];
  }

  static String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
