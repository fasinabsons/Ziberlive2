import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/gamification.dart';
import 'cubit/achievements_cubit.dart';
import 'cubit/achievements_state.dart';
import 'widgets/achievement_card.dart';
import 'widgets/milestone_celebration.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<AchievementsCubit>().loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements & Milestones'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Unlocked', icon: Icon(Icons.emoji_events)),
            Tab(text: 'In Progress', icon: Icon(Icons.trending_up)),
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Milestones', icon: Icon(Icons.flag)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _shareAchievements(),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: BlocConsumer<AchievementsCubit, AchievementsState>(
        listener: (context, state) {
          if (state is AchievementUnlocked) {
            _showAchievementCelebration(state.achievement);
          } else if (state is MilestoneReached) {
            _showMilestoneCelebration(state.milestone);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildProgressHeader(state),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUnlockedTab(state),
                    _buildInProgressTab(state),
                    _buildAllAchievementsTab(state),
                    _buildMilestonesTab(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(AchievementsState state) {
    int unlockedCount = 0;
    int totalCount = 0;
    int totalCreditsEarned = 0;

    if (state is AchievementsLoaded) {
      unlockedCount = state.userAchievements.where((ua) => ua.isUnlocked).length;
      totalCount = state.achievements.length;
      totalCreditsEarned = state.userAchievements
          .where((ua) => ua.isUnlocked)
          .fold(0, (sum, ua) {
            final achievement = state.achievements.firstWhere((a) => a.id == ua.achievementId);
            return sum + achievement.creditsReward;
          });
    }

    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievement Progress',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$unlockedCount / $totalCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Credits Earned',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$totalCreditsEarned',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}% Complete',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${totalCount - unlockedCount} remaining',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedTab(AchievementsState state) {
    if (state is AchievementsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AchievementsLoaded) {
      final unlockedAchievements = state.userAchievements
          .where((ua) => ua.isUnlocked)
          .map((ua) => state.achievements.firstWhere((a) => a.id == ua.achievementId))
          .toList();

      if (unlockedAchievements.isEmpty) {
        return _buildEmptyState(
          'No achievements unlocked yet',
          'Complete tasks, pay bills, and participate in community activities to unlock achievements!',
          Icons.emoji_events,
        );
      }

      return _buildAchievementGrid(unlockedAchievements, state.userAchievements, true);
    }

    return const Center(child: Text('Failed to load achievements'));
  }

  Widget _buildInProgressTab(AchievementsState state) {
    if (state is AchievementsLoaded) {
      final inProgressAchievements = state.userAchievements
          .where((ua) => !ua.isUnlocked && ua.currentProgress > 0)
          .map((ua) => state.achievements.firstWhere((a) => a.id == ua.achievementId))
          .toList();

      if (inProgressAchievements.isEmpty) {
        return _buildEmptyState(
          'No achievements in progress',
          'Start completing tasks and participating in community activities to make progress!',
          Icons.trending_up,
        );
      }

      return _buildAchievementGrid(inProgressAchievements, state.userAchievements, false);
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildAllAchievementsTab(AchievementsState state) {
    if (state is AchievementsLoaded) {
      return _buildAchievementGrid(state.achievements, state.userAchievements, null);
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildMilestonesTab(AchievementsState state) {
    final milestones = [
      Milestone(
        id: 'first_week',
        name: 'First Week Survivor',
        description: 'Complete your first week in the apartment',
        icon: Icons.calendar_today,
        color: Colors.green,
        isReached: true,
        reachedAt: DateTime.now().subtract(const Duration(days: 20)),
        creditsReward: 50,
      ),
      Milestone(
        id: 'task_master',
        name: 'Task Master',
        description: 'Complete 50 tasks',
        icon: Icons.task_alt,
        color: Colors.blue,
        isReached: true,
        reachedAt: DateTime.now().subtract(const Duration(days: 10)),
        creditsReward: 100,
      ),
      Milestone(
        id: 'community_builder',
        name: 'Community Builder',
        description: 'Help grow the Community Tree to Level 3',
        icon: Icons.park,
        color: Colors.green,
        isReached: false,
        progress: 0.7,
        creditsReward: 200,
      ),
      Milestone(
        id: 'investor',
        name: 'Smart Investor',
        description: 'Contribute $1000 to investment groups',
        icon: Icons.trending_up,
        color: Colors.amber,
        isReached: false,
        progress: 0.3,
        creditsReward: 150,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        return _buildMilestoneCard(milestone);
      },
    );
  }

  Widget _buildAchievementGrid(
    List<Achievement> achievements,
    List<UserAchievement> userAchievements,
    bool? showOnlyUnlocked,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final userAchievement = userAchievements.firstWhere(
          (ua) => ua.achievementId == achievement.id,
          orElse: () => UserAchievement(
            id: '',
            userId: '',
            achievementId: achievement.id,
            currentProgress: 0,
            isUnlocked: false,
            createdAt: DateTime.now(),
          ),
        );

        return AchievementCard(
          achievement: achievement,
          userAchievement: userAchievement,
          onTap: () => _showAchievementDetails(achievement, userAchievement),
        );
      },
    );
  }

  Widget _buildMilestoneCard(Milestone milestone) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              milestone.color.withOpacity(0.1),
              milestone.color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: milestone.isReached 
                      ? milestone.color 
                      : milestone.color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  milestone.icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      milestone.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (milestone.isReached) ...[
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Reached ${_formatDate(milestone.reachedAt!)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(milestone.progress * 100).toStringAsFixed(0)}% Complete',
                                style: TextStyle(
                                  color: milestone.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.stars, color: Colors.amber, size: 14),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${milestone.creditsReward}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: milestone.progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(milestone.color),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement, UserAchievement userAchievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getAchievementIcon(achievement.type),
              color: _getAchievementColor(achievement.type),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(achievement.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            if (!userAchievement.isUnlocked) ...[
              Text(
                'Progress: ${userAchievement.currentProgress} / ${achievement.requiredCount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: userAchievement.currentProgress / achievement.requiredCount,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getAchievementColor(achievement.type),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Reward: ${achievement.creditsReward} credits',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (userAchievement.isUnlocked && userAchievement.unlockedAt != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked ${_formatDate(userAchievement.unlockedAt!)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (userAchievement.isUnlocked)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _shareAchievement(achievement);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
        ],
      ),
    );
  }

  void _showAchievementCelebration(Achievement achievement) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MilestoneCelebration(
        title: 'Achievement Unlocked!',
        subtitle: achievement.name,
        description: achievement.description,
        icon: _getAchievementIcon(achievement.type),
        color: _getAchievementColor(achievement.type),
        creditsEarned: achievement.creditsReward,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showMilestoneCelebration(Milestone milestone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MilestoneCelebration(
        title: 'Milestone Reached!',
        subtitle: milestone.name,
        description: milestone.description,
        icon: milestone.icon,
        color: milestone.color,
        creditsEarned: milestone.creditsReward,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.taskMaster:
        return Icons.task_alt;
      case AchievementType.streakKeeper:
        return Icons.local_fire_department;
      case AchievementType.communityHelper:
        return Icons.people;
      case AchievementType.billPayer:
        return Icons.receipt;
      case AchievementType.voter:
        return Icons.how_to_vote;
      case AchievementType.chef:
        return Icons.restaurant;
      case AchievementType.cleaner:
        return Icons.cleaning_services;
    }
  }

  Color _getAchievementColor(AchievementType type) {
    switch (type) {
      case AchievementType.taskMaster:
        return Colors.blue;
      case AchievementType.streakKeeper:
        return Colors.orange;
      case AchievementType.communityHelper:
        return Colors.green;
      case AchievementType.billPayer:
        return Colors.purple;
      case AchievementType.voter:
        return Colors.red;
      case AchievementType.chef:
        return Colors.brown;
      case AchievementType.cleaner:
        return Colors.teal;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _shareAchievement(Achievement achievement) {
    // TODO: Implement achievement sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared achievement: ${achievement.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareAchievements() {
    // TODO: Implement achievements sharing (Community Tree screenshot)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Achievement sharing coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Supporting classes
class Milestone {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isReached;
  final DateTime? reachedAt;
  final double progress;
  final int creditsReward;

  Milestone({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isReached = false,
    this.reachedAt,
    this.progress = 0.0,
    required this.creditsReward,
  });
}