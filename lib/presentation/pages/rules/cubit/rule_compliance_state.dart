import 'package:equatable/equatable.dart';
import '../../../../core/services/rule_compliance_service.dart';

abstract class RuleComplianceState extends Equatable {
  const RuleComplianceState();

  @override
  List<Object?> get props => [];
}

class RuleComplianceInitial extends RuleComplianceState {}

class RuleComplianceLoading extends RuleComplianceState {}

class RuleComplianceLoaded extends RuleComplianceState {
  final RuleComplianceStats stats;
  final List<RuleComplianceRecord> history;
  final ComplianceRewards rewards;

  const RuleComplianceLoaded({
    required this.stats,
    required this.history,
    required this.rewards,
  });

  @override
  List<Object?> get props => [stats, history, rewards];
}

class RuleComplianceError extends RuleComplianceState {
  final String message;

  const RuleComplianceError(this.message);

  @override
  List<Object?> get props => [message];
}

class ComplianceRecorded extends RuleComplianceState {
  final String ruleId;
  final bool isCompliant;

  const ComplianceRecorded({
    required this.ruleId,
    required this.isCompliant,
  });

  @override
  List<Object?> get props => [ruleId, isCompliant];
}

class RewardsCalculated extends RuleComplianceState {
  final ComplianceRewards rewards;

  const RewardsCalculated(this.rewards);

  @override
  List<Object?> get props => [rewards];
}