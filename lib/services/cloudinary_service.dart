import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dbq7rxivj',
    'ReportesIncidenciasIESTP',
    cache: false,
  );
  final CloudinaryPublic cloudinaryPdf = CloudinaryPublic(
    'dbq7rxivj',
    'ReportesIncidenciasPDFIESTP',
    cache: false,
  );
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path, folder: 'Reportes de incidencia'),
        );
        return response.secureUrl;
      } catch (e) {
        print(e);
        return null;
      }
    }
    return null;
  }

  // MÉTODO AGREGADO
  Future<String?> uploadImageFromFile(String imagePath) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imagePath, folder: 'Reportes de incidencia'),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> uploadPDF(File pdfFile) async {
    try {
      CloudinaryResponse response = await cloudinaryPdf.uploadFile(
        CloudinaryFile.fromFile(
          pdfFile.path,
          folder: 'Requerimientos PDF',
          resourceType: CloudinaryResourceType.Raw,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error uploading PDF: $e');
      return null;
    }
  }
}
