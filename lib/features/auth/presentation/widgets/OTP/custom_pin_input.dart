import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CustomPinInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;
  final int length;
  final String? title;
  final String? subtitle;
  final bool obscureText;
  final bool showRefreshButton;
  final VoidCallback? onRefresh;

  const CustomPinInput({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.length = 6,
    this.title,
    this.subtitle,
    this.obscureText = true,
    this.showRefreshButton = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    print('CustomPinInput:🔐 Building CustomPinInput'
          '\n└─ Length: $length'
          '\n└─ Obscured: $obscureText');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
        PinCodeTextField(
          appContext: context,
          length: length,
          controller: controller,
          obscureText: obscureText,
          animationType: AnimationType.fade,
          keyboardType: TextInputType.number,
          autoFocus: true,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Colors.white,
            activeColor: Colors.blue,
            selectedColor: Colors.blue,
            inactiveColor: Colors.grey.shade300,
          ),
          onCompleted: (code) {
            print(' CustomPinInput:🔑 Pin completed'
                  '\n└─ Length: ${code.length}');
            onCompleted(code);
          },
          onChanged: (value) {
            if (value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
              controller.text = value.replaceAll(RegExp(r'[^0-9]'), '');
            }
          },
        ),
        if (showRefreshButton && onRefresh != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              print('CustomPinInput:🔄 Pin refresh requested');
              controller.clear();
              onRefresh!();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ],
    );
  }
}