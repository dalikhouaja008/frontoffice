// lib/features/investment/domain/repositories/investment_repository.dart
import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import '../entities/enhanced_tokens_response.dart';

abstract class InvestmentRepository {
  Future<Either<Failure, EnhancedTokensResponse>> getEnhancedTokens();
}