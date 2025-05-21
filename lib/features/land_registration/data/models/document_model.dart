// lib/features/land_registration/data/models/document_model.dart
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/document.dart';

class LandDocumentModel extends LandDocument {
  const LandDocumentModel({
    required String name,
    required int size,
    List<int>? bytes,
    String? path,
    required String contentType,
  }) : super(
          name: name,
          size: size,
          bytes: bytes,
          path: path,
          contentType: contentType,
        );

  factory LandDocumentModel.fromJson(Map<String, dynamic> json) {
    return LandDocumentModel(
      name: json['name'],
      size: json['size'],
      path: json['path'],
      contentType: json['contentType'],
      bytes: null,
    );
  }

  factory LandDocumentModel.fromPlatformFile(PlatformFile file) {
    return LandDocumentModel(
      name: file.name,
      size: file.size,
      // Never use path directly - it's not available on web
      path: null,
      // Always use bytes instead for web compatibility
      bytes: file.bytes,
      contentType: _getContentType(file.name),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size,
      'path': path,
      'contentType': contentType,
    };
  }

  static String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}