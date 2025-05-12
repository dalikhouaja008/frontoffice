import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/use_cases/usecase.dart';
import '../entities/token.dart';
import '../repositories/marketplace_repository.dart';

class GetListingDetails implements UseCase<Token, ListingDetailsParams> {
  final MarketplaceRepository repository;

  GetListingDetails(this.repository);

  @override
  Future<Either<Failure, Token>> call(ListingDetailsParams params) async {
    return await repository.getListingDetails(params.tokenId);
  }
}

class ListingDetailsParams extends Equatable {
  final int tokenId;

  const ListingDetailsParams({required this.tokenId});

  @override
  List<Object?> get props => [tokenId];
}