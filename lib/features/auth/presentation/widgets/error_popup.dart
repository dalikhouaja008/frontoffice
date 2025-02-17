import 'package:flutter/material.dart';

class ErrorPopup extends StatelessWidget {
  final String message;

  const ErrorPopup({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 🔹 Smaller rounded dialog
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Keeps the pop-up small
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 50), // ⚠️ Warning Icon
            const SizedBox(height: 10),
            const Text(
              "Oops! Something went wrong",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Invalid email or password. Please try again.",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // 🔹 Red button color
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
