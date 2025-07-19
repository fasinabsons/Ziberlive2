import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/gamification.dart';
import '../../../../core/services/gamification_service.dart';
import '../achievements_page.dart';
import 'achievements_state.dart';

class AchievementsCubit extends Cubit<AchievementsState> {
  final GamificationService _gamificationService;

  AchievementsCubit(this._gamificationService) : super(AchievementsInitial());

  Future<void> loadAchievements() async {
    try {
      emit(AchievementsLoading());
      
      // Load all achievements and user progress
      final achievements = await _loadSystemAchievements();
      final userAchievements = await _loadUserAchievements();
      
      emit(AchievementsLoaded(achievements, userAchievements));
    } catch (e) {
      emit(AchievementsError('Failed to load achievements: $e'));
    }
  }

  Future<List<Achievement>> _loadSystemAchievements() async {
    // TODO: Load from database or service
    // For now, return predefined achievements
    return [
      Achievement(
        id: 'first_task',
        name: 'Getting Started',
        description: 'Complete your first task',
        type: AchievementType.taskMaster,
        requiredCount: 1,
        creditsReward: 10,
        iconName: 'task_alt',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'task_master_10',
        name: 'Task Master',
        description: 'Complete 10 tasks',
        type: AchievementType.taskMaster,
        requiredCount: 10,
        creditsReward: 50,
        iconName: 'task_alt',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'task_master_50',
        name: 'Task Champion',
        description: 'Complete 50 tasks',
        type: AchievementType.taskMaster,
        requiredCount: 50,
        creditsReward: 200,
        iconName: 'task_alt',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_keeper_7',
        name: 'Week Warrior',
        description: 'Maintain a 7-day task completion streak',
        type: AchievementType.streakKeeper,
        requiredCount: 7,
        creditsReward: 75,
        iconName: 'local_fire_department',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_keeper_30',
        name: 'Consistency King',
        description: 'Maintain a 30-day task completion streak',
        type: AchievementType.streakKeeper,
        requiredCount: 30,
        creditsReward: 300,
        iconName: 'local_fire_department',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'bill_payer_5',
        name: 'Reliable Roommate',
        description: 'Pay 5 bills on time',
        type: AchievementType.billPayer,
        requiredCount: 5,
        creditsReward: 40,
        iconName: 'receipt',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'bill_payer_25',
        name: 'Financial Wizard',
        description: 'Pay 25 bills on time',
        type: AchievementType.billPayer,
        requiredCount: 25,
        creditsReward: 150,
        iconName: 'receipt',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'voter_10',
        name: 'Voice of Democracy',
        description: 'Participate in 10 community votes',
        type: AchievementType.voter,
        requiredCount: 10,
        creditsReward: 60,
        iconName: 'how_to_vote',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'community_helper_5',
        name: 'Helping Hand',
        description: 'Help 5 different roommates',
        type: AchievementType.communityHelper,
        requiredCount: 5,
        creditsReward: 80,
        iconName: 'people',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'chef_10',
        name: 'Kitchen Master',
        description: 'Cook 10 community meals',
        type: AchievementType.chef,
        requiredCount: 10,
        creditsReward: 100,
        iconName: 'restaurant',
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'cleaner_20',
        name: 'Cleanliness Champion',
        description: 'Complete 20 cleaning tasks',
        type: AchievementType.cleaner,
        requiredCount: 20,
        creditsReward: 120,
        iconName: 'cleaning_services',
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<List<UserAchievement>> _loadUserAchievements() async {
    // TODO: Load actual user achievements from database
    // For now, return mock data
    const userId = 'current_user';
    
    return [
      UserAchievement(
        id: '1',
        userId: userId,
        achievementId: 'first_task',
        currentProgress: 1,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserAchievement(
        id: '2',
        userId: userId,
        achievementId: 'task_master_10',
        currentProgress: 7,
        isUnlocked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      UserAchievement(
        id: '3',
        userId: userId,
        achievementId: 'bill_payer_5',
        currentProgress: 3,
        isUnlocked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      UserAchievement(
        id: '4',
        userId: userId,
        achievementId: 'streak_keeper_7',
        currentProgress: 5,
        isUnlocked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      UserAchievement(
        id: '5',
        userId: userId,
        achievementId: 'voter_10',
        currentProgress: 2,
        isUnlocked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<void> updateAchievementProgress(String achievementId, int newProgress) async {
    try {
      // Update progress in database
      await _gamificationService.updateAchievementProgress(
        'current_user', // TODO: Get current user ID
        achievementId,
        newProgress,
      );
      
      emit(AchievementProgressUpdated(achievementId, newProgress));
      
      // Check if achievement should be unlocked
      await _checkAchievementUnlock(achievementId, newProgress);
      
      // Reload achievements to reflect changes
      await loadAchievements();
    } catch (e) {
      emit(AchievementsError('Failed to update achievement progress: $e'));
    }
  }

  Future<void> _checkAchievementUnlock(String achievementId, int progress) async {
    final achievements = await _loadSystemAchievements();
    final achievement = achievements.firstWhere((a) => a.id == achievementId);
    
    if (progress >= achievement.requiredCount) {
      // Unlock achievement
      await _unlockAchievement(achievement);
    }
  }

  Future<void> _unlockAchievement(Achievement achievement) async {
    try {
      // Mark achievement as unlocked in database
      await _gamificationService.unlockAchievement(
        'current_user', // TODO: Get current user ID
        achievement.id,
      );
      
      // Award credits
      await _gamificationService.awardCredits(
        'current_user', // TODO: Get current user ID
        achievement.creditsReward,
        'Achievement unlocked: ${achievement.name}',
      );
      
      emit(AchievementUnlocked(achievement));
    } catch (e) {
      emit(AchievementsError('Failed to unlock achievement: $e'));
    }
  }

  Future<void> checkTaskAchievements(int totalTasks) async {
    await updateAchievementProgress('first_task', totalTasks >= 1 ? 1 : 0);
    await updateAchievementProgress('task_master_10', totalTasks);
    await updateAchievementProgress('task_master_50', totalTasks);
  }

  Future<void> checkBillAchievements(int totalBillsPaid) async {
    await updateAchievementProgress('bill_payer_5', totalBillsPaid);
    await updateAchievementProgress('bill_payer_25', totalBillsPaid);
  }

  Future<void> checkVotingAchievements(int totalVotes) async {
    await updateAchievementProgress('voter_10', totalVotes);
  }

  Future<void> checkStreakAchievements(int currentStreak) async {
    await updateAchievementProgress('streak_keeper_7', currentStreak);
    await updateAchievementProgress('streak_keeper_30', currentStreak);
  }

  Future<void> checkCommunityAchievements(int helpCount) async {
    await updateAchievementProgress('community_helper_5', helpCount);
  }

  Future<void> checkChefAchievements(int mealsCooked) async {
    await updateAchievementProgress('chef_10', mealsCooked);
  }

  Future<void> checkCleaningAchievements(int cleaningTasks) async {
    await updateAchievementProgress('cleaner_20', cleaningTasks);
  }

  Future<void> checkMilestones() async {
    // TODO: Check for milestone achievements
    // This would check various conditions like:
    // - Community Tree level
    // - Investment contributions
    // - Overall participation
    // - Time-based milestones
    
    // Example milestone check
    final communityTreeLevel = 2; // TODO: Get actual level
    if (communityTreeLevel >= 3) {
      final milestone = Milestone(
        id: 'community_builder',
        name: 'Community Builder',
        description: 'Help grow the Community Tree to Level 3',
        icon: Icons.park,
        color: Colors.green,
        isReached: true,
        reachedAt: DateTime.now(),
        creditsReward: 200,
      );
      
      emit(MilestoneReached(milestone));
    }
  }

  Future<void> shareAchievement(String achievementId) async {
    try {
      // TODO: Implement achievement sharing
      // This would:
      // - Generate a shareable image/text
      // - Include Community Tree screenshot if applicable
      // - Share via social media or messaging apps
    } catch (e) {
      emit(AchievementsError('Failed to share achievement: $e'));
    }
  }
}