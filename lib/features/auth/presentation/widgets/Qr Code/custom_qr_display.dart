import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class CustomQrDisplay extends StatelessWidget {
  final String qrData;
  final double size;
  final VoidCallback? onRefresh;
  final String? title;
  final String? subtitle;

  const CustomQrDisplay({
    super.key,
    required this.qrData,
    this.size = 200,
    this.onRefresh,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    print('CustomQrDisplay📱 Building CustomQrDisplay'
          '\n└─ QR data length: ${qrData.length}');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
        ],
        if (subtitle != null) ...[
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: qrData.startsWith('data:image')
              ? Image.memory(
                  base64Decode(qrData.split(',')[1]),
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                )
              : QrImageView(
                  data: qrData,
                  size: size,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
        ),
        if (onRefresh != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              print('CustomQrDisplay:🔄 QR refresh requested');
              onRefresh!();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Rafraîchir le QR code'),
          ),
        ],
      ],
    );
  }
}