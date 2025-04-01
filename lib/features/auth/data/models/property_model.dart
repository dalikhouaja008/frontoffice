// lib/features/auth/data/models/property_model.dart
import '../../domain/entities/property.dart';

/// PropertyModel extends Property and provides JSON serialization/deserialization
class PropertyModel extends Property {
  PropertyModel({
    required String id,
    required String title,
    required String location,
    required String category,
    required double minInvestment,
    required double tokenPrice,
    required double totalValue,
    required double projectedReturn,
    required String riskLevel,
    required int availableTokens,
    required double fundingPercentage,
    required String imageUrl,
    bool isFeatured = false, // Default value for optional field
  }) : super(
          id: id,
          title: title,
          location: location,
          category: category,
          minInvestment: minInvestment,
          tokenPrice: tokenPrice,
          totalValue: totalValue,
          projectedReturn: projectedReturn,
          riskLevel: riskLevel,
          availableTokens: availableTokens,
          fundingPercentage: fundingPercentage,
          imageUrl: imageUrl,
          isFeatured: isFeatured,
        );

  /// Factory constructor to create a PropertyModel from JSON
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      category: json['category'] as String,
      minInvestment: (json['minInvestment'] as num).toDouble(),
      tokenPrice: (json['tokenPrice'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      projectedReturn: (json['projectedReturn'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
      availableTokens: json['availableTokens'] as int,
      fundingPercentage: (json['fundingPercentage'] as num).toDouble(),
      imageUrl: json['image'] ?? 'assets/placeholder.jpg', // Default placeholder
      isFeatured: json['featured'] ?? false, // Default to false if not provided
    );
  }

  /// Converts a PropertyModel instance to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'category': category,
      'minInvestment': minInvestment,
      'tokenPrice': tokenPrice,
      'totalValue': totalValue,
      'projectedReturn': projectedReturn,
      'riskLevel': riskLevel,
      'availableTokens': availableTokens,
      'fundingPercentage': fundingPercentage,
      'image': imageUrl,
      'featured': isFeatured,
    };
  }
}