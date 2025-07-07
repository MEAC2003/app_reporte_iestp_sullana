import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/features/user/presentation/providers/user_action_provider.dart';
import 'package:app_reporte_iestp_sullana/services/cloudinary_service.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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
      body: const _UserReportView(),
    );
  }
}

class _UserReportView extends StatefulWidget {
  const _UserReportView();

  @override
  State<_UserReportView> createState() => _UserReportViewState();
}

class _UserReportViewState extends State<_UserReportView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreUsuarioController =
      TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  String? _selectedArea;
  String? _selectedTipoReporte;
  String? _selectedPrioridad;
  String? _imageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserActionProvider>().loadInitialData();
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

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(AppSize.defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar imagen',
                  style: AppStyles.h3(
                    color: AppColors.darkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSize.defaultPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón para Cámara
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                      child: Container(
                        padding: EdgeInsets.all(AppSize.defaultPadding),
                        decoration: BoxDecoration(
                          color: AppColors.primarySkyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primarySkyBlue,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: AppColors.primarySkyBlue,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Cámara',
                              style: AppStyles.h4(
                                color: AppColors.primarySkyBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón para Galería
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                      child: Container(
                        padding: EdgeInsets.all(AppSize.defaultPadding),
                        decoration: BoxDecoration(
                          color: AppColors.primarySkyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primarySkyBlue,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 40,
                              color: AppColors.primarySkyBlue,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Galería',
                              style: AppStyles.h4(
                                color: AppColors.primarySkyBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.defaultPadding),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: AppStyles.h4(color: AppColors.darkColor50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final url = await _cloudinaryService.uploadImageFromFile(image.path);
        if (url != null) {
          setState(() {
            _imageUrl = url;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen capturada exitosamente')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al capturar imagen: $e')));
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final url = await _cloudinaryService.uploadImageFromFile(image.path);
        if (url != null) {
          setState(() {
            _imageUrl = url;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen seleccionada exitosamente')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserActionProvider>();

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
                'Área(salón/lab)',
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
              CustomTextFields(
                label: 'Descripción',
                controller: _descripcionController,
                keyboardType: TextInputType.multiline,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Por favor ingrese una descripción'
                    : null,
              ),
              SizedBox(height: AppSize.defaultPadding * 2),
              Text(
                'Imagen',
                style: AppStyles.h4(
                  color: AppColors.primarySkyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.defaultPadding),
              GestureDetector(
                onTap: _isUploadingImage ? null : _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isUploadingImage
                          ? Colors.grey
                          : AppColors.primarySkyBlue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isUploadingImage
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('Subiendo imagen...'),
                            ],
                          ),
                        )
                      : _imageUrl != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _imageUrl = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: AppColors.primarySkyBlue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca para agregar imagen',
                              style: AppStyles.h5(
                                color: AppColors.primarySkyBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cámara o Galería',
                              style: AppStyles.h5(color: AppColors.darkColor50),
                            ),
                          ],
                        ),
                ),
              ),

              SizedBox(height: AppSize.defaultPadding * 2),

              CustomActionButton(
                text: 'Guardar Reporte',
                onPressed: () => _saveReport(),
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

      print('INICIANDO CREACIÓN DE REPORTE...');
      print('   Usuario: $userId');
      print('   Descripción: ${_descripcionController.text}');

      final reporteId = await context
          .read<UserActionProvider>()
          .createReporteWithParams(
            descripcion: _descripcionController.text,
            imageUrl: _imageUrl!,
            areaId: _selectedArea!,
            tipoReporteId: _selectedTipoReporte!,
            prioridadId: _selectedPrioridad!,
            userId: userId,
          );

      if (reporteId != null) {
        print('REPORTE CREADO CON ID: $reporteId');

        await context.read<UserActionProvider>().loadInitialData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte creado exitosamente')),
        );

        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el reporte')),
        );
      }
    } catch (e) {
      print('ERROR AL CREAR REPORTE: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear el reporte: $e')));
    }
  }
}
