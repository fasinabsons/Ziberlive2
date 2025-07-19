import '../../domain/entities/gamification.dart';
import '../error/failures.dart';
import '../utils/result.dart';
import 'ad_service.dart';

abstract class RewardCoinService {
  Future<Result<RewardCoins>> getUserCoins(String userId);
  Future<Result<RewardCoins>> awardCoins(String userId, int coins, CoinEarnReason reason, {String? description});
  Future<Result<RewardCoins>> spendCoins(String userId, int coins, String description);
  Future<Result<List<CoinTransaction>>> getCoinHistory(String userId);
  Future<Result<void>> watchAdForCoins(String userId);
  Future<Result<void>> completeTaskForCoins(String userId, String taskId);
  Future<Result<void>> voteForCoins(String userId, String voteId);
  Future<Result<CoinRedemption>> redeemCoins(String userId, RedemptionType type, int coinCost);
}

class RewardCoinServiceImpl implements RewardCoinService {
  final AdService _adService;
  
  RewardCoinServiceImpl(this._adService);
  
  @override
  Future<Result<RewardCoins>> getUserCoins(String userId) async {
    try {
      // TODO: Load from database
      // For now, return mock data
      final coins = RewardCoins(
        userId: userId,
        totalCoins: 150,
        availableCoins: 120,
        spentCoins: 30,
        transactions: [],
        lastUpdated: DateTime.now(),
      );
      
      return Success(coins);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get user coins: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<RewardCoins>> awardCoins(
    String userId, 
    int coins, 
    CoinEarnReason reason, {
    String? description,
  }) async {
    try {
      final currentCoins = await getUserCoins(userId);
      
      return currentCoins.fold(
        (failure) => Error(failure),
        (userCoins) async {
          final transaction = CoinTransaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            amount: coins,
            isEarned: true,
            reason: reason,
            description: description ?? _getDefaultDescription(reason),
            createdAt: DateTime.now(),
          );
          
          final updatedCoins = userCoins.copyWith(
            totalCoins: userCoins.totalCoins + coins,
            availableCoins: userCoins.availableCoins + coins,
            transactions: [...userCoins.transactions, transaction],
            lastUpdated: DateTime.now(),
          );
          
          await _saveCoins(updatedCoins);
          
          // Show celebration notification
          await _showCoinEarnedNotification(coins, reason);
          
          return Success(updatedCoins);
        },
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to award coins: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<RewardCoins>> spendCoins(String userId, int coins, String description) async {
    try {
      final currentCoins = await getUserCoins(userId);
      
      return currentCoins.fold(
        (failure) => Error(failure),
        (userCoins) async {
          if (userCoins.availableCoins < coins) {
            return Error(ValidationFailure(
              field: 'coins',
              message: 'Insufficient coins. You have ${userCoins.availableCoins} coins.',
            ));
          }
          
          final transaction = CoinTransaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            amount: coins,
            isEarned: false,
            reason: CoinEarnReason.adViewing, // Default for spending
            description: description,
            createdAt: DateTime.now(),
          );
          
          final updatedCoins = userCoins.copyWith(
            availableCoins: userCoins.availableCoins - coins,
            spentCoins: userCoins.spentCoins + coins,
            transactions: [...userCoins.transactions, transaction],
            lastUpdated: DateTime.now(),
          );
          
          await _saveCoins(updatedCoins);
          
          return Success(updatedCoins);
        },
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to spend coins: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<CoinTransaction>>> getCoinHistory(String userId) async {
    try {
      final coinsResult = await getUserCoins(userId);
      
      return coinsResult.fold(
        (failure) => Error(failure),
        (coins) => Success(coins.transactions),
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get coin history: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> watchAdForCoins(String userId) async {
    try {
      // Show ad and award coins if successful
      final adResult = await _adService.showRewardedAd();
      
      return adResult.fold(
        (failure) => Error(failure),
        (_) async {
          await awardCoins(
            userId,
            2, // 2 coins per ad
            CoinEarnReason.adViewing,
            description: 'Watched rewarded ad',
          );
          return Success(null);
        },
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to watch ad for coins: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> completeTaskForCoins(String userId, String taskId) async {
    try {
      // Award bonus coins for task completion
      await awardCoins(
        userId,
        _getTaskCoinReward(), // 5-10 coins per task
        CoinEarnReason.taskCompletion,
        description: 'Completed task: $taskId',
      );
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to award task coins: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> voteForCoins(String userId, String voteId) async {
    try {
      // Award coins for voting participation
      await awardCoins(
        userId,
        3, // 3 coins per vote
        CoinEarnReason.voting,
        description: 'Participated in vote: $voteId',
      );
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to award voting coins: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<CoinRedemption>> redeemCoins(String userId, RedemptionType type, int coinCost) async {
    try {
      // Check if user has enough coins
      final coinsResult = await getUserCoins(userId);
      
      return coinsResult.fold(
        (failure) => Error(failure),
        (userCoins) async {
          if (userCoins.availableCoins < coinCost) {
            return Error(ValidationFailure(
              field: 'coins',
              message: 'Insufficient coins for redemption',
            ));
          }
          
          // Spend coins
          final spendResult = await spendCoins(
            userId,
            coinCost,
            'Redeemed: ${_getRedemptionDescription(type)}',
          );
          
          return spendResult.fold(
            (failure) => Error(failure),
            (_) async {
              final redemption = CoinRedemption(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: userId,
                type: type,
                coinCost: coinCost,
                status: RedemptionStatus.completed,
                redeemedAt: DateTime.now(),
              );
              
              await _processRedemption(redemption);
              
              return Success(redemption);
            },
          );
        },
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to redeem coins: ${e.toString()}'));
    }
  }
  
  // Helper methods
  
  String _getDefaultDescription(CoinEarnReason reason) {
    switch (reason) {
      case CoinEarnReason.adViewing:
        return 'Watched advertisement';
      case CoinEarnReason.taskCompletion:
        return 'Completed task';
      case CoinEarnReason.voting:
        return 'Participated in voting';
      case CoinEarnReason.dailyBonus:
        return 'Daily login bonus';
      case CoinEarnReason.streakBonus:
        return 'Activity streak bonus';
      case CoinEarnReason.achievement:
        return 'Achievement unlocked';
    }
  }
  
  int _getTaskCoinReward() {
    // Random reward between 5-10 coins
    return 5 + (DateTime.now().millisecond % 6);
  }
  
  String _getRedemptionDescription(RedemptionType type) {
    switch (type) {
      case RedemptionType.adFreeExperience:
        return '24-hour ad-free experience';
      case RedemptionType.luckyDrawTicket:
        return 'Lucky draw ticket';
      case RedemptionType.premiumFeatures:
        return 'Premium features access';
    }
  }
  
  Future<void> _saveCoins(RewardCoins coins) async {
    // TODO: Save to database
    print('Saving coins for user ${coins.userId}: ${coins.availableCoins} available');
  }
  
  Future<void> _showCoinEarnedNotification(int coins, CoinEarnReason reason) async {
    // TODO: Show local notification
    print('Earned $coins coins for ${reason.name}');
  }
  
  Future<void> _processRedemption(CoinRedemption redemption) async {
    switch (redemption.type) {
      case RedemptionType.adFreeExperience:
        await _activateAdFreeExperience(redemption.userId);
        break;
      case RedemptionType.luckyDrawTicket:
        await _addLuckyDrawTicket(redemption.userId);
        break;
      case RedemptionType.premiumFeatures:
        await _activatePremiumFeatures(redemption.userId);
        break;
    }
  }
  
  Future<void> _activateAdFreeExperience(String userId) async {
    // TODO: Set ad-free flag with 24-hour expiry
    print('Activated 24-hour ad-free experience for user $userId');
  }
  
  Future<void> _addLuckyDrawTicket(String userId) async {
    // TODO: Add ticket to lucky draw system
    print('Added lucky draw ticket for user $userId');
  }
  
  Future<void> _activatePremiumFeatures(String userId) async {
    // TODO: Activate premium features
    print('Activated premium features for user $userId');
  }
}

// Data models for reward coins

enum CoinEarnReason {
  adViewing,
  taskCompletion,
  voting,
  dailyBonus,
  streakBonus,
  achievement,
}

enum RedemptionType {
  adFreeExperience,
  luckyDrawTicket,
  premiumFeatures,
}

enum RedemptionStatus {
  pending,
  completed,
  failed,
}

class RewardCoins {
  final String userId;
  final int totalCoins;
  final int availableCoins;
  final int spentCoins;
  final List<CoinTransaction> transactions;
  final DateTime lastUpdated;

  const RewardCoins({
    required this.userId,
    required this.totalCoins,
    required this.availableCoins,
    required this.spentCoins,
    required this.transactions,
    required this.lastUpdated,
  });

  RewardCoins copyWith({
    String? userId,
    int? totalCoins,
    int? availableCoins,
    int? spentCoins,
    List<CoinTransaction>? transactions,
    DateTime? lastUpdated,
  }) {
    return RewardCoins(
      userId: userId ?? this.userId,
      totalCoins: totalCoins ?? this.totalCoins,
      availableCoins: availableCoins ?? this.availableCoins,
      spentCoins: spentCoins ?? this.spentCoins,
      transactions: transactions ?? this.transactions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class CoinTransaction {
  final String id;
  final String userId;
  final int amount;
  final bool isEarned;
  final CoinEarnReason reason;
  final String description;
  final DateTime createdAt;

  const CoinTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.isEarned,
    required this.reason,
    required this.description,
    required this.createdAt,
  });
}

class CoinRedemption {
  final String id;
  final String userId;
  final RedemptionType type;
  final int coinCost;
  final RedemptionStatus status;
  final DateTime redeemedAt;
  final DateTime? expiresAt;

  const CoinRedemption({
    required this.id,
    required this.userId,
    required this.type,
    required this.coinCost,
    required this.status,
    required this.redeemedAt,
    this.expiresAt,
  });
}