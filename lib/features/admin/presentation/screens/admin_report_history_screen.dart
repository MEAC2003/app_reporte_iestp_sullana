import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/widgets/admin_report_card.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminActionProvider>();
      provider.loadReportes();
      provider.loadEstadosReporte();
      provider.loadPrioridades();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AdminActionProvider>().loadReportes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Reportes',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSize.defaultPadding),
                  child: Column(
                    children: [
                      // Search TextField
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 240, 243, 243),
                              Color.fromARGB(255, 243, 241, 241),
                              Color.fromARGB(255, 231, 231, 231),
                            ],
                            stops: [0.03, 0.12, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSize.defaultRadius,
                          ),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            context.read<AdminActionProvider>().searchReportes(
                              value,
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar reportes...',
                            hintStyle: AppStyles.h4(
                              color: AppColors.darkColor50,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSize.defaultPadding),

                      // Botón de filtros y filtros activos
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showFilters = !_showFilters;
                              });
                            },
                            icon: Icon(
                              _showFilters
                                  ? Icons.expand_less
                                  : Icons.filter_list,
                            ),
                            label: const Text('Filtros'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Consumer<AdminActionProvider>(
                            builder: (context, provider, _) {
                              return TextButton(
                                onPressed: () {
                                  provider.clearAllFilters();
                                },
                                child: Text(
                                  'Limpiar filtros',
                                  style: AppStyles.h5(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // Filtros expandibles
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _showFilters ? null : 0,
                        child: _showFilters
                            ? _buildFiltersSection()
                            : const SizedBox(),
                      ),

                      SizedBox(height: AppSize.defaultPadding),
                    ],
                  ),
                ),
              ),

              // Lista de reportes
              Consumer<AdminActionProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final reportes = provider.filteredReportes;

                  if (reportes.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false, // AGREGAR ESTA LÍNEA
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, // AGREGAR ESTA LÍNEA
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: AppColors.darkColor50,
                            ),
                            SizedBox(height: AppSize.defaultPadding),
                            Text(
                              'No hay reportes disponibles',
                              style: AppStyles.h4(color: AppColors.darkColor),
                              textAlign: TextAlign.center, // AGREGAR ESTA LÍNEA
                            ),
                            SizedBox(
                              height: AppSize.defaultPadding,
                            ), // AGREGAR PADDING EXTRA
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final reporte = reportes[index];
                      return AdminReportCard(
                        id: reporte.id ?? 'Sin ID',
                        description: reporte.descripcion,
                        date: provider.formatDate(reporte.createdAt),
                        imageUrl: reporte.urlImg,
                        status: provider.getStatusName(reporte.idEstadoReporte),
                        statusColor: provider.getStatusColor(
                          reporte.idEstadoReporte,
                        ),
                        onTap: () {
                          context.push(
                            '${AppRouter.adminReportDetail}/${reporte.id}',
                          );
                        },
                      );
                    }, childCount: reportes.length),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Consumer<AdminActionProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.all(AppSize.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(AppSize.defaultRadius),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtro por Estado
              Text(
                'Estado',
                style: AppStyles.h4(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding * 0.5),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildFilterChip(
                    'todos',
                    'Todos',
                    provider,
                    FilterType.status,
                  ),
                  ...provider.estadosReporte.map(
                    (estado) => _buildFilterChip(
                      estado.id,
                      estado.nombre,
                      provider,
                      FilterType.status,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Filtro por Prioridad
              Text(
                'Prioridad',
                style: AppStyles.h4(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding * 0.5),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildFilterChip(
                    'todos',
                    'Todos',
                    provider,
                    FilterType.priority,
                  ),
                  ...provider.prioridades.map(
                    (prioridad) => _buildFilterChip(
                      prioridad.id,
                      prioridad.nombre,
                      provider,
                      FilterType.priority,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSize.defaultPadding),

              // Filtro por Fecha
              Text(
                'Fecha',
                style: AppStyles.h4(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding * 0.5),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDateRange(context, provider),
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        provider.selectedDateRange ?? 'Seleccionar rango',
                      ),
                    ),
                  ),
                  if (provider.selectedDateRange != null) ...[
                    SizedBox(width: AppSize.defaultPadding * 0.5),
                    IconButton(
                      onPressed: () => provider.clearDateFilter(),
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpiar fecha',
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
    AdminActionProvider provider,
    FilterType type,
  ) {
    bool isSelected = false;

    switch (type) {
      case FilterType.status:
        isSelected = provider.selectedStatusFilter == value;
        break;
      case FilterType.priority:
        isSelected = provider.selectedPriorityFilter == value;
        break;
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        switch (type) {
          case FilterType.status:
            provider.filterReportesByStatus(value);
            break;
          case FilterType.priority:
            provider.filterReportesByPriority(value);
            break;
        }
      },
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: AppStyles.h5(
        color: isSelected ? AppColors.primaryColor : AppColors.darkColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Future<void> _selectDateRange(
    BuildContext context,
    AdminActionProvider provider,
  ) async {
    // Mostrar opciones: rango o día único
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar fecha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Un día específico'),
              onTap: () => Navigator.pop(context, 'single'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Rango de fechas'),
              onTap: () => Navigator.pop(context, 'range'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;

    if (choice == 'single') {
      // Seleccionar un solo día
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        // Crear un rango del mismo día
        final sameDay = DateTimeRange(start: picked, end: picked);
        provider.filterReportesByDateRange(sameDay);
      }
    } else {
      // Seleccionar rango de fechas
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDateRange: provider.dateRange,
      );

      if (picked != null) {
        provider.filterReportesByDateRange(picked);
      }
    }
  }
}

enum FilterType { status, priority }
