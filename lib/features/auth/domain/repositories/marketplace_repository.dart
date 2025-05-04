import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import '../entities/marketplace_response.dart';

abstract class MarketplaceRepository {
  Future<Either<Failure, ListingResponse>> listToken(int tokenId, String price);
  Future<Either<Failure, MultipleListingResponse>> listMultipleTokens(
      List<int> tokenIds, List<String> prices);
  Future<Either<Failure, MarketplaceResponse>> cancelListing(int tokenId);
}