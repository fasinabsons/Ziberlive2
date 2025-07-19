import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/gamification_service.dart';
import '../leaderboard_page.dart';
import 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final GamificationService _gamificationService;

  LeaderboardCubit(this._gamificationService) : super(LeaderboardInitial());

  Future<void> loadLeaderboards() async {
    try {
      emit(LeaderboardLoading());
      
      // Load different leaderboard categories
      final overallLeaderboard = await _loadOverallLeaderboard();
      final taskLeaderboard = await _loadTaskLeaderboard();
      final communityLeaderboard = await _loadCommunityLeaderboard();
      final streakLeaderboard = await _loadStreakLeaderboard();
      final currentUserRank = await _loadCurrentUserRank();
      
      emit(LeaderboardsLoaded(
        overallLeaderboard: overallLeaderboard,
        taskLeaderboard: taskLeaderboard,
        communityLeaderboard: communityLeaderboard,
        streakLeaderboard: streakLeaderboard,
        currentUserRank: currentUserRank,
      ));
    } catch (e) {
      emit(LeaderboardError('Failed to load leaderboards: $e'));
    }
  }

  Future<List<LeaderboardEntry>> _loadOverallLeaderboard() async {
    // TODO: Load from actual database
    // For now, return mock data
    return [
      LeaderboardEntry(
        userId: 'user1',
        userName: 'Alice Johnson',
        anonymousName: 'Anonymous User #1',
        totalCredits: 1250,
        tasksCompleted: 45,
        billsPaid: 12,
        votesCast: 18,
        currentStreak: 15,
        longestStreak: 28,
        achievements: ['Task Master', 'Bill Payer', 'Community Helper'],
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      LeaderboardEntry(
        userId: 'user2',
        userName: 'Bob Smith',
        anonymousName: 'Anonymous User #2',
        totalCredits: 1180,
        tasksCompleted: 38,
        billsPaid: 15,
        votesCast: 22,
        currentStreak: 8,
        longestStreak: 15,
        achievements: ['Streak Keeper', 'Voter', 'Cleaner'],
        lastActive: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      LeaderboardEntry(
        userId: 'user3',
        userName: 'Carol Davis',
        anonymousName: 'Anonymous User #3',
        totalCredits: 1050,
        tasksCompleted: 32,
        billsPaid: 10,
        votesCast: 25,
        currentStreak: 12,
        longestStreak: 20,
        achievements: ['Community Helper', 'Voter', 'Chef'],
        lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      LeaderboardEntry(
        userId: 'user4',
        userName: 'David Wilson',
        anonymousName: 'Anonymous User #4',
        totalCredits: 920,
        tasksCompleted: 28,
        billsPaid: 8,
        votesCast: 15,
        currentStreak: 5,
        longestStreak: 12,
        achievements: ['Task Master', 'Bill Payer'],
        lastActive: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      LeaderboardEntry(
        userId: 'user5',
        userName: 'Eva Brown',
        anonymousName: 'Anonymous User #5',
        totalCredits: 850,
        tasksCompleted: 25,
        billsPaid: 9,
        votesCast: 12,
        currentStreak: 3,
        longestStreak: 8,
        achievements: ['Cleaner', 'Chef'],
        lastActive: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  Future<List<LeaderboardEntry>> _loadTaskLeaderboard() async {
    final allEntries = await _loadOverallLeaderboard();
    // Sort by tasks completed
    allEntries.sort((a, b) => b.tasksCompleted.compareTo(a.tasksCompleted));
    return allEntries;
  }

  Future<List<LeaderboardEntry>> _loadCommunityLeaderboard() async {
    final allEntries = await _loadOverallLeaderboard();
    // Sort by community participation (votes cast + helping others)
    allEntries.sort((a, b) {
      final aScore = a.votesCast + a.achievements.length;
      final bScore = b.votesCast + b.achievements.length;
      return bScore.compareTo(aScore);
    });
    return allEntries;
  }

  Future<List<LeaderboardEntry>> _loadStreakLeaderboard() async {
    final allEntries = await _loadOverallLeaderboard();
    // Sort by current streak
    allEntries.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    return allEntries;
  }

  Future<LeaderboardEntry?> _loadCurrentUserRank() async {
    // TODO: Get current user's actual data
    // For now, return mock data for current user
    return LeaderboardEntry(
      userId: 'current_user',
      userName: 'You',
      anonymousName: 'You',
      totalCredits: 750,
      tasksCompleted: 22,
      billsPaid: 6,
      votesCast: 10,
      currentStreak: 4,
      longestStreak: 7,
      achievements: ['Getting Started', 'Task Master'],
      lastActive: DateTime.now(),
    );
  }

  Future<void> shareLeaderboard(String category) async {
    try {
      // TODO: Generate shareable content
      final shareContent = _generateShareContent(category);
      emit(LeaderboardShared(shareContent));
    } catch (e) {
      emit(LeaderboardError('Failed to share leaderboard: $e'));
    }
  }

  String _generateShareContent(String category) {
    // TODO: Generate actual shareable content with Community Tree screenshot
    return 'Check out our apartment\'s $category leaderboard! 🏆\n\n'
           'Our community is thriving with amazing participation!\n'
           '#CommunityLiving #Teamwork';
  }

  Future<void> sendAppreciation(String userId, String message) async {
    try {
      // TODO: Implement appreciation system
      // This would:
      // - Send notification to the user
      // - Award small credits for receiving appreciation
      // - Track appreciation metrics
      // - Update community recognition
      
      await _gamificationService.awardCredits(
        userId,
        5, // Small credit reward for receiving appreciation
        'Received community appreciation',
      );
      
      emit(AppreciationSent(userId, message));
    } catch (e) {
      emit(LeaderboardError('Failed to send appreciation: $e'));
    }
  }

  Future<void> updateUserStats(String userId, {
    int? tasksCompleted,
    int? billsPaid,
    int? votesCast,
    int? currentStreak,
  }) async {
    try {
      // TODO: Update user statistics in database
      // This would be called when users complete activities
      
      // Reload leaderboards to reflect changes
      await loadLeaderboards();
    } catch (e) {
      emit(LeaderboardError('Failed to update user stats: $e'));
    }
  }

  Future<void> filterLeaderboard({
    String? timePeriod,
    String? category,
    bool? showAnonymous,
  }) async {
    try {
      // TODO: Implement filtering logic
      // This would filter leaderboards based on:
      // - Time period (daily, weekly, monthly, all-time)
      // - Category (tasks, bills, votes, etc.)
      // - Anonymous vs named display
      
      await loadLeaderboards();
    } catch (e) {
      emit(LeaderboardError('Failed to filter leaderboard: $e'));
    }
  }

  Future<void> generateCommunityRecognition() async {
    try {
      // TODO: Generate community recognition based on:
      // - Outstanding performance in different categories
      // - Consistent participation
      // - Helping others
      // - Positive community impact
      
      // This could be called weekly/monthly to highlight top contributors
    } catch (e) {
      emit(LeaderboardError('Failed to generate community recognition: $e'));
    }
  }
}