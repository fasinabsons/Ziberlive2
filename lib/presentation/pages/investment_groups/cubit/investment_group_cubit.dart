import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/investment_group.dart';
import '../../../../domain/usecases/investment_group/get_investment_groups_usecase.dart';
import '../../../../domain/usecases/investment_group/manage_investment_group_usecase.dart';
import '../../../../core/services/gamification_service.dart';
import 'investment_group_state.dart';

class InvestmentGroupCubit extends Cubit<InvestmentGroupState> {
  final GetInvestmentGroupsUseCase _getInvestmentGroupsUseCase;
  final ManageInvestmentGroupUseCase _manageInvestmentGroupUseCase;
  final GamificationService _gamificationService;

  InvestmentGroupCubit(
    this._getInvestmentGroupsUseCase,
    this._manageInvestmentGroupUseCase,
    this._gamificationService,
  ) : super(InvestmentGroupInitial());

  Future<void> loadInvestmentGroups() async {
    try {
      emit(InvestmentGroupLoading());
      final result = await _getInvestmentGroupsUseCase.call();
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (groups) => emit(InvestmentGroupsLoaded(groups)),
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to load investment groups: $e'));
    }
  }

  Future<void> createInvestmentGroup(InvestmentGroup group) async {
    try {
      emit(InvestmentGroupLoading());
      final result = await _manageInvestmentGroupUseCase.createGroup(group);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (createdGroup) {
          emit(InvestmentGroupCreated(createdGroup));
          loadInvestmentGroups(); // Refresh the list
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to create investment group: $e'));
    }
  }

  Future<void> updateInvestmentGroup(InvestmentGroup group) async {
    try {
      emit(InvestmentGroupLoading());
      final result = await _manageInvestmentGroupUseCase.updateGroup(group);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (updatedGroup) {
          emit(InvestmentGroupUpdated(updatedGroup));
          loadInvestmentGroups(); // Refresh the list
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to update investment group: $e'));
    }
  }

  Future<void> deleteInvestmentGroup(String groupId) async {
    try {
      emit(InvestmentGroupLoading());
      final result = await _manageInvestmentGroupUseCase.deleteGroup(groupId);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (_) {
          emit(InvestmentGroupDeleted(groupId));
          loadInvestmentGroups(); // Refresh the list
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to delete investment group: $e'));
    }
  }

  Future<void> addMember(String groupId, String userId) async {
    try {
      final result = await _manageInvestmentGroupUseCase.addMember(groupId, userId);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (_) {
          emit(MemberAdded(groupId, userId));
          loadInvestmentGroups(); // Refresh to show updated membership
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to add member: $e'));
    }
  }

  Future<void> removeMember(String groupId, String userId) async {
    try {
      final result = await _manageInvestmentGroupUseCase.removeMember(groupId, userId);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (_) {
          emit(MemberRemoved(groupId, userId));
          loadInvestmentGroups(); // Refresh to show updated membership
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to remove member: $e'));
    }
  }

  Future<void> addContribution(String groupId, String userId, double amount) async {
    try {
      final result = await _manageInvestmentGroupUseCase.addContribution(groupId, userId, amount);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (_) async {
          // Award credits for contributing to investment group
          await _gamificationService.awardCredits(
            userId, 
            (amount / 10).round(), // 1 credit per $10 contributed
            'Investment group contribution'
          );
          
          emit(ContributionAdded(groupId, userId, amount));
          loadInvestmentGroups(); // Refresh to show updated contributions
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to add contribution: $e'));
    }
  }

  Future<void> proposeInvestment(String groupId, Investment investment) async {
    try {
      final result = await _manageInvestmentGroupUseCase.proposeInvestment(groupId, investment);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (proposedInvestment) {
          emit(InvestmentProposed(proposedInvestment));
          loadInvestmentGroups(); // Refresh to show new investment proposal
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to propose investment: $e'));
    }
  }

  Future<void> approveInvestment(String groupId, String investmentId) async {
    try {
      final result = await _manageInvestmentGroupUseCase.approveInvestment(groupId, investmentId);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (_) {
          emit(InvestmentApproved(investmentId));
          loadInvestmentGroups(); // Refresh to show approved investment
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to approve investment: $e'));
    }
  }

  Future<void> rejectInvestment(String groupId, String investmentId) async {
    try {
      final result = await _manageInvestmentGroupUseCase.rejectInvestment(groupId, investmentId);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (_) {
          loadInvestmentGroups(); // Refresh to show updated investment status
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to reject investment: $e'));
    }
  }

  Future<void> updateGroupValue(String groupId, double newValue) async {
    try {
      final result = await _manageInvestmentGroupUseCase.updateGroupValue(groupId, newValue);
      result.fold(
        (failure) => emit(InvestmentGroupError(failure.message)),
        (updatedGroup) {
          emit(InvestmentGroupUpdated(updatedGroup));
          loadInvestmentGroups(); // Refresh to show updated values
        },
      );
    } catch (e) {
      emit(InvestmentGroupError('Failed to update group value: $e'));
    }
  }
}