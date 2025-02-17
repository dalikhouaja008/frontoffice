import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/land_bloc.dart';
import '../bloc/land_event.dart';
import '../bloc/land_state.dart';

class AddLandPage extends StatefulWidget {
  @override
  _AddLandPageState createState() => _AddLandPageState();
}

class _AddLandPageState extends State<AddLandPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _sizeController = TextEditingController();
  List<Uint8List> _selectedPhotos = [];
  List<Uint8List> _selectedDocuments = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes();
        setState(() => _selectedPhotos.add(bytes));
      }
    }
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result != null) {
      for (var file in result.files) {
        if (file.bytes != null) {
          setState(() => _selectedDocuments.add(file.bytes!));
        }
      }
    }
  }

  List<MultipartFile> _convertToMultipart(List<Uint8List> files, String fieldName) {
    return files.map((file) {
      return MultipartFile.fromBytes(
        file,
        filename: '$fieldName-${DateTime.now().millisecondsSinceEpoch}.bin'
      );
    }).toList();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      
      final photos = _convertToMultipart(_selectedPhotos, 'photo');
      final documents = _convertToMultipart(_selectedDocuments, 'document');

      context.read<LandBloc>().add(AddLandEvent(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        size: int.parse(_sizeController.text.trim()),
        photos: photos,
        documents: documents,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Register New Land',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: Colors.grey[600]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.map_outlined, color: Colors.grey[600]),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocListener<LandBloc, LandState>(
        listener: (context, state) {
          setState(() => _isSubmitting = false);
          if (state is LandAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Land Added Successfully!')),
            );
            Navigator.pop(context);
          } else if (state is LandError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column - Basic Information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Basic Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 24),
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Land Name',
                                  hint: 'Enter land name',
                                ),
                                SizedBox(height: 16),
                                _buildTextField(
                                  controller: _locationController,
                                  label: 'Location',
                                  hint: 'Enter location',
                                  prefixIcon: Icons.location_on_outlined,
                                ),
                                SizedBox(height: 16),
                                _buildTextField(
                                  controller: _sizeController,
                                  label: 'Size (sq meters)',
                                  hint: 'Enter land size',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 32),
                          // Right Column - Documentation
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Documentation',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 24),
                                _buildUploadArea(
                                  icon: Icons.camera_alt_outlined,
                                  title: 'Upload Photos',
                                  subtitle: 'Drag and drop or click to select files',
                                  onTap: _pickImages,
                                ),
                                SizedBox(height: 16),
                                if (_selectedPhotos.isNotEmpty)
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: _selectedPhotos.length,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: MemoryImage(_selectedPhotos[index]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _selectedPhotos.removeAt(index);
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                SizedBox(height: 24),
                                _buildUploadArea(
                                  icon: Icons.upload_file_outlined,
                                  title: 'Upload Documents',
                                  subtitle: 'PDF, DOC, or DOCX files',
                                  onTap: _pickDocuments,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          child: Container(
                            width: 200,
                            height: 45,
                            child: Center(
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_location_alt_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Register Land',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.green.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[400])
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[500]!),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) =>
              value?.isEmpty == true ? '$label is required' : null,
        ),
      ],
    );
  }

  Widget _buildUploadArea({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}