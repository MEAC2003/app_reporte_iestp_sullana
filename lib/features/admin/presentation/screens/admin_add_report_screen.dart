import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/services/cloudinary_service.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddReportScreen extends StatelessWidget {
  const AddReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.defaultPaddingHorizontal * 1.5.w,
          ),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Crear Reporte',
          style: AppStyles.h2(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const _AdminReportView(),
    );
  }
}

class _AdminReportView extends StatefulWidget {
  const _AdminReportView();

  @override
  State<_AdminReportView> createState() => _AdminReportViewState();
}

class _AdminReportViewState extends State<_AdminReportView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreUsuarioController =
      TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  String? _selectedArea;
  String? _selectedTipoReporte;
  String? _selectedPrioridad;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminActionProvider>().loadInitialData();
      _setLoggedUserName();
    });
  }

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _setLoggedUserName() {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      _nombreUsuarioController.text = user.nombre;
    }
  }

  Future<void> _pickImage() async {
    final url = await _cloudinaryService.uploadImage();
    if (url != null) {
      setState(() {
        _imageUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminActionProvider>();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFields(
                label: 'Nombre del Usuario',
                controller: _nombreUsuarioController,
                keyboardType: TextInputType.text,
                enabled: false,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Por favor ingrese el nombre del usuario'
                    : null,
              ),
              SizedBox(height: AppSize.defaultPadding),
              Text(
                'Área',
                style: AppStyles.h4(
                  color: AppColors.primarySkyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedArea,
                hint: Text(
                  'Selecciona un área',
                  style: AppStyles.h5(
                    color: AppColors.darkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                items: provider.areas.map((category) {
                  return DropdownMenuItem(
                    value: category.id.toString(),
                    child: Text(
                      category.nombre,
                      style: AppStyles.h5(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedArea = value),
                validator: (value) =>
                    value == null ? 'Seleccione un área' : null,
              ),
              SizedBox(height: AppSize.defaultPadding * 2),
              // Type Garment Dropdown
              Text(
                'Tipo de Reporte',
                style: AppStyles.h4(
                  color: AppColors.primarySkyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedTipoReporte,
                hint: Text(
                  'Selecciona un tipo de reporte',
                  style: AppStyles.h5(
                    color: AppColors.darkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                items: provider.tiposReporte.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo.id.toString(),
                    child: Text(
                      tipo.nombre,
                      style: AppStyles.h5(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedTipoReporte = value),
                validator: (value) =>
                    value == null ? 'Seleccione un tipo de reporte' : null,
              ),
              SizedBox(height: AppSize.defaultPadding * 2),
              // Prioridad Dropdown
              Text(
                'Prioridad',
                style: AppStyles.h4(
                  color: AppColors.primarySkyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedPrioridad,
                hint: Text(
                  'Selecciona una prioridad',
                  style: AppStyles.h5(
                    color: AppColors.darkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                items: provider.prioridades.map((prioridad) {
                  return DropdownMenuItem(
                    value: prioridad.id.toString(),
                    child: Text(
                      prioridad.nombre,
                      style: AppStyles.h5(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedPrioridad = value),
                validator: (value) =>
                    value == null ? 'Seleccione una prioridad' : null,
              ),
              SizedBox(height: AppSize.defaultPadding * 2),
              // Description field
              CustomTextFields(
                label: 'Descripción',
                controller: _descripcionController,
                keyboardType: TextInputType.multiline,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Por favor ingrese una descripción'
                    : null,
              ),
              SizedBox(height: AppSize.defaultPadding * 2),
              // Image picker
              Text(
                'Imagen',
                style: AppStyles.h4(
                  color: AppColors.primarySkyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageUrl != null
                      ? Image.network(_imageUrl!, fit: BoxFit.cover)
                      : Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: AppColors.darkColor50,
                        ),
                ),
              ),

              SizedBox(height: AppSize.defaultPadding * 2),

              CustomActionButton(
                text: 'Guardar Reporte',
                onPressed: _saveReport,
                color: AppColors.primarySkyBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione una imagen')),
      );
      return;
    }

    try {
      final userId = context.read<UserProvider>().user?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no identificado')),
        );
        return;
      }

      // Llamar  al método createReporteWithParams
      final reporteId = await context
          .read<AdminActionProvider>()
          .createReporteWithParams(
            descripcion: _descripcionController.text,
            imageUrl: _imageUrl!,
            areaId: _selectedArea!,
            tipoReporteId: _selectedTipoReporte!,
            prioridadId: _selectedPrioridad!,
            userId: userId,
          );

      if (reporteId != null) {
        // Recargar datos después de crear el reporte
        await context.read<AdminActionProvider>().loadInitialData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte creado exitosamente')),
        );

        // Cerrar la pantalla
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el reporte')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear el reporte: $e')));
    }
  }
}
