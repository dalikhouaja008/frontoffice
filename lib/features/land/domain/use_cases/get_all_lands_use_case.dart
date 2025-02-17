import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/land.dart';
import '../repositories/land_repository.dart';

class GetAllLandsUseCase {
  final LandRepository repository;

  GetAllLandsUseCase(this.repository);

  Future<Either<Failure, List<Land>>> call() async {
    return await repository.getAllLands();
  }
}
