import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/use_cases/usecase.dart';
import '../entities/token.dart';
import '../repositories/marketplace_repository.dart';

class GetFilteredListings implements UseCase<List<Token>, FilteredListingsParams> {
  final MarketplaceRepository repository;

  GetFilteredListings(this.repository);

  @override
  Future<Either<Failure, List<Token>>> call(FilteredListingsParams params) async {
    return await repository.getFilteredListings(
      query: params.query,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      category: params.category,
      sortBy: params.sortBy,
    );
  }
}

class FilteredListingsParams extends Equatable {
  final String? query;
  final double? minPrice;
  final double? maxPrice;
  final String? category;
  final String? sortBy;

  const FilteredListingsParams({
    this.query,
    this.minPrice,
    this.maxPrice,
    this.category,
    this.sortBy,
  });

  @override
  List<Object?> get props => [query, minPrice, maxPrice, category, sortBy];
}