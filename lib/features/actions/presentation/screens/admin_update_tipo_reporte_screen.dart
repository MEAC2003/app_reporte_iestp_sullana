import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class AdminUpdateTipoReporteScreen extends StatelessWidget {
  final String tipoId;
  const AdminUpdateTipoReporteScreen({super.key, required this.tipoId});

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
          'Editar Tipo',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _UpdateTipoReporteView(tipoId: tipoId),
    );
  }
}

class _UpdateTipoReporteView extends StatefulWidget {
  final String tipoId;
  const _UpdateTipoReporteView({required this.tipoId});

  @override
  State<_UpdateTipoReporteView> createState() => _UpdateTipoReporteViewState();
}

class _UpdateTipoReporteViewState extends State<_UpdateTipoReporteView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTipoData();
  }

  void _loadTipoData() {
    final provider = Provider.of<AdminActionProvider>(context, listen: false);
    final tipo = provider.tiposReporte.firstWhere((t) => t.id == widget.tipoId);

    _nameController.text = tipo.nombre;
    _descriptionController.text = tipo.descripcion;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateTipo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await context
          .read<AdminActionProvider>()
          .updateTipoReporte(
            id: widget.tipoId,
            name: _nameController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
          );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo actualizado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el tipo: $e')),
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
                label: 'Nombre del Tipo',
                controller: _nameController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor ingrese un nombre para el tipo';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSize.defaultPadding),
              CustomTextFields(
                label: 'Descripción (Opcional)',
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: AppSize.defaultPadding * 2),
              CustomActionButton(
                text: 'Actualizar Tipo',
                onPressed: _updateTipo,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
