import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/features/auth/domain/entities/marketplace_response.dart';
import 'package:the_boost/features/auth/domain/repositories/marketplace_repository.dart';

class CancelListingUseCase {
  final MarketplaceRepository repository;

  CancelListingUseCase(this.repository);

  Future<Either<Failure, MarketplaceResponse>> call(int tokenId) {
    return repository.cancelListing(tokenId);
  }
}