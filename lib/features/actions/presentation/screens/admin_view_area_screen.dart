import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class AdminViewAreaScreen extends StatefulWidget {
  const AdminViewAreaScreen({super.key});

  @override
  State<AdminViewAreaScreen> createState() => _AdminViewAreaScreenState();
}

class _AdminViewAreaScreenState extends State<AdminViewAreaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminActionProvider>().loadAreas();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AdminActionProvider>().loadAreas();
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
          'Áreas',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRouter.adminAreaAdd),
          ),
        ],
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
                            context.read<AdminActionProvider>().searchAreas(
                              value,
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar áreas...',
                            hintStyle: AppStyles.h4(
                              color: AppColors.darkColor50,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Areas Grid
              Consumer<AdminActionProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final areas = provider.filteredAreas;

                  if (areas.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.domain,
                              size: 64,
                              color: AppColors.darkColor50,
                            ),
                            SizedBox(height: AppSize.defaultPadding),
                            Text(
                              'No hay áreas disponibles',
                              style: AppStyles.h4(color: AppColors.darkColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.all(AppSize.defaultPadding),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final area = areas[index];
                        return Card(
                          child: InkWell(
                            onTap: () {
                              context.push(
                                '${AppRouter.adminAreaDetail}/${area.id}',
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(AppSize.defaultPadding),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.domain,
                                    size: 48,
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(height: AppSize.defaultPadding),
                                  Text(
                                    area.nombre,
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
                      }, childCount: areas.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
