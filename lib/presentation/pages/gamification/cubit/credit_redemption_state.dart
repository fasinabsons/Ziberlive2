import 'package:equatable/equatable.dart';

abstract class CreditRedemptionState extends Equatable {
  const CreditRedemptionState();

  @override
  List<Object?> get props => [];
}

class CreditRedemptionInitial extends CreditRedemptionState {}

class CreditRedemptionLoading extends CreditRedemptionState {}

class RedemptionSuccess extends CreditRedemptionState {
  final String itemName;
  final int creditsSpent;

  const RedemptionSuccess(this.itemName, this.creditsSpent);

  @override
  List<Object?> get props => [itemName, creditsSpent];
}

class RedemptionError extends CreditRedemptionState {
  final String message;

  const RedemptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdRemovalActivated extends CreditRedemptionState {
  final DateTime expiresAt;

  const AdRemovalActivated(this.expiresAt);

  @override
  List<Object?> get props => [expiresAt];
}

class CloudStorageActivated extends CreditRedemptionState {
  final DateTime expiresAt;

  const CloudStorageActivated(this.expiresAt);

  @override
  List<Object?> get props => [expiresAt];
}