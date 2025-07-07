// lib/features/support/presentation/screens/support_tickets_assigned_screen.dart
import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/support/presentation/providers/support_provider.dart';
import 'package:app_reporte_iestp_sullana/features/support/presentation/widgets/widget.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SupportTicketsAssignedScreen extends StatefulWidget {
  const SupportTicketsAssignedScreen({super.key});

  @override
  State<SupportTicketsAssignedScreen> createState() =>
      _SupportTicketsAssignedScreenState();
}

class _SupportTicketsAssignedScreenState
    extends State<SupportTicketsAssignedScreen> {
  bool _showFilters = false;
  String _selectedPriorityFilter = 'todos';
  String _selectedStatusFilter = 'todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SupportProvider>();
      provider.initialize();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<SupportProvider>().refresh();
  }

  static const List<String> _estadosExcluidos = [
    "d2d0cc74-0a47-4626-9571-adc8c07a8be0", // Cerrado
    "1d7db7fb-5bbe-4c5a-a24e-2930fdc8289e", // Cancelado
  ];

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
          'Tickets Asignados',
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
                            // Implementar búsqueda local aquí si es necesario
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar tickets...',
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
                          Consumer<SupportProvider>(
                            builder: (context, provider, _) {
                              return TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedPriorityFilter = 'todos';
                                    _selectedStatusFilter = 'todos';
                                  });
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

              // Lista de tickets
              Consumer<SupportProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoadingTickets) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.error != null) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error, size: 64, color: Colors.red),
                            SizedBox(height: AppSize.defaultPadding),
                            Text(
                              provider.error!,
                              style: AppStyles.h4(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppSize.defaultPadding),
                            ElevatedButton(
                              onPressed: () => provider.refresh(),
                              child: Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Aplicar filtros locales
                  final ticketsFiltrados = _filtrarTickets(
                    provider.ticketsAsignados,
                    provider,
                  );

                  if (ticketsFiltrados.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: AppColors.darkColor50,
                            ),
                            SizedBox(height: AppSize.defaultPadding),
                            Text(
                              _selectedPriorityFilter != 'todos' ||
                                      _selectedStatusFilter != 'todos'
                                  ? 'No hay tickets que coincidan con los filtros'
                                  : 'No tienes tickets asignados',
                              style: AppStyles.h4(color: AppColors.darkColor),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppSize.defaultPadding),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final ticket = ticketsFiltrados[index];
                      return SupportTicketCard(
                        ticket: ticket,
                        provider: provider,
                        onTap: () {
                          context.push(
                            '${AppRouter.supportTicketDetail}/${ticket.id}',
                          );
                        },
                      );
                    }, childCount: ticketsFiltrados.length),
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
    return Consumer<SupportProvider>(
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
                  _buildFilterChip('todos', 'Todos', FilterType.status),
                  // Filtrar estados excluidos de los filtros
                  ...provider.estadosMap.entries
                      .where((entry) => !_estadosExcluidos.contains(entry.key))
                      .map(
                        (entry) => _buildFilterChip(
                          entry.key,
                          entry.value,
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
                  _buildFilterChip('todos', 'Todos', FilterType.priority),
                  ...provider.prioridadesMap.entries.map(
                    (entry) => _buildFilterChip(
                      entry.key,
                      entry.value,
                      FilterType.priority,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String value, String label, FilterType type) {
    bool isSelected = false;

    switch (type) {
      case FilterType.status:
        isSelected = _selectedStatusFilter == value;
        break;
      case FilterType.priority:
        isSelected = _selectedPriorityFilter == value;
        break;
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          switch (type) {
            case FilterType.status:
              _selectedStatusFilter = value;
              break;
            case FilterType.priority:
              _selectedPriorityFilter = value;
              break;
          }
        });
      },
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: AppStyles.h5(
        color: isSelected ? AppColors.primaryColor : AppColors.darkColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // Método para filtrar tickets localmente
  List<dynamic> _filtrarTickets(
    List<dynamic> tickets,
    SupportProvider provider,
  ) {
    return tickets.where((ticket) {
      // Filtro por prioridad
      if (_selectedPriorityFilter != 'todos' &&
          ticket.idPrioridad != _selectedPriorityFilter) {
        return false;
      }

      // Filtro por estado
      if (_selectedStatusFilter != 'todos' &&
          ticket.idEstadoReporte != _selectedStatusFilter) {
        return false;
      }

      return true;
    }).toList();
  }
}

enum FilterType { status, priority }
