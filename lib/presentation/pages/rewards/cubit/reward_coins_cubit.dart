import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/reward_coin_service.dart';
import 'reward_coins_state.dart';

class RewardCoinsCubit extends Cubit<RewardCoinsState> {
  final RewardCoinService _coinService;
  
  RewardCoinsCubit(this._coinService) : super(RewardCoinsInitial());

  Future<void> loadCoins() async {
    emit(RewardCoinsLoading());
    
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      final result = await _coinService.getUserCoins(currentUserId);
      
      result.fold(
        (failure) => emit(RewardCoinsError('Failed to load coins: ${failure.message}')),
        (coins) => emit(RewardCoinsLoaded(coins)),
      );
    } catch (e) {
      emit(RewardCoinsError('Failed to load coins: ${e.toString()}'));
    }
  }

  Future<void> watchAdForCoins() async {
    emit(AdWatching());
    
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      final result = await _coinService.watchAdForCoins(currentUserId);
      
      result.fold(
        (failure) => emit(AdWatchFailed('Failed to watch ad: ${failure.message}')),
        (_) {
          emit(const AdWatchCompleted(2)); // 2 coins per ad
          emit(const CoinsEarned(amount: 2, reason: CoinEarnReason.adViewing));
          // Reload coins to show updated balance
          loadCoins();
        },
      );
    } catch (e) {
      emit(AdWatchFailed('Failed to watch ad: ${e.toString()}'));
    }
  }

  Future<void> awardTaskCoins(String taskId) async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      final result = await _coinService.completeTaskForCoins(currentUserId, taskId);
      
      result.fold(
        (failure) => emit(RewardCoinsError('Failed to award task coins: ${failure.message}')),
        (_) {
          emit(const CoinsEarned(amount: 7, reason: CoinEarnReason.taskCompletion)); // Average 7 coins
          // Reload coins to show updated balance
          loadCoins();
        },
      );
    } catch (e) {
      emit(RewardCoinsError('Failed to award task coins: ${e.toString()}'));
    }
  }

  Future<void> awardVotingCoins(String voteId) async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      final result = await _coinService.voteForCoins(currentUserId, voteId);
      
      result.fold(
        (failure) => emit(RewardCoinsError('Failed to award voting coins: ${failure.message}')),
        (_) {
          emit(const CoinsEarned(amount: 3, reason: CoinEarnReason.voting));
          // Reload coins to show updated balance
          loadCoins();
        },
      );
    } catch (e) {
      emit(RewardCoinsError('Failed to award voting coins: ${e.toString()}'));
    }
  }

  Future<void> redeemCoins(RedemptionType type, int coinCost) async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      final result = await _coinService.redeemCoins(currentUserId, type, coinCost);
      
      result.fold(
        (failure) => emit(RewardCoinsError('Failed to redeem coins: ${failure.message}')),
        (redemption) {
          emit(CoinsRedeemed(type: type, coinCost: coinCost));
          // Reload coins to show updated balance
          loadCoins();
        },
      );
    } catch (e) {
      emit(RewardCoinsError('Failed to redeem coins: ${e.toString()}'));
    }
  }

  Future<void> awardDailyBonus() async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      final result = await _coinService.awardCoins(
        currentUserId,
        5, // 5 coins daily bonus
        CoinEarnReason.dailyBonus,
        description: 'Daily login bonus',
      );
      
      result.fold(
        (failure) => emit(RewardCoinsError('Failed to award daily bonus: ${failure.message}')),
        (_) {
          emit(const CoinsEarned(amount: 5, reason: CoinEarnReason.dailyBonus));
          // Reload coins to show updated balance
          loadCoins();
        },
      );
    } catch (e) {
      emit(RewardCoinsError('Failed to award daily bonus: ${e.toString()}'));
    }
  }

  Future<void> awardStreakBonus(int streakDays) async {
    try {
      const currentUserId = 'current_user'; // TODO: Get from auth context
      
      final bonusCoins = (streakDays / 7).floor() * 10; // 10 coins per week in streak
      
      if (bonusCoins > 0) {
        final result = await _coinService.awardCoins(
          currentUserId,
          bonusCoins,
          CoinEarnReason.streakBonus,
          description: 'Activity streak bonus: $streakDays days',
        );
        
        result.fold(
          (failure) => emit(RewardCoinsError('Failed to award streak bonus: ${failure.message}')),
          (_) {
            emit(CoinsEarned(amount: bonusCoins, reason: CoinEarnReason.streakBonus));
            // Reload coins to show updated balance
            loadCoins();
          },
        );
      }
    } catch (e) {
      emit(RewardCoinsError('Failed to award streak bonus: ${e.toString()}'));
    }
  }

  Future<void> refreshCoins() async {
    await loadCoins();
  }
}