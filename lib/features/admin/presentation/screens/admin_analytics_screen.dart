import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.defaultPaddingHorizontal * 1.5.w,
          ),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.darkColor),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Estadísticas y Reportes',
          style: AppStyles.h3p5(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const _AdminAnalyticsView(),
    );
  }
}

class _AdminAnalyticsView extends StatefulWidget {
  const _AdminAnalyticsView();

  @override
  State<_AdminAnalyticsView> createState() => _AdminAnalyticsViewState();
}

class _AdminAnalyticsViewState extends State<_AdminAnalyticsView> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminActionProvider>().loadInitialData();
    });
  }

  Future<void> _generateExcelReport() async {
    setState(() {
      isGenerating = true;
    });

    try {
      final provider = context.read<AdminActionProvider>();
      final success = await provider.generateMonthlyExcelReport(
        selectedMonth,
        selectedYear,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reporte Excel generado exitosamente',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Busca el archivo en: Descargas o Reportes_IESTP',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 6),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: AppSize.defaultPadding * 0.5),
                Text('Error al generar el reporte Excel'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar Período'),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Text('Mes:', style: AppStyles.h4(fontWeight: FontWeight.w600)),
              DropdownButton<int>(
                value: selectedMonth,
                isExpanded: true,
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem(
                    value: month,
                    child: Text(_getMonthName(month)),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value!;
                  });
                },
              ),
              SizedBox(height: AppSize.defaultPadding),
              Text('Año:', style: AppStyles.h4(fontWeight: FontWeight.w600)),
              DropdownButton<int>(
                value: selectedYear,
                isExpanded: true,
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Seleccionar'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminActionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: AppSize.defaultPadding),
                Text(
                  'Cargando estadísticas...',
                  style: AppStyles.h4(color: AppColors.darkColor50),
                ),
              ],
            ),
          );
        }

        // Usar el nuevo método específico para analytics
        final monthlyStats = provider.getAnalyticsMonthlyStatistics(
          selectedMonth,
          selectedYear,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSize.defaultPadding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de período seleccionado
              _buildPeriodHeader(),

              SizedBox(height: AppSize.defaultPadding * 1.5),

              // Estadísticas del mes
              Text(
                'Estadísticas del Período',
                style: AppStyles.h3(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding),

              // Grid de estadísticas
              _buildStatsGrid(monthlyStats),

              SizedBox(height: AppSize.defaultPadding * 2),

              // Sección de generación de reportes
              _buildReportGenerationSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppColors.primaryColor),
          SizedBox(width: AppSize.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Período Seleccionado',
                  style: AppStyles.h5(color: AppColors.darkColor50),
                ),
                Text(
                  '${_getMonthName(selectedMonth)} $selectedYear',
                  style: AppStyles.h3(
                    color: AppColors.darkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showMonthYearPicker,
            icon: Icon(Icons.edit_calendar, size: 18),
            label: Text('Cambiar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.defaultPadding,
                vertical: AppSize.defaultPadding * 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> monthlyStats) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSize.defaultPadding * 0.75,
      mainAxisSpacing: AppSize.defaultPadding * 0.75,
      childAspectRatio: 1.2, // Ajustado para evitar overflow
      children: [
        _buildStatCard(
          'Total Reportes',
          monthlyStats['total']!,
          Icons.assignment,
          Colors.blue,
        ),
        _buildStatCard(
          'Sin Atender',
          monthlyStats['sinAtender']!,
          Icons.hourglass_empty,
          Colors.orange,
        ),
        _buildStatCard(
          'En Proceso',
          monthlyStats['enProceso']!,
          Icons.build,
          Colors.purple,
        ),
        _buildStatCard(
          'Resueltos',
          monthlyStats['resueltos']!,
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildReportGenerationSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.defaultPadding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: AppColors.primaryColor, size: 28),
              SizedBox(width: AppSize.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generar Reporte Excel',
                      style: AppStyles.h3(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Descarga un reporte detallado en formato Excel',
                      style: AppStyles.h5(color: AppColors.darkColor50),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSize.defaultPadding),

          Container(
            padding: EdgeInsets.all(AppSize.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El reporte incluye:',
                  style: AppStyles.h5(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSize.defaultPadding * 0.5),
                ...[
                  'Resumen estadístico del período',
                  'Lista detallada de todos los reportes',
                  'Estadísticas por área y estado',
                  'Información técnica completa',
                ].map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: AppStyles.h5(color: Colors.green[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSize.defaultPadding * 1.5),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : _generateExcelReport,
              icon: isGenerating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.download),
              label: Text(
                isGenerating
                    ? 'Generando reporte...'
                    : 'Descargar Reporte Excel',
                style: AppStyles.h4(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isGenerating
                    ? Colors.grey
                    : AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppSize.defaultPadding),
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

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppSize.defaultPadding * 0.6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.defaultPadding * 0.3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(height: AppSize.defaultPadding * 0.25),
          Text(
            value.toString(),
            style: AppStyles.h3(
              color: AppColors.darkColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSize.defaultPadding * 0.15),
          Flexible(
            child: Text(
              title,
              style: AppStyles.h5(color: AppColors.darkColor50),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
