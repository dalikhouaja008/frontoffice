import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/core/use_cases/usecase.dart';
import 'package:the_boost/features/marketplace/domain/entities/transaction.dart';
import '../repositories/marketplace_repository.dart';

class PurchaseToken implements UseCase<Transaction, PurchaseTokenParams> {
  final MarketplaceRepository repository;

  PurchaseToken(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(PurchaseTokenParams params) async {
    return await repository.purchaseToken(params.tokenId, params.price);
  }
}

class PurchaseTokenParams extends Equatable {
  final int tokenId;
  final String price;

  const PurchaseTokenParams({
    required this.tokenId, 
    required this.price,
  });

  @override
  List<Object?> get props => [tokenId, price];
}