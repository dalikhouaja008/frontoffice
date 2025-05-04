import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/core/network/network_info.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/enhanced_tokens_response.dart';
import '../../domain/repositories/investment_repository.dart';
import '../datasources/investment_remote_data_source.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  final InvestmentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  InvestmentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, EnhancedTokensResponse>> getEnhancedTokens() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getEnhancedTokens();
        return Right(remoteData);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}