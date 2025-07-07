import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class AdminUpdateEstadoReporteScreen extends StatelessWidget {
  final String estadoId;
  const AdminUpdateEstadoReporteScreen({super.key, required this.estadoId});

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
          'Editar Estado',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _UpdateEstadoReporteView(estadoId: estadoId),
    );
  }
}

class _UpdateEstadoReporteView extends StatefulWidget {
  final String estadoId;
  const _UpdateEstadoReporteView({required this.estadoId});

  @override
  State<_UpdateEstadoReporteView> createState() =>
      _UpdateEstadoReporteViewState();
}

class _UpdateEstadoReporteViewState extends State<_UpdateEstadoReporteView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEstadoData();
  }

  void _loadEstadoData() {
    final provider = Provider.of<AdminActionProvider>(context, listen: false);
    final estado = provider.estadosReporte.firstWhere(
      (e) => e.id == widget.estadoId,
    );

    _nameController.text = estado.nombre;
    _descriptionController.text = estado.descripcion;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateEstado() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await context
          .read<AdminActionProvider>()
          .updateEstadoReporte(
            id: widget.estadoId,
            name: _nameController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
          );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el estado: $e')),
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
                label: 'Nombre del Estado',
                controller: _nameController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor ingrese un nombre para el estado';
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
                text: 'Actualizar Estado',
                onPressed: _updateEstado,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
