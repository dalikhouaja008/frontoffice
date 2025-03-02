import '../../entities/investment.dart';
import '../../repositories/investment_repository.dart';

class MakeInvestmentUseCase {
  final InvestmentRepository repository;

  MakeInvestmentUseCase(this.repository);

  Future<Investment> execute(String userId, String propertyId, int tokens) async {
    return await repository.makeInvestment(userId, propertyId, tokens);
  }
}