import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/core/use_cases/usecase.dart';
import '../repositories/marketplace_repository.dart';

class PurchaseToken implements UseCase<bool, PurchaseTokenParams> {
  final MarketplaceRepository repository;

  PurchaseToken(this.repository);

  @override
  Future<Either<Failure, bool>> call(PurchaseTokenParams params) async {
    return await repository.purchaseToken(params.tokenId, params.buyerAddress);
  }
}

class PurchaseTokenParams extends Equatable {
  final int tokenId;
  final String buyerAddress;

  const PurchaseTokenParams({
    required this.tokenId,
    required this.buyerAddress,
  });

  @override
  List<Object?> get props => [tokenId, buyerAddress];
}