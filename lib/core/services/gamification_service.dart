import 'package:dartz/dartz.dart';
import '../../domain/entities/gamification.dart';
import '../../domain/entities/task.dart';
import '../error/failures.dart';
import '../utils/result.dart';

abstract class GamificationService {
  Future<Either<Failure, CoLivingCredits>> awardCredits(
    String userId,
    int credits,
    CreditReason reason, {
    String? description,
    String? relatedEntityId,
  });
  
  Future<Either<Failure, CoLivingCredits>> spendCredits(
    String userId,
    int credits,
    String description,
  );
  
  Future<Either<Failure, CoLivingCredits>> getUserCredits(String userId);
  
  Future<Either<Failure, CompletionStreak>> updateStreak(
    String userId,
    String type,
    bool completed,
  );
  
  Future<Either<Failure, List<CompletionStreak>>> getUserStreaks(String userId);
  
  Future<Either<Failure, List<UserAchievement>>> checkAchievements(String userId);
  
  Future<Either<Failure, GamificationStats>> getUserStats(String userId);
  
  Future<Either<Failure, List<Achievement>>> getAvailableAchievements();
}

class GamificationServiceImpl implements GamificationService {
  // This would typically use a repository, but for now we'll simulate the logic
  
  @override
  Future<Either<Failure, CoLivingCredits>> awardCredits(
    String userId,
    int credits,
    CreditReason reason, {
    String? description,
    String? relatedEntityId,
  }) async {
    try {
      // Get current credits
      final currentCredits = await getUserCredits(userId);
      
      return currentCredits.fold(
        (failure) => Left(failure),
        (userCredits) async {
          // Create transaction
          final transaction = CreditTransaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            amount: credits,
            isEarned: true,
            reason: reason,
            description: description ?? _getDefaultDescription(reason),
            relatedEntityId: relatedEntityId,
            createdAt: DateTime.now(),
          );
          
          // Update credits
          final updatedCredits = userCredits.copyWith(
            totalCredits: userCredits.totalCredits + credits,
            availableCredits: userCredits.availableCredits + credits,
            transactions: [...userCredits.transactions, transaction],
            lastUpdated: DateTime.now(),
          );
          
          // TODO: Save to database
          await _saveCredits(updatedCredits);
          
          // Check for streak bonuses
          if (reason == CreditReason.taskCompletion) {
            await _checkStreakBonus(userId, credits);
          }
          
          // Check for achievements
          await checkAchievements(userId);
          
          return Right(updatedCredits);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to award credits: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, CoLivingCredits>> spendCredits(
    String userId,
    int credits,
    String description,
  ) async {
    try {
      final currentCredits = await getUserCredits(userId);
      
      return currentCredits.fold(
        (failure) => Left(failure),
        (userCredits) async {
          if (userCredits.availableCredits < credits) {
            return Left(ValidationFailure('Insufficient credits'));
          }
          
          final transaction = CreditTransaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            amount: credits,
            isEarned: false,
            reason: CreditReason.communityParticipation, // Default for spending
            description: description,
            createdAt: DateTime.now(),
          );
          
          final updatedCredits = userCredits.copyWith(
            availableCredits: userCredits.availableCredits - credits,
            spentCredits: userCredits.spentCredits + credits,
            transactions: [...userCredits.transactions, transaction],
            lastUpdated: DateTime.now(),
          );
          
          await _saveCredits(updatedCredits);
          
          return Right(updatedCredits);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to spend credits: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, CoLivingCredits>> getUserCredits(String userId) async {
    try {
      // TODO: Load from database
      // For now, return default credits
      final credits = CoLivingCredits(
        userId: userId,
        totalCredits: 0,
        availableCredits: 0,
        spentCredits: 0,
        transactions: [],
        lastUpdated: DateTime.now(),
      );
      
      return Right(credits);
    } catch (e) {
      return Left(ServerFailure('Failed to get user credits: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, CompletionStreak>> updateStreak(
    String userId,
    String type,
    bool completed,
  ) async {
    try {
      // Get current streak
      final currentStreak = await _getCurrentStreak(userId, type);
      
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      if (completed) {
        // Check if this continues the streak
        final isConsecutive = currentStreak.lastCompletionDate.isAfter(yesterday) ||
                             _isSameDay(currentStreak.lastCompletionDate, yesterday);
        
        final newCurrentStreak = isConsecutive ? currentStreak.currentStreak + 1 : 1;
        final newLongestStreak = newCurrentStreak > currentStreak.longestStreak 
            ? newCurrentStreak 
            : currentStreak.longestStreak;
        
        final updatedStreak = currentStreak.copyWith(
          currentStreak: newCurrentStreak,
          longestStreak: newLongestStreak,
          lastCompletionDate: now,
          streakStartDate: isConsecutive ? currentStreak.streakStartDate : now,
          isActive: true,
        );
        
        await _saveStreak(updatedStreak);
        
        // Award streak bonus credits
        if (newCurrentStreak % 7 == 0) { // Weekly streak bonus
          await awardCredits(
            userId,
            newCurrentStreak * 2, // 2 credits per week in streak
            CreditReason.streakBonus,
            description: '$type streak bonus: $newCurrentStreak days',
          );
        }
        
        return Right(updatedStreak);
      } else {
        // Break the streak if it was active
        if (currentStreak.isActive) {
          final brokenStreak = currentStreak.copyWith(
            currentStreak: 0,
            isActive: false,
          );
          
          await _saveStreak(brokenStreak);
          return Right(brokenStreak);
        }
        
        return Right(currentStreak);
      }
    } catch (e) {
      return Left(ServerFailure('Failed to update streak: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<CompletionStreak>>> getUserStreaks(String userId) async {
    try {
      // TODO: Load from database
      final streaks = <CompletionStreak>[];
      return Right(streaks);
    } catch (e) {
      return Left(ServerFailure('Failed to get user streaks: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<UserAchievement>>> checkAchievements(String userId) async {
    try {
      final stats = await getUserStats(userId);
      
      return stats.fold(
        (failure) => Left(failure),
        (userStats) async {
          final newAchievements = <UserAchievement>[];
          final availableAchievements = await getAvailableAchievements();
          
          return availableAchievements.fold(
            (failure) => Left(failure),
            (achievements) async {
              for (final achievement in achievements) {
                final userAchievement = userStats.achievements.firstWhere(
                  (ua) => ua.achievementId == achievement.id,
                  orElse: () => UserAchievement(
                    id: '${userId}_${achievement.id}',
                    userId: userId,
                    achievementId: achievement.id,
                    currentProgress: 0,
                    isUnlocked: false,
                    createdAt: DateTime.now(),
                  ),
                );
                
                if (!userAchievement.isUnlocked) {
                  final progress = _calculateAchievementProgress(achievement, userStats);
                  
                  if (progress >= achievement.requiredCount) {
                    // Unlock achievement
                    final unlockedAchievement = userAchievement.copyWith(
                      currentProgress: progress,
                      isUnlocked: true,
                      unlockedAt: DateTime.now(),
                    );
                    
                    newAchievements.add(unlockedAchievement);
                    
                    // Award achievement credits
                    await awardCredits(
                      userId,
                      achievement.creditsReward,
                      CreditReason.achievement,
                      description: 'Achievement unlocked: ${achievement.name}',
                      relatedEntityId: achievement.id,
                    );
                  }
                }
              }
              
              return Right(newAchievements);
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to check achievements: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, GamificationStats>> getUserStats(String userId) async {
    try {
      // TODO: Load from database
      final stats = GamificationStats(
        userId: userId,
        totalTasksCompleted: 0,
        totalBillsPaid: 0,
        totalVotesCast: 0,
        totalCreditsEarned: 0,
        currentTaskStreak: 0,
        longestTaskStreak: 0,
        achievements: [],
        lastUpdated: DateTime.now(),
      );
      
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure('Failed to get user stats: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<Achievement>>> getAvailableAchievements() async {
    try {
      final achievements = _getSystemAchievements();
      return Right(achievements);
    } catch (e) {
      return Left(ServerFailure('Failed to get achievements: ${e.toString()}'));
    }
  }
  
  // Helper methods
  
  String _getDefaultDescription(CreditReason reason) {
    switch (reason) {
      case CreditReason.taskCompletion:
        return 'Task completed successfully';
      case CreditReason.billPayment:
        return 'Bill paid on time';
      case CreditReason.voting:
        return 'Participated in community voting';
      case CreditReason.communityParticipation:
        return 'Community participation';
      case CreditReason.scheduleCompletion:
        return 'Schedule slot completed';
      case CreditReason.streakBonus:
        return 'Streak bonus awarded';
      case CreditReason.achievement:
        return 'Achievement unlocked';
    }
  }
  
  Future<void> _saveCredits(CoLivingCredits credits) async {
    // TODO: Save to database
    print('Saving credits for user ${credits.userId}: ${credits.availableCredits} available');
  }
  
  Future<CompletionStreak> _getCurrentStreak(String userId, String type) async {
    // TODO: Load from database
    return CompletionStreak(
      userId: userId,
      type: type,
      currentStreak: 0,
      longestStreak: 0,
      lastCompletionDate: DateTime.now().subtract(const Duration(days: 2)),
      streakStartDate: DateTime.now(),
      isActive: false,
    );
  }
  
  Future<void> _saveStreak(CompletionStreak streak) async {
    // TODO: Save to database
    print('Saving streak for user ${streak.userId}: ${streak.currentStreak} ${streak.type} streak');
  }
  
  Future<void> _checkStreakBonus(String userId, int baseCredits) async {
    final taskStreak = await _getCurrentStreak(userId, 'task');
    
    // Award bonus credits for maintaining streaks
    if (taskStreak.currentStreak >= 7) {
      final bonusCredits = (taskStreak.currentStreak / 7).floor() * 2;
      await awardCredits(
        userId,
        bonusCredits,
        CreditReason.streakBonus,
        description: 'Task completion streak bonus',
      );
    }
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  int _calculateAchievementProgress(Achievement achievement, GamificationStats stats) {
    switch (achievement.type) {
      case AchievementType.taskMaster:
        return stats.totalTasksCompleted;
      case AchievementType.streakKeeper:
        return stats.longestTaskStreak;
      case AchievementType.communityHelper:
        return stats.totalTasksCompleted + stats.totalVotesCast;
      case AchievementType.billPayer:
        return stats.totalBillsPaid;
      case AchievementType.voter:
        return stats.totalVotesCast;
      case AchievementType.chef:
        return 0; // TODO: Implement chef-specific tracking
      case AchievementType.cleaner:
        return 0; // TODO: Implement cleaning task tracking
    }
  }
  
  List<Achievement> _getSystemAchievements() {
    return [
      Achievement(
        id: 'task_master_1',
        name: 'Task Master',
        description: 'Complete 10 tasks',
        type: AchievementType.taskMaster,
        requiredCount: 10,
        creditsReward: 50,
        iconName: 'task_alt',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_keeper_1',
        name: 'Streak Keeper',
        description: 'Maintain a 7-day task completion streak',
        type: AchievementType.streakKeeper,
        requiredCount: 7,
        creditsReward: 100,
        iconName: 'local_fire_department',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'community_helper_1',
        name: 'Community Helper',
        description: 'Complete 5 tasks and cast 5 votes',
        type: AchievementType.communityHelper,
        requiredCount: 10,
        creditsReward: 75,
        iconName: 'people',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'bill_payer_1',
        name: 'Reliable Payer',
        description: 'Pay 5 bills on time',
        type: AchievementType.billPayer,
        requiredCount: 5,
        creditsReward: 30,
        iconName: 'payment',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'voter_1',
        name: 'Voice of the Community',
        description: 'Participate in 10 votes',
        type: AchievementType.voter,
        requiredCount: 10,
        creditsReward: 40,
        iconName: 'how_to_vote',
        createdAt: DateTime.now(),
      ),
    ];
  }
}