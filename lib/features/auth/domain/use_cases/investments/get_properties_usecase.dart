import '../../entities/property.dart';
import '../../repositories/property_repository.dart';


class GetPropertiesUseCase {
  final PropertyRepository repository;

  GetPropertiesUseCase(this.repository);

  Future<List<Property>> execute({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minReturn,
    double? maxReturn,
    List<String>? riskLevels,
  }) async {
    return await repository.getProperties(
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minReturn: minReturn,
      maxReturn: maxReturn,
      riskLevels: riskLevels,
    );
  }
}