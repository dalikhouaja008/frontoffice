import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/exceptions.dart';
import 'package:the_boost/core/error/failures.dart';
import 'package:the_boost/features/auth/presentation/pages/land/data/datasources/land_remote_data_source.dart';
import 'package:the_boost/features/auth/presentation/pages/land/domain/entities/land.dart';
import 'package:the_boost/features/auth/presentation/pages/land/domain/repositories/land_repository.dart';

class LandRepositoryImpl implements LandRepository {
  final LandRemoteDataSource remoteDataSource;

  LandRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Land>>> getMyLands() async {
    try {
      final lands = await remoteDataSource.getMyLands();
      return Right(lands);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
