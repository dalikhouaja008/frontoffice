import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileCard extends StatelessWidget {
  final PlatformFile file;
  final bool isImage;
  final VoidCallback onRemove;

  const FileCard({
    Key? key,
    required this.file,
    required this.isImage,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    file.bytes!,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insert_drive_file, color: Colors.blue[700], size: 40),
                    SizedBox(height: 8),
                    Text(
                      file.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                  ],
                ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 20, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ),
      ],
    );
  }
}