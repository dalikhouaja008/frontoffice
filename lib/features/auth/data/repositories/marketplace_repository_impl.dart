import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/core/network/network_info.dart';
import 'package:the_boost/features/auth/data/datasources/marketplace_remote_data_source.dart';
import 'package:the_boost/features/auth/data/models/marketplace_response_model.dart';
import 'package:the_boost/features/auth/domain/entities/marketplace_response.dart';
import 'package:the_boost/features/auth/domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MarketplaceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ListingResponse>> listToken(
      int tokenId, String price) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.listToken(tokenId, price);
        return Right(ListingResponseModel.fromJson(response));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, MultipleListingResponse>> listMultipleTokens(
      List<int> tokenIds, List<String> prices) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.listMultipleTokens(tokenIds, prices);
        return Right(MultipleListingResponseModel.fromJson(response));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, MarketplaceResponse>> cancelListing(int tokenId) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.cancelListing(tokenId);
        return Right(MarketplaceResponseModel.fromJson(response));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}