import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class AdminAddPrioridadScreen extends StatelessWidget {
  const AdminAddPrioridadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.defaultPaddingHorizontal * 1.5,
          ),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Agregar Prioridad',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const _AddPrioridadView(),
    );
  }
}

class _AddPrioridadView extends StatefulWidget {
  const _AddPrioridadView();

  @override
  State<_AddPrioridadView> createState() => _AddPrioridadViewState();
}

class _AddPrioridadViewState extends State<_AddPrioridadView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _savePrioridad() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await context.read<AdminActionProvider>().createPrioridad(
        name: _nameController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prioridad creada exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear la prioridad: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.defaultPadding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFields(
                label: 'Nombre de la Prioridad',
                controller: _nameController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor ingrese un nombre para la prioridad';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSize.defaultPadding * 2),
              CustomActionButton(
                text: 'Guardar Prioridad',
                onPressed: _savePrioridad,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
