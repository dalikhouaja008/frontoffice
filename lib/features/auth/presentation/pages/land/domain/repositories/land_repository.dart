import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/failures.dart';
import 'package:the_boost/features/auth/presentation/pages/land/domain/entities/land.dart';

abstract class LandRepository {
  Future<Either<Failure, List<Land>>> getMyLands();
}
