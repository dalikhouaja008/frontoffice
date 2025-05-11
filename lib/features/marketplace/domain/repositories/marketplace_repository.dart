import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import '../entities/token.dart';

abstract class MarketplaceRepository {
  Future<Either<Failure, List<Token>>> getAllListings();
  Future<Either<Failure, List<Token>>> getFilteredListings({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? sortBy,
  });
  Future<Either<Failure, Token>> getListingDetails(int tokenId);
  Future<Either<Failure, bool>> purchaseToken(int tokenId, String buyerAddress);
}