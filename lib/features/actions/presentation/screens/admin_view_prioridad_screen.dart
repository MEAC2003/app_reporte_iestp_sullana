import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class AdminViewPrioridadScreen extends StatefulWidget {
  const AdminViewPrioridadScreen({super.key});

  @override
  State<AdminViewPrioridadScreen> createState() =>
      _AdminViewPrioridadScreenState();
}

class _AdminViewPrioridadScreenState extends State<AdminViewPrioridadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminActionProvider>().loadPrioridades();
    });
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
          'Prioridades',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRouter.adminPriorityReporteAdd),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminActionProvider>().loadPrioridades(),
        child: SafeArea(
          child: SingleChildScrollView(
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
                        context.read<AdminActionProvider>().searchPrioridades(
                          value,
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar prioridades...',
                        hintStyle: AppStyles.h4(color: AppColors.darkColor50),
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSize.defaultPadding * 2),

                  // Prioridades Grid
                  Consumer<AdminActionProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final prioridades = provider.filteredPrioridades;

                      if (prioridades.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.priority_high,
                                size: 64,
                                color: AppColors.darkColor50,
                              ),
                              SizedBox(height: AppSize.defaultPadding),
                              Text(
                                'No hay prioridades disponibles',
                                style: AppStyles.h4(color: AppColors.darkColor),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                        itemCount: prioridades.length,
                        itemBuilder: (context, index) {
                          final prioridad = prioridades[index];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                context.push(
                                  '${AppRouter.adminPriorityReporteDetail}/${prioridad.id}',
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(AppSize.defaultPadding),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.priority_high,
                                      size: 48,
                                      color: AppColors.primaryColor,
                                    ),
                                    SizedBox(height: AppSize.defaultPadding),
                                    Text(
                                      prioridad.nombre,
                                      style: AppStyles.h4(
                                        color: AppColors.darkColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
