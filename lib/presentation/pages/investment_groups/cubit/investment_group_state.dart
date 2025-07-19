import 'package:equatable/equatable.dart';
import '../../../../domain/entities/investment_group.dart';

abstract class InvestmentGroupState extends Equatable {
  const InvestmentGroupState();

  @override
  List<Object?> get props => [];
}

class InvestmentGroupInitial extends InvestmentGroupState {}

class InvestmentGroupLoading extends InvestmentGroupState {}

class InvestmentGroupsLoaded extends InvestmentGroupState {
  final List<InvestmentGroup> groups;

  const InvestmentGroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class InvestmentGroupCreated extends InvestmentGroupState {
  final InvestmentGroup group;

  const InvestmentGroupCreated(this.group);

  @override
  List<Object?> get props => [group];
}

class InvestmentGroupUpdated extends InvestmentGroupState {
  final InvestmentGroup group;

  const InvestmentGroupUpdated(this.group);

  @override
  List<Object?> get props => [group];
}

class InvestmentGroupDeleted extends InvestmentGroupState {
  final String groupId;

  const InvestmentGroupDeleted(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class InvestmentGroupError extends InvestmentGroupState {
  final String message;

  const InvestmentGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class ContributionAdded extends InvestmentGroupState {
  final String groupId;
  final String userId;
  final double amount;

  const ContributionAdded(this.groupId, this.userId, this.amount);

  @override
  List<Object?> get props => [groupId, userId, amount];
}

class InvestmentProposed extends InvestmentGroupState {
  final Investment investment;

  const InvestmentProposed(this.investment);

  @override
  List<Object?> get props => [investment];
}

class InvestmentApproved extends InvestmentGroupState {
  final String investmentId;

  const InvestmentApproved(this.investmentId);

  @override
  List<Object?> get props => [investmentId];
}

class MemberAdded extends InvestmentGroupState {
  final String groupId;
  final String userId;

  const MemberAdded(this.groupId, this.userId);

  @override
  List<Object?> get props => [groupId, userId];
}

class MemberRemoved extends InvestmentGroupState {
  final String groupId;
  final String userId;

  const MemberRemoved(this.groupId, this.userId);

  @override
  List<Object?> get props => [groupId, userId];
}