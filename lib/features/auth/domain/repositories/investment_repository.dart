import '../entities/investment.dart';

abstract class InvestmentRepository {
  Future<List<Investment>> getUserInvestments(String userId);
  Future<Investment> makeInvestment(String userId, String propertyId, int tokens);
  Future<bool> sellInvestment(String investmentId, int tokens);
}