import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/rule_compliance_service.dart';
import 'rule_compliance_state.dart';

class RuleComplianceCubit extends Cubit<RuleComplianceState> {
  final RuleComplianceService _complianceService;
  
  RuleComplianceCubit(this._complianceService) : super(RuleComplianceInitial());

  Future<void> loadComplianceData() async {
    emit(RuleComplianceLoading());
    
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      // Load all compliance data in parallel
      final results = await Future.wait([
        _complianceService.getUserComplianceStats(currentUserId),
        _complianceService.getUserComplianceHistory(currentUserId),
        _complianceService.calculateComplianceRewards(currentUserId),
      ]);
      
      final statsResult = results[0];
      final historyResult = results[1];
      final rewardsResult = results[2];
      
      // Check if all results are successful
      if (statsResult.isSuccess && historyResult.isSuccess && rewardsResult.isSuccess) {
        emit(RuleComplianceLoaded(
          stats: statsResult.data!,
          history: historyResult.data!,
          rewards: rewardsResult.data!,
        ));
      } else {
        // Find the first error
        final error = [statsResult, historyResult, rewardsResult]
            .firstWhere((result) => result.isError)
            .error!;
        emit(RuleComplianceError('Failed to load compliance data: ${error.message}'));
      }
    } catch (e) {
      emit(RuleComplianceError('Failed to load compliance data: ${e.toString()}'));
    }
  }

  Future<void> recordCompliance(String ruleId, bool isCompliant) async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      final result = await _complianceService.recordRuleCompliance(
        currentUserId,
        ruleId,
        isCompliant,
      );
      
      result.fold(
        (failure) => emit(RuleComplianceError('Failed to record compliance: ${failure.message}')),
        (_) {
          emit(ComplianceRecorded(ruleId: ruleId, isCompliant: isCompliant));
          // Reload data to show updated stats
          loadComplianceData();
        },
      );
    } catch (e) {
      emit(RuleComplianceError('Failed to record compliance: ${e.toString()}'));
    }
  }

  Future<void> calculateRewards() async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      final result = await _complianceService.calculateComplianceRewards(currentUserId);
      
      result.fold(
        (failure) => emit(RuleComplianceError('Failed to calculate rewards: ${failure.message}')),
        (rewards) => emit(RewardsCalculated(rewards)),
      );
    } catch (e) {
      emit(RuleComplianceError('Failed to calculate rewards: ${e.toString()}'));
    }
  }

  Future<void> refreshData() async {
    await loadComplianceData();
  }
}