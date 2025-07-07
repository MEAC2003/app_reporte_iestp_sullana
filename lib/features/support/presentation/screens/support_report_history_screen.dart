import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/models/models.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupportHistoryScreen extends StatelessWidget {
  const SupportHistoryScreen({super.key});

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
          'Mi Historial de Reportes',
          style: AppStyles.h3p5(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const _SupportHistoryView(),
    );
  }
}

class _SupportHistoryView extends StatefulWidget {
  const _SupportHistoryView();

  @override
  State<_SupportHistoryView> createState() => _SupportHistoryViewState();
}

class _SupportHistoryViewState extends State<_SupportHistoryView> {
  List<ReporteIncidencia> _historialTickets = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedFilter = 'todos'; // todos, resuelto, completados, cancelados

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistorial();
    });
  }

  Future<void> _loadHistorial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<AdminActionProvider>();
      final userProvider = context.read<UserProvider>();

      // Cargar datos necesarios
      await provider.loadInitialData();
      await userProvider.getUsers();
      await provider.loadUsuariosPublicos();

      // Obtener ID del usuario actual (soporte técnico)
      final currentUserId = await _getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('No se pudo obtener el ID del usuario actual');
      }

      // Obtener reportes asignados a este soporte
      final reportesAsignados = await provider.getReportesBySoporteId(
        currentUserId,
      );

      // Filtrar solo los finalizados o cancelados
      final historial = reportesAsignados.where((reporte) {
        final estadoNombre = _getEstadoNombre(
          reporte.idEstadoReporte,
          provider,
        );
        return _esTicketFinalizado(estadoNombre);
      }).toList();

      // Ordenar por fecha (más reciente primero)
      historial.sort((a, b) {
        final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _historialTickets = historial;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el historial: $e';
        _isLoading = false;
      });
    }
  }

  Future<String?> _getCurrentUserId() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      return user?.id;
    } catch (e) {
      print('Error obteniendo ID del usuario: $e');
      return null;
    }
  }

  String _getEstadoNombre(String estadoId, AdminActionProvider provider) {
    try {
      final estado = provider.estadosReporte.firstWhere(
        (e) => e.id == estadoId,
      );
      return estado.nombre;
    } catch (e) {
      return 'Desconocido';
    }
  }

  bool _esTicketFinalizado(String estadoNombre) {
    final estadosFinalizados = [
      'resuelto',
      'completado',
      'finalizado',
      'cerrado',
      'cancelado',
      'terminado',
    ];

    return estadosFinalizados.any(
      (estado) => estadoNombre.toLowerCase().contains(estado),
    );
  }

  List<ReporteIncidencia> get _filteredTickets {
    List<ReporteIncidencia> filtered = _historialTickets;

    // Aplicar filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ticket) {
        return ticket.descripcion.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (ticket.id?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Aplicar filtro de estado
    if (_selectedFilter != 'todos') {
      filtered = filtered.where((ticket) {
        final provider = context.read<AdminActionProvider>();
        final estadoNombre = _getEstadoNombre(ticket.idEstadoReporte, provider);

        if (_selectedFilter == 'resuelto') {
          return estadoNombre.toLowerCase().contains('resuelto');
        } else if (_selectedFilter == 'completados') {
          return estadoNombre.toLowerCase().contains('cerrado');
        } else if (_selectedFilter == 'cancelados') {
          return estadoNombre.toLowerCase().contains('cancelado');
        }
        return true;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header con estadísticas
        _buildStatsHeader(),

        // Filtros y búsqueda
        _buildFiltersSection(),

        // Lista de tickets
        Expanded(child: _buildTicketsList()),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final resueltos = _historialTickets.where((ticket) {
      final provider = context.read<AdminActionProvider>();
      final estadoNombre = _getEstadoNombre(ticket.idEstadoReporte, provider);
      return estadoNombre.toLowerCase().contains('resuelto');
    }).length;

    final cerrados = _historialTickets.where((ticket) {
      final provider = context.read<AdminActionProvider>();
      final estadoNombre = _getEstadoNombre(ticket.idEstadoReporte, provider);
      return estadoNombre.toLowerCase().contains('cerrado');
    }).length;

    final cancelados = _historialTickets.where((ticket) {
      final provider = context.read<AdminActionProvider>();
      final estadoNombre = _getEstadoNombre(ticket.idEstadoReporte, provider);
      return estadoNombre.toLowerCase().contains('cancelado');
    }).length;

    return Container(
      margin: EdgeInsets.all(AppSize.defaultPadding),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppColors.primaryColor),
              SizedBox(width: AppSize.defaultPadding * 0.5),
              Text(
                'Resumen del Historial',
                style: AppStyles.h4(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.defaultPadding),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total',
                  value: '${_historialTickets.length}',
                  color: AppColors.primaryColor,
                  icon: Icons.assignment,
                ),
              ),
              SizedBox(width: AppSize.defaultPadding * 0.5),
              Expanded(
                child: _buildStatCard(
                  title: 'Resueltos',
                  value: '$resueltos',
                  color: Colors.blue,
                  icon: Icons.check_circle_outline,
                ),
              ),
              SizedBox(width: AppSize.defaultPadding * 0.5),
              Expanded(
                child: _buildStatCard(
                  title: 'Cerrados',
                  value: '$cerrados',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              SizedBox(width: AppSize.defaultPadding * 0.5),
              Expanded(
                child: _buildStatCard(
                  title: 'Cancelados',
                  value: '$cancelados',
                  color: Colors.red,
                  icon: Icons.cancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppSize.defaultPadding * 0.25),
          Text(
            value,
            style: AppStyles.h3(color: color, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSize.defaultPadding * 0.25),
          Text(
            title,
            style: AppStyles.h5(
              color: AppColors.darkColor50,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSize.defaultPadding),
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
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar en historial...',
              hintStyle: AppStyles.h5(color: AppColors.darkColor50),
              prefixIcon: Icon(Icons.search, color: AppColors.darkColor50),
              filled: true,
              fillColor: AppColors.primaryGrey.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(height: AppSize.defaultPadding),

          // Filtros de estado
          Row(
            children: [
              Text(
                'Filtrar por:',
                style: AppStyles.h5(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: AppSize.defaultPadding),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('todos', 'Todos'),
                      SizedBox(width: AppSize.defaultPadding * 0.5),
                      _buildFilterChip('resuelto', 'Resuelto'),
                      SizedBox(width: AppSize.defaultPadding * 0.5),
                      _buildFilterChip('completados', 'Cerrados'),
                      SizedBox(width: AppSize.defaultPadding * 0.5),
                      _buildFilterChip('cancelados', 'Cancelados'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey.withOpacity(0.1),
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: AppStyles.h5(
        color: isSelected ? AppColors.primaryColor : AppColors.darkColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildTicketsList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: AppSize.defaultPadding),
            Text(
              'Cargando historial...',
              style: AppStyles.h4(color: AppColors.darkColor50),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(AppSize.defaultPadding),
          padding: EdgeInsets.all(AppSize.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              SizedBox(height: AppSize.defaultPadding),
              Text(
                'Error al cargar',
                style: AppStyles.h3(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding * 0.5),
              Text(
                _error!,
                style: AppStyles.h4(color: AppColors.darkColor50),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSize.defaultPadding),
              ElevatedButton(
                onPressed: _loadHistorial,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredTickets = _filteredTickets;

    if (filteredTickets.isEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppSize.defaultPadding),
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_outlined,
                size: 64,
                color: AppColors.darkColor50,
              ),
              SizedBox(height: AppSize.defaultPadding),
              Text(
                'Sin historial',
                style: AppStyles.h3(
                  color: AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding * 0.5),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No se encontraron tickets con "$_searchQuery"'
                    : 'Aún no tienes tickets finalizados en tu historial.',
                style: AppStyles.h4(color: AppColors.darkColor50),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistorial,
      child: ListView.builder(
        padding: EdgeInsets.all(AppSize.defaultPadding),
        itemCount: filteredTickets.length,
        itemBuilder: (context, index) {
          final ticket = filteredTickets[index];
          return _HistoryTicketCard(
            ticket: ticket,
            onTap: () {
              // Navegar al detalle del reporte
              context.push('${AppRouter.supportTicketDetail}/${ticket.id}');
            },
          );
        },
      ),
    );
  }
}

class _HistoryTicketCard extends StatelessWidget {
  final ReporteIncidencia ticket;
  final VoidCallback onTap;

  const _HistoryTicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AdminActionProvider, UserProvider>(
      builder: (context, provider, userProvider, child) {
        // Obtener información relacionada
        String estadoNombre = 'Desconocido';
        String areaNombre = 'Desconocido';
        String prioridadNombre = 'Desconocido';
        String usuarioNombre = 'Desconocido';
        Color estadoColor = Colors.grey;

        try {
          final estado = provider.estadosReporte.firstWhere(
            (e) => e.id == ticket.idEstadoReporte,
          );
          estadoNombre = estado.nombre;
          estadoColor = _getEstadoColor(estadoNombre);
        } catch (e) {}

        try {
          final area = provider.areas.firstWhere((a) => a.id == ticket.idArea);
          areaNombre = area.nombre;
        } catch (e) {}

        try {
          final prioridad = provider.prioridades.firstWhere(
            (p) => p.id == ticket.idPrioridad,
          );
          prioridadNombre = prioridad.nombre;
        } catch (e) {}

        try {
          final usuario = userProvider.users.firstWhere(
            (u) => u.id == ticket.idUsuario,
          );
          usuarioNombre = usuario.nombre;
        } catch (e) {}

        return Container(
          margin: EdgeInsets.only(bottom: AppSize.defaultPadding),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(AppSize.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con ID y estado
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSize.defaultPadding * 0.75,
                            vertical: AppSize.defaultPadding * 0.25,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${ticket.id?.substring(0, 8) ?? 'N/A'}',
                            style: AppStyles.h5(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSize.defaultPadding * 0.75,
                            vertical: AppSize.defaultPadding * 0.25,
                          ),
                          decoration: BoxDecoration(
                            color: estadoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: estadoColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: estadoColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: AppSize.defaultPadding * 0.25),
                              Text(
                                estadoNombre,
                                style: AppStyles.h5(
                                  color: estadoColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSize.defaultPadding * 0.75),

                    // Descripción
                    Text(
                      ticket.descripcion,
                      style: AppStyles.h4(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppSize.defaultPadding * 0.75),

                    // Información adicional
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppColors.darkColor50,
                        ),
                        SizedBox(width: AppSize.defaultPadding * 0.25),
                        Expanded(
                          child: Text(
                            usuarioNombre,
                            style: AppStyles.h5(color: AppColors.darkColor50),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: AppSize.defaultPadding),
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.darkColor50,
                        ),
                        SizedBox(width: AppSize.defaultPadding * 0.25),
                        Text(
                          areaNombre,
                          style: AppStyles.h5(color: AppColors.darkColor50),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSize.defaultPadding * 0.5),

                    // Fecha y prioridad
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.darkColor50,
                        ),
                        SizedBox(width: AppSize.defaultPadding * 0.25),
                        Text(
                          _formatDate(ticket.createdAt ?? ''),
                          style: AppStyles.h5(color: AppColors.darkColor50),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSize.defaultPadding * 0.5,
                            vertical: AppSize.defaultPadding * 0.2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPrioridadColor(
                              prioridadNombre,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            prioridadNombre,
                            style: AppStyles.h5(
                              color: _getPrioridadColor(prioridadNombre),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'resuelto':
        return Colors.blue;
      case 'completado':
      case 'finalizado':
      case 'cerrado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
