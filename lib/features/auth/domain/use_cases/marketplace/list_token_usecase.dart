import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/features/auth/domain/entities/marketplace_response.dart';
import 'package:the_boost/features/auth/domain/repositories/marketplace_repository.dart';


class ListTokenUseCase {
  final MarketplaceRepository repository;

  ListTokenUseCase(this.repository);

  Future<Either<Failure, ListingResponse>> call(int tokenId, String price) {
    return repository.listToken(tokenId, price);
  }
}