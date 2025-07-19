import 'package:equatable/equatable.dart';
import '../../../../core/services/rule_dispute_service.dart';

abstract class RuleDisputeState extends Equatable {
  const RuleDisputeState();

  @override
  List<Object?> get props => [];
}

class RuleDisputeInitial extends RuleDisputeState {}

class RuleDisputeLoading extends RuleDisputeState {}

class RuleDisputesLoaded extends RuleDisputeState {
  final List<RuleDispute> disputes;

  const RuleDisputesLoaded(this.disputes);

  @override
  List<Object?> get props => [disputes];
}

class RuleDisputeError extends RuleDisputeState {
  final String message;

  const RuleDisputeError(this.message);

  @override
  List<Object?> get props => [message];
}

class DisputeCreated extends RuleDisputeState {
  final RuleDispute dispute;

  const DisputeCreated(this.dispute);

  @override
  List<Object?> get props => [dispute];
}

class VoteCast extends RuleDisputeState {
  final String disputeId;
  final bool supportDispute;

  const VoteCast({
    required this.disputeId,
    required this.supportDispute,
  });

  @override
  List<Object?> get props => [disputeId, supportDispute];
}

class DisputeResolved extends RuleDisputeState {
  final RuleDispute dispute;

  const DisputeResolved(this.dispute);

  @override
  List<Object?> get props => [dispute];
}