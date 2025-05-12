import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/token.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_datasource.dart';
import '../datasources/marketplace_local_datasource.dart';

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
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ✓ Fetching listings from remote');
        final remoteListings = await remoteDataSource.getAllListings();
        await localDataSource.cacheTokenListings(remoteListings);
        return Right(remoteListings);
      } on ServerException catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Server error getting listings: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Unexpected error getting listings: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ⚠️ No network, fetching listings from cache');
        final localListings = await localDataSource.getLastTokenListings();
        return Right(localListings);
      } on CacheException {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Cache error getting listings');
        return const Left(CacheFailure(message: 'No cached data available'));
      } catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Unexpected error getting cached listings: $e');
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Token>>> getFilteredListings({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? sortBy,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ✓ Fetching filtered listings from remote');
        final filteredListings = await remoteDataSource.getFilteredListings(
          query: query,
          minPrice: minPrice,
          maxPrice: maxPrice,
          category: category,
          sortBy: sortBy,
        );
        return Right(filteredListings);
      } on ServerException catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Server error getting filtered listings: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Unexpected error getting filtered listings: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // For filtered queries, we can try to filter the cached listings if available
      try {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ⚠️ No network, filtering cached listings');
        final allCachedListings = await localDataSource.getLastTokenListings();
        final filteredCachedListings = _filterLocalListings(
          allCachedListings,
          query: query,
          minPrice: minPrice,
          maxPrice: maxPrice,
          category: category,
          sortBy: sortBy,
        );
        return Right(filteredCachedListings);
      } on CacheException {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Cache error getting filtered listings');
        return Left(CacheFailure(message: 'No cached data available'));
      } catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Unexpected error filtering cached listings: $e');
        return Left(NetworkFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Token>> getListingDetails(int tokenId) async {
    if (await networkInfo.isConnected) {
      try {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ✓ Fetching token details from remote: $tokenId');
        final tokenDetails = await remoteDataSource.getListingDetails(tokenId);
        await localDataSource.cacheTokenDetails(tokenDetails);
        return Right(tokenDetails);
      } on ServerException catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Server error getting token details: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Unexpected error getting token details: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ⚠️ No network, fetching token details from cache: $tokenId');
        final cachedToken = await localDataSource.getTokenDetails(tokenId);
        return Right(cachedToken);
      } on CacheException {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Cache error getting token details');
        return Left(CacheFailure(message: 'No cached data available'));
      } catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Unexpected error getting cached token details: $e');
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> purchaseToken(int tokenId, String buyerAddress) async {
    if (await networkInfo.isConnected) {
      try {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ✓ Purchasing token: $tokenId by $buyerAddress');
        final success = await remoteDataSource.purchaseToken(tokenId, buyerAddress);
        if (success) {
          // Invalidate cache for this token since it's been purchased
          await localDataSource.removeTokenDetails(tokenId);
          await localDataSource.invalidateListingsCache();
          debugPrint('[${DateTime.now()}] MarketplaceRepository: ✓ Purchase successful, cache invalidated');
        }
        return Right(success);
      } on ServerException catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Server error purchasing token: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Unexpected error purchasing token: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      debugPrint('[${DateTime.now()}] MarketplaceRepository: ❌ Cannot purchase token while offline');
      return Left(NetworkFailure(message: 'Cannot purchase token while offline'));
    }
  }
  
  // Helper method to filter local listings
  List<Token> _filterLocalListings(
    List<Token> listings, {
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? sortBy,
  }) {
    var filtered = List<Token>.from(listings);
    
    // Apply filters
    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((token) => 
        token.land.location.toLowerCase().contains(query.toLowerCase()) ||
        token.tokenId.toString() == query ||
        token.tokenNumber.toString() == query
      ).toList();
    }
    
    if (minPrice != null) {
      filtered = filtered.where((token) {
        final price = double.tryParse(token.price.replaceAll(' ETH', '')) ?? 0;
        return price >= minPrice;
      }).toList();
    }
    
    if (maxPrice != null) {
      filtered = filtered.where((token) {
        final price = double.tryParse(token.price.replaceAll(' ETH', '')) ?? 0;
        return price <= maxPrice;
      }).toList();
    }
    
    if (category != null && category != 'All Categories' && category.isNotEmpty) {
      filtered = filtered.where((token) => 
        token.land.status.toLowerCase() == category.toLowerCase()
      ).toList();
    }
    
    // Apply sorting
    if (sortBy != null) {
      if (sortBy.contains('Low to High')) {
        filtered.sort((a, b) {
          final priceA = double.tryParse(a.price.replaceAll(' ETH', '')) ?? 0;
          final priceB = double.tryParse(b.price.replaceAll(' ETH', '')) ?? 0;
          return priceA.compareTo(priceB);
        });
      } else if (sortBy.contains('High to Low')) {
        filtered.sort((a, b) {
          final priceA = double.tryParse(a.price.replaceAll(' ETH', '')) ?? 0;
          final priceB = double.tryParse(b.price.replaceAll(' ETH', '')) ?? 0;
          return priceB.compareTo(priceA);
        });
      } else if (sortBy.contains('Newest')) {
        filtered.sort((a, b) => b.listingTimestamp.compareTo(a.listingTimestamp));
      } else if (sortBy.contains('ROI')) {
        filtered.sort((a, b) => 
          b.priceChangePercentage.percentage.compareTo(a.priceChangePercentage.percentage)
        );
      } else if (sortBy.contains('Surface')) {
        filtered.sort((a, b) => b.land.surface.compareTo(a.land.surface));
      }
    }
    
    return filtered;
  }
}