import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/colors.dart';
import 'file_card.dart';

class DocumentationStep extends StatelessWidget {
  final List<PlatformFile> documents;
  final List<PlatformFile> images;
  final Function(List<PlatformFile>) onDocumentsUploaded;
  final Function(PlatformFile, bool) onRemoveDocument;
  final Function() onPickDocuments;

  const DocumentationStep({
    Key? key,
    required this.documents,
    required this.images,
    required this.onDocumentsUploaded,
    required this.onRemoveDocument,
    required this.onPickDocuments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Land Documentation',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Upload documents to verify your land ownership',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // Document upload section
        Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images section
              Text(
                'Images (${images.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 8),
              images.isEmpty
                  ? Text('No images uploaded',
                      style: TextStyle(color: Colors.grey[600]))
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: images
                          .map((image) => FileCard(
                                file: image,
                                isImage: true,
                                onRemove: () => onRemoveDocument(image, true),
                              ))
                          .toList(),
                    ),
              SizedBox(height: 24),

              // Documents section
              Text(
                'Documents (${documents.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              SizedBox(height: 8),
              documents.isEmpty
                  ? Text('No documents uploaded',
                      style: TextStyle(color: Colors.grey[600]))
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: documents
                          .map((doc) => FileCard(
                                file: doc,
                                isImage: false,
                                onRemove: () => onRemoveDocument(doc, false),
                              ))
                          .toList(),
                    ),

              // Upload button
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: Text('Upload Files'),
                onPressed: onPickDocuments,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Required documents info
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                  SizedBox(width: 12),
                  Text(
                    'Required Documents',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildRequiredDocItem('Proof of ownership (title deed)'),
              _buildRequiredDocItem('Land survey document'),
              _buildRequiredDocItem('Property tax receipts (if applicable)'),
              _buildRequiredDocItem('Government ID of the owner'),
              SizedBox(height: 16),
              Text(
                '* These documents will be reviewed by validators for land verification',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredDocItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Colors.orange[700],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}