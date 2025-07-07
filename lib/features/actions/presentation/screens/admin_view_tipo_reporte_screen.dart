import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class AdminViewTipoReporteScreen extends StatefulWidget {
  const AdminViewTipoReporteScreen({super.key});

  @override
  State<AdminViewTipoReporteScreen> createState() =>
      _AdminViewTipoReporteScreenState();
}

class _AdminViewTipoReporteScreenState
    extends State<AdminViewTipoReporteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminActionProvider>().loadTiposReporte();
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
          'Tipos de Reporte',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRouter.adminTipoReporteAdd),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminActionProvider>().loadTiposReporte(),
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
                        context.read<AdminActionProvider>().searchTiposReporte(
                          value,
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar tipos de reporte...',
                        hintStyle: AppStyles.h4(color: AppColors.darkColor50),
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSize.defaultPadding * 2),

                  // Tipos Grid
                  Consumer<AdminActionProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final tipos = provider.filteredTiposReporte;

                      if (tipos.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.report,
                                size: 64,
                                color: AppColors.darkColor50,
                              ),
                              SizedBox(height: AppSize.defaultPadding),
                              Text(
                                'No hay tipos de reporte disponibles',
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
                        itemCount: tipos.length,
                        itemBuilder: (context, index) {
                          final tipo = tipos[index];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                context.push(
                                  '${AppRouter.adminTipoReporteDetail}/${tipo.id}',
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(AppSize.defaultPadding),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.report,
                                      size: 48,
                                      color: AppColors.primaryColor,
                                    ),
                                    SizedBox(height: AppSize.defaultPadding),
                                    Text(
                                      tipo.nombre,
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
