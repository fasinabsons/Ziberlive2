import 'package:dartz/dartz.dart';
import '../../entities/investment_group.dart';
import '../../repositories/investment_group_repository.dart';
import '../../../core/error/failures.dart';

class GetInvestmentGroupsUseCase {
  final InvestmentGroupRepository repository;

  GetInvestmentGroupsUseCase(this.repository);

  Future<Either<Failure, List<InvestmentGroup>>> call() async {
    return await repository.getInvestmentGroups();
  }

  Future<Either<Failure, InvestmentGroup>> getById(String groupId) async {
    return await repository.getInvestmentGroupById(groupId);
  }

  Future<Either<Failure, List<InvestmentGroup>>> getByApartment(String apartmentId) async {
    return await repository.getInvestmentGroupsByApartment(apartmentId);
  }

  Future<Either<Failure, List<InvestmentGroup>>> getByUser(String userId) async {
    return await repository.getInvestmentGroupsByUser(userId);
  }
}