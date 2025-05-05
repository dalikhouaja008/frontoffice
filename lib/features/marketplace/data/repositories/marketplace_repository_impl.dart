import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/token.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_local_datasource.dart';
import '../datasources/marketplace_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource remoteDataSource;
  final MarketplaceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MarketplaceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Token>>> getAllListings() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteListings = await remoteDataSource.getAllListings();
        localDataSource.cacheListings(remoteListings);
        return Right(remoteListings);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        // Try to get cached data if remote fails
        try {
          final localListings = await localDataSource.getLastListings();
          return Right(localListings);
        } catch (_) {
          return Left(ServerFailure(e.toString()));
        }
      }
    } else {
      try {
        final localListings = await localDataSource.getLastListings();
        return Right(localListings);
      } catch (e) {
        return Left(CacheFailure('No cached data available'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Token>>> getFilteredListings({
    String? query,
    String? category,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final filteredListings = await remoteDataSource.getFilteredListings(
          query: query,
          category: category,
          sortBy: sortBy,
          minPrice: minPrice,
          maxPrice: maxPrice,
        );
        return Right(filteredListings);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Token>> getListingDetails(int tokenId) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await remoteDataSource.getListingDetails(tokenId);
        return Right(token);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> purchaseToken(
      int tokenId, String buyerAddress) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.purchaseToken(tokenId, buyerAddress);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}