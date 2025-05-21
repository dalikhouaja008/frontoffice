import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failures.dart';
import 'package:the_boost/core/network/network_info.dart';
import 'package:the_boost/features/land/data/datasources/land_remote_data_source.dart';
import 'package:the_boost/features/land/domain/entities/land.dart';
import 'package:the_boost/features/land/domain/repositories/land_repository.dart';

class LandRepositoryImpl implements LandRepository {
  final LandRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LandRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Land>>> getMyLands() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteLands = await remoteDataSource.getMyLands();
        return Right(remoteLands);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
