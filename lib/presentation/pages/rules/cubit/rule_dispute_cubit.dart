import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/rule_dispute_service.dart';
import 'rule_dispute_state.dart';

class RuleDisputeCubit extends Cubit<RuleDisputeState> {
  final RuleDisputeService _disputeService;
  
  RuleDisputeCubit(this._disputeService) : super(RuleDisputeInitial());

  Future<void> loadDisputes() async {
    emit(RuleDisputeLoading());
    
    try {
      const currentApartmentId = 'current_apartment'; // TODO: Get from context
      
      final result = await _disputeService.getApartmentDisputes(currentApartmentId);
      
      result.fold(
        (failure) => emit(RuleDisputeError('Failed to load disputes: ${failure.message}')),
        (disputes) => emit(RuleDisputesLoaded(disputes)),
      );
    } catch (e) {
      emit(RuleDisputeError('Failed to load disputes: ${e.toString()}'));
    }
  }

  Future<void> createDispute(String ruleId, String reason, String description) async {
    try {
      const currentApartmentId = 'current_apartment'; // TODO: Get from context
      const currentUserId = 'current_user'; // TODO: Get from context
      
      final result = await _disputeService.createDispute(
        currentApartmentId,
        ruleId,
        currentUserId,
        reason,
        description,
      );
      
      result.fold(
        (failure) => emit(RuleDisputeError('Failed to create dispute: ${failure.message}')),
        (dispute) {
          emit(DisputeCreated(dispute));
          // Reload disputes to show the new one
          loadDisputes();
        },
      );
    } catch (e) {
      emit(RuleDisputeError('Failed to create dispute: ${e.toString()}'));
    }
  }

  Future<void> castVote(String disputeId, bool supportDispute) async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from context
      
      final result = await _disputeService.castDisputeVote(
        disputeId,
        currentUserId,
        supportDispute,
      );
      
      result.fold(
        (failure) => emit(RuleDisputeError('Failed to cast vote: ${failure.message}')),
        (_) {
          emit(VoteCast(disputeId: disputeId, supportDispute: supportDispute));
          // Reload disputes to show updated vote counts
          loadDisputes();
        },
      );
    } catch (e) {
      emit(RuleDisputeError('Failed to cast vote: ${e.toString()}'));
    }
  }

  Future<void> resolveDispute(String disputeId) async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from context (admin)
      
      final result = await _disputeService.resolveDispute(disputeId, currentUserId);
      
      result.fold(
        (failure) => emit(RuleDisputeError('Failed to resolve dispute: ${failure.message}')),
        (dispute) {
          emit(DisputeResolved(dispute));
          // Reload disputes to show updated status
          loadDisputes();
        },
      );
    } catch (e) {
      emit(RuleDisputeError('Failed to resolve dispute: ${e.toString()}'));
    }
  }

  Future<void> loadUserDisputes() async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from context
      
      final result = await _disputeService.getUserDisputes(currentUserId);
      
      result.fold(
        (failure) => emit(RuleDisputeError('Failed to load user disputes: ${failure.message}')),
        (disputes) => emit(RuleDisputesLoaded(disputes)),
      );
    } catch (e) {
      emit(RuleDisputeError('Failed to load user disputes: ${e.toString()}'));
    }
  }

  Future<void> refreshDisputes() async {
    await loadDisputes();
  }
}