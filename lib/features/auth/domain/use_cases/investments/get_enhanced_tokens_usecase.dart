import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/core/use_cases/usecase.dart';
import 'package:the_boost/features/auth/domain/entities/enhanced_tokens_response.dart';
import 'package:the_boost/features/auth/domain/repositories/investment_repository.dart';

class GetEnhancedTokensUseCase implements UseCase<EnhancedTokensResponse, NoParams> {
  final InvestmentRepository repository;

  GetEnhancedTokensUseCase(this.repository);

  @override
  Future<Either<Failure, EnhancedTokensResponse>> call(NoParams params) async {
    return await repository.getEnhancedTokens();
  }
}