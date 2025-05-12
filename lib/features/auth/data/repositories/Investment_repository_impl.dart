import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/core/network/network_info.dart';
import 'package:the_boost/features/auth/data/datasources/investment_remote_data_source.dart';
import 'package:the_boost/features/auth/domain/entities/enhanced_tokens_response.dart';
import 'package:the_boost/features/auth/domain/repositories/investment_repository.dart';

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
        final remoteTokens = await remoteDataSource.getEnhancedTokens();
        return Right(remoteTokens);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}