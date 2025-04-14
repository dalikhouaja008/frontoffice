// lib/features/auth/presentation/pages/dashboard/user_land_stats.dart
import 'package:the_boost/features/auth/data/models/land_model.dart';

class UserLandStats {
  final double totalInvestment;
  final double totalArea;
  final double validationProgress;
  final Map<LandType, int> landsByType;
  final Map<LandValidationStatus, int> landsByStatus;
  final Map<String, int> amenitiesCount;
  final double potentialRevenue; // Nouveau

  UserLandStats({
    required this.totalInvestment,
    required this.totalArea,
    required this.validationProgress,
    required this.landsByType,
    required this.landsByStatus,
    required this.amenitiesCount,
    required this.potentialRevenue,
  });

  factory UserLandStats.fromLands(List<Land> lands) {
    double totalInvestment = 0;
    double totalArea = 0;
    double validationProgress = 0;
    double potentialRevenue = 0;
    final landsByType = {
      LandType.AGRICULTURAL: 0,
      LandType.RESIDENTIAL: 0,
      LandType.COMMERCIAL: 0,
      LandType.INDUSTRIAL: 0,
    };
    final landsByStatus = {
      LandValidationStatus.VALIDATED: 0,
      LandValidationStatus.PENDING_VALIDATION: 0,
      LandValidationStatus.PARTIALLY_VALIDATED: 0,
      LandValidationStatus.REJECTED: 0,
    };
    final amenitiesCount = {
      'electricity': 0,
      'water': 0,
      'roadAccess': 0,
    };

    for (var land in lands) {
      totalInvestment += land.surface * 100; // Exemple: 100 €/m²
      totalArea += land.surface;

      landsByType[land.landtype] = (landsByType[land.landtype] ?? 0) + 1;
      landsByStatus[land.status] = (landsByStatus[land.status] ?? 0) + 1;

      if (land.amenities['electricity'] == true) amenitiesCount['electricity'] = (amenitiesCount['electricity'] ?? 0) + 1;
      if (land.amenities['water'] == true) amenitiesCount['water'] = (amenitiesCount['water'] ?? 0) + 1;
      if (land.amenities['roadAccess'] == true) amenitiesCount['roadAccess'] = (amenitiesCount['roadAccess'] ?? 0) + 1;

      // Calculer le revenu potentiel (exemple : 10 €/m²/an pour les terrains validés)
      if (land.status == LandValidationStatus.VALIDATED) {
        potentialRevenue += land.surface * 10;
      }
    }

    validationProgress = lands.isNotEmpty
        ? (landsByStatus[LandValidationStatus.VALIDATED]! / lands.length) * 100
        : 0;

    return UserLandStats(
      totalInvestment: totalInvestment,
      totalArea: totalArea,
      validationProgress: validationProgress,
      landsByType: landsByType,
      landsByStatus: landsByStatus,
      amenitiesCount: amenitiesCount,
      potentialRevenue: potentialRevenue,
    );
  }
}