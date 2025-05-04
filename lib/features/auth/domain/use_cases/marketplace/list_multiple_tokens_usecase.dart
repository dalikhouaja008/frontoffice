import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/features/auth/domain/entities/marketplace_response.dart';
import 'package:the_boost/features/auth/domain/repositories/marketplace_repository.dart';

class ListMultipleTokensUseCase {
  final MarketplaceRepository repository;

  ListMultipleTokensUseCase(this.repository);

  Future<Either<Failure, MultipleListingResponse>> call(List<int> tokenIds, List<String> prices) {
    return repository.listMultipleTokens(tokenIds, prices);
  }
}