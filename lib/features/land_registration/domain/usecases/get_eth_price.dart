import 'package:dartz/dartz.dart';
import 'package:the_boost/features/land_registration/domain/usecases/usecase.dart';
import '../repositories/valuation_repository.dart';
import '../../../../core/error/failures.dart';

class GetEthPrice implements UseCase<Map<String, dynamic>, NoParams> {
  final ValuationRepository repository;

  GetEthPrice(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) {
    return repository.getEthPrice();
  }
}