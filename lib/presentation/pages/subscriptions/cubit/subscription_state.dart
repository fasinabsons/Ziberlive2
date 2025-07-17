part of 'subscription_cubit.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final User user;

  const SubscriptionLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class SubscriptionSuccess extends SubscriptionState {
  final String message;

  const SubscriptionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}