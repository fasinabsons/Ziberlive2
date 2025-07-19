import 'package:equatable/equatable.dart';
import '../../../../core/services/reward_coin_service.dart';

abstract class RewardCoinsState extends Equatable {
  const RewardCoinsState();

  @override
  List<Object?> get props => [];
}

class RewardCoinsInitial extends RewardCoinsState {}

class RewardCoinsLoading extends RewardCoinsState {}

class RewardCoinsLoaded extends RewardCoinsState {
  final RewardCoins coins;

  const RewardCoinsLoaded(this.coins);

  @override
  List<Object?> get props => [coins];
}

class RewardCoinsError extends RewardCoinsState {
  final String message;

  const RewardCoinsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CoinsEarned extends RewardCoinsState {
  final int amount;
  final CoinEarnReason reason;

  const CoinsEarned({
    required this.amount,
    required this.reason,
  });

  @override
  List<Object?> get props => [amount, reason];
}

class CoinsRedeemed extends RewardCoinsState {
  final RedemptionType type;
  final int coinCost;

  const CoinsRedeemed({
    required this.type,
    required this.coinCost,
  });

  @override
  List<Object?> get props => [type, coinCost];
}

class AdWatching extends RewardCoinsState {}

class AdWatchCompleted extends RewardCoinsState {
  final int coinsEarned;

  const AdWatchCompleted(this.coinsEarned);

  @override
  List<Object?> get props => [coinsEarned];
}

class AdWatchFailed extends RewardCoinsState {
  final String message;

  const AdWatchFailed(this.message);

  @override
  List<Object?> get props => [message];
}