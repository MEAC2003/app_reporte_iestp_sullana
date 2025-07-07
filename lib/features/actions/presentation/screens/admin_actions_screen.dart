import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminActionsScreen extends StatelessWidget {
  const AdminActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Acciones',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const _AdminActionsView(),
    );
  }
}

class _AdminActionsView extends StatefulWidget {
  const _AdminActionsView();

  @override
  State<_AdminActionsView> createState() => _AdminActionsViewState();
}

class _AdminActionsViewState extends State<_AdminActionsView> {
  @override
  Widget build(BuildContext context) {
    String? selectedOption;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.defaultPaddingHorizontal * 1.5,
        ),
        child: Column(
          children: [
            SizedBox(height: AppSize.defaultPadding * 1.5),
            //View
            DropdownButton<String>(
              isExpanded: true,
              underline: Container(),
              value: selectedOption,
              style: AppStyles.h3(
                fontWeight: FontWeight.w600,
                color: AppColors.darkColor,
              ),
              hint: Row(
                children: [
                  const Icon(Icons.remove_red_eye),
                  SizedBox(width: AppSize.defaultPaddingHorizontal * 0.2),
                  Text(
                    'Ver',
                    style: AppStyles.h3(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkColor,
                    ),
                  ),
                ],
              ),

              items: [
                DropdownMenuItem(
                  value: 'areas',
                  child: Row(
                    children: [
                      const Icon(Icons.domain),
                      SizedBox(width: AppSize.defaultPaddingHorizontal * 0.65),
                      const Text('Áreas'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'estados',
                  child: Row(
                    children: [
                      const Icon(Icons.flag),
                      SizedBox(width: AppSize.defaultPaddingHorizontal * 0.65),
                      const Text('Estados del Reporte'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'prioridades',
                  child: Row(
                    children: [
                      const Icon(Icons.priority_high),
                      SizedBox(width: AppSize.defaultPaddingHorizontal * 0.65),
                      const Text('Prioridades'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'tipos_reportes',
                  child: Row(
                    children: [
                      const Icon(Icons.assignment),
                      SizedBox(width: AppSize.defaultPaddingHorizontal * 0.65),
                      const Text('Tipos de Reportes'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                  switch (value) {
                    case 'areas':
                      context.push(AppRouter.adminViewArea);
                      break;
                    case 'estados':
                      context.push(AppRouter.adminViewEstadoReporte);
                      break;
                    case 'prioridades':
                      context.push(AppRouter.adminViewPriorityReporte);
                      break;
                    case 'tipos_reportes':
                      context.push(AppRouter.adminViewTipoReporte);
                      break;
                  }
                });
              },
            ),
            //Add
            SizedBox(height: AppSize.defaultPadding),
            DropdownButton<String>(
              isExpanded: true,
              underline: Container(),
              value: selectedOption,
              style: AppStyles.h3(
                fontWeight: FontWeight.w600,
                color: AppColors.darkColor,
              ),
              hint: Row(
                children: [
                  const Icon(Icons.add),
                  SizedBox(width: AppSize.defaultPaddingHorizontal * 0.2),
                  Text(
                    'Agregar',
                    style: AppStyles.h3(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkColor,
                    ),
                  ),
                ],
              ),
              items: [
                DropdownMenuItem(
                  value: 'area',
                  child: Row(
                    children: [
                      const Icon(Icons.domain),
                      SizedBox(width: AppSize.defaultPaddingHorizontal * 0.65),
                      const Text('Área'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'estado',
                  child: Row(
                    children: [
                      const Icon(Icons.flag),
                      SizedBox(width: AppSize.defaultPaddingHorizontal * 0.65),
                      const Text('Estado del Reporte'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'prioridad',
                  child: Row(
                    children: [
                      const Icon(Icons.priority_high),
                      SizedBox(width: AppSize.defaultPaddingHorizontal * 0.65),
                      const Text('Prioridad'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'tipo_reporte',
                  child: Row(
                    children: [
                      const Icon(Icons.assignment),
                      SizedBox(width: AppSize.defaultPaddingHorizontal * 0.65),
                      const Text('Tipo de Reporte'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                  switch (value) {
                    case 'area':
                      context.push(AppRouter.adminAreaAdd);
                      break;
                    case 'estado':
                      context.push(AppRouter.adminEstadoReporteAdd);
                      break;
                    case 'prioridad':
                      context.push(AppRouter.adminPriorityReporteAdd);
                      break;
                    case 'tipo_reporte':
                      context.push(AppRouter.adminTipoReporteAdd);
                      break;
                  }
                });
              },
            ),
            SizedBox(height: AppSize.defaultPadding),
            //inventario de movimientos
            CustomListTile(
              trailingIcon: const Icon(Icons.arrow_forward_ios),
              leadingIcon: const Icon(Icons.report),
              title: 'Reportes',
              onTap: () {
                context.push(AppRouter.adminReport);
              },
            ),
            SizedBox(height: AppSize.defaultPadding),
            CustomListTile(
              trailingIcon: const Icon(Icons.arrow_forward_ios),
              leadingIcon: const Icon(Icons.person),
              title: 'Roles de Usuario',
              onTap: () {
                context.push(AppRouter.adminRoles);
              },
            ),
          ],
        ),
      ),
    );
  }
}
