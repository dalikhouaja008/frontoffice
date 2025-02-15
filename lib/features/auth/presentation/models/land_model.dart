import 'package:flutter/material.dart';

enum LandType { AGRICULTURAL, URBAN }
enum LandStatus { PENDING, APPROVED, REJECTED }

class Land {
  final String id;
  final String title;
  final String description;
  final String location;
  final LandType type;
  final LandStatus status;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;

  Land({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.status,
    required this.price,
    this.imageUrl,
    required this.createdAt,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      type: LandType.values.firstWhere(
        (e) => e.toString() == 'LandType.${json['type']}',
      ),
      status: LandStatus.values.firstWhere(
        (e) => e.toString() == 'LandStatus.${json['status']}',
      ),
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}