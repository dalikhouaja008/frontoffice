import 'package:dartz/dartz.dart';
import 'package:the_boost/features/marketplace/domain/entities/transaction.dart';
import '../../../../core/error/failure.dart';
import '../entities/token.dart';

abstract class MarketplaceRepository {
  /// Gets all token listings from the repository
  Future<Either<Failure, List<Token>>> getAllListings();

  /// Gets filtered token listings based on various criteria
  Future<Either<Failure, List<Token>>> getFilteredListings({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? sortBy,
  });

  /// Gets details for a specific token by ID
  Future<Either<Failure, Token>> getListingDetails(int tokenId);

  /// Purchases a token with the specified ID
  Future<Either<Failure, Transaction>> purchaseToken(int tokenId, String price);
}
