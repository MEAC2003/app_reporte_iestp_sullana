import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class AdminUpdatePrioridadScreen extends StatelessWidget {
  final String prioridadId;
  const AdminUpdatePrioridadScreen({super.key, required this.prioridadId});

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
          'Editar Prioridad',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _UpdatePrioridadView(prioridadId: prioridadId),
    );
  }
}

class _UpdatePrioridadView extends StatefulWidget {
  final String prioridadId;
  const _UpdatePrioridadView({required this.prioridadId});

  @override
  State<_UpdatePrioridadView> createState() => _UpdatePrioridadViewState();
}

class _UpdatePrioridadViewState extends State<_UpdatePrioridadView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrioridadData();
  }

  void _loadPrioridadData() {
    final provider = Provider.of<AdminActionProvider>(context, listen: false);
    final prioridad = provider.prioridades.firstWhere(
      (p) => p.id == widget.prioridadId,
    );

    _nameController.text = prioridad.nombre;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updatePrioridad() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await context.read<AdminActionProvider>().updatePrioridad(
        id: widget.prioridadId,
        name: _nameController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prioridad actualizada exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la prioridad: $e')),
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
                text: 'Actualizar Prioridad',
                onPressed: _updatePrioridad,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
