import 'package:dartz/dartz.dart';
import '../../entities/investment_group.dart';
import '../../repositories/investment_group_repository.dart';
import '../../../core/error/failures.dart';

class ManageInvestmentGroupUseCase {
  final InvestmentGroupRepository repository;

  ManageInvestmentGroupUseCase(this.repository);

  Future<Either<Failure, InvestmentGroup>> createGroup(InvestmentGroup group) async {
    return await repository.createInvestmentGroup(group);
  }

  Future<Either<Failure, InvestmentGroup>> updateGroup(InvestmentGroup group) async {
    return await repository.updateInvestmentGroup(group);
  }

  Future<Either<Failure, void>> deleteGroup(String groupId) async {
    return await repository.deleteInvestmentGroup(groupId);
  }

  Future<Either<Failure, void>> addMember(String groupId, String userId) async {
    return await repository.addMemberToGroup(groupId, userId);
  }

  Future<Either<Failure, void>> removeMember(String groupId, String userId) async {
    return await repository.removeMemberFromGroup(groupId, userId);
  }

  Future<Either<Failure, void>> addContribution(String groupId, String userId, double amount) async {
    return await repository.addContribution(groupId, userId, amount);
  }

  Future<Either<Failure, Investment>> proposeInvestment(String groupId, Investment investment) async {
    return await repository.proposeInvestment(groupId, investment);
  }

  Future<Either<Failure, void>> approveInvestment(String groupId, String investmentId) async {
    return await repository.approveInvestment(groupId, investmentId);
  }

  Future<Either<Failure, void>> rejectInvestment(String groupId, String investmentId) async {
    return await repository.rejectInvestment(groupId, investmentId);
  }

  Future<Either<Failure, InvestmentGroup>> updateGroupValue(String groupId, double newValue) async {
    return await repository.updateGroupValue(groupId, newValue);
  }

  Future<Either<Failure, void>> updateMonthlyReturns(String groupId, double monthlyReturns) async {
    return await repository.updateMonthlyReturns(groupId, monthlyReturns);
  }
}