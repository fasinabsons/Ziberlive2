import 'package:dartz/dartz.dart';
import '../entities/investment_group.dart';
import '../../core/error/failures.dart';

abstract class InvestmentGroupRepository {
  Future<Either<Failure, List<InvestmentGroup>>> getInvestmentGroups();
  Future<Either<Failure, InvestmentGroup>> getInvestmentGroupById(String groupId);
  Future<Either<Failure, List<InvestmentGroup>>> getInvestmentGroupsByApartment(String apartmentId);
  Future<Either<Failure, List<InvestmentGroup>>> getInvestmentGroupsByUser(String userId);
  
  Future<Either<Failure, InvestmentGroup>> createInvestmentGroup(InvestmentGroup group);
  Future<Either<Failure, InvestmentGroup>> updateInvestmentGroup(InvestmentGroup group);
  Future<Either<Failure, void>> deleteInvestmentGroup(String groupId);
  
  Future<Either<Failure, void>> addMemberToGroup(String groupId, String userId);
  Future<Either<Failure, void>> removeMemberFromGroup(String groupId, String userId);
  
  Future<Either<Failure, void>> addContribution(String groupId, String userId, double amount);
  
  Future<Either<Failure, Investment>> proposeInvestment(String groupId, Investment investment);
  Future<Either<Failure, void>> approveInvestment(String groupId, String investmentId);
  Future<Either<Failure, void>> rejectInvestment(String groupId, String investmentId);
  
  Future<Either<Failure, InvestmentGroup>> updateGroupValue(String groupId, double newValue);
  Future<Either<Failure, void>> updateMonthlyReturns(String groupId, double monthlyReturns);
}