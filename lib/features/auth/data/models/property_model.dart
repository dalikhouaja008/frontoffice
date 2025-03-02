import '../../domain/entities/property.dart';

class PropertyModel extends Property {
  PropertyModel({
    required super.id,
    required super.title,
    required super.location,
    required super.category,
    required super.minInvestment,
    required super.tokenPrice,
    required super.totalValue,
    required super.projectedReturn,
    required super.riskLevel,
    required super.availableTokens,
    required super.fundingPercentage,
    required super.imageUrl,
    super.isFeatured,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      category: json['category'],
      minInvestment: json['minInvestment'].toDouble(),
      tokenPrice: json['tokenPrice'].toDouble(),
      totalValue: json['totalValue'].toDouble(),
      projectedReturn: json['projectedReturn'].toDouble(),
      riskLevel: json['riskLevel'],
      availableTokens: json['availableTokens'],
      fundingPercentage: json['fundingPercentage'].toDouble(),
      imageUrl: json['image'] ?? 'assets/placeholder.jpg',
      isFeatured: json['featured'] ?? false,
    );
  }

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