import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/core/use_cases/usecase.dart';
import '../entities/token.dart';
import '../repositories/marketplace_repository.dart';

class GetAllListings implements UseCase<List<Token>, NoParams> {
  final MarketplaceRepository repository;

  GetAllListings(this.repository);

  @override
  Future<Either<Failure, List<Token>>> call(NoParams params) async {
    return await repository.getAllListings();
  }
}