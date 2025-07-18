import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/gamification.dart';
import 'cubit/gamification_cubit.dart';
import 'cubit/gamification_state.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({Key? key}) : super(key: key);

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<GamificationCubit>().loadUserCredits();
    context.read<GamificationCubit>().loadUserStats();
    context.read<GamificationCubit>().loadAchievements();
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
        title: const Text('Co-Living Credits'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Credits', icon: Icon(Icons.stars)),
            Tab(text: 'Achievements', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Stats', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: BlocConsumer<GamificationCubit, GamificationState>(
        listener: (context, state) {
          if (state is GamificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCreditsTab(state),
              _buildAchievementsTab(state),
              _buildStatsTab(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreditsTab(GamificationState state) {
    if (state is GamificationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CreditsLoaded) {
      return _buildCreditsView(state.credits);
    }

    return const Center(
      child: Text('No credits data available'),
    );
  }

  Widget _buildCreditsView(CoLivingCredits credits) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GamificationCubit>().loadUserCredits();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreditsOverview(credits),
            const SizedBox(height: 24),
            _buildRedemptionOptions(credits),
            const SizedBox(height: 24),
            _buildTransactionHistory(credits),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsOverview(CoLivingCredits credits) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.stars,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              '${credits.availableCredits}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Available Credits',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${credits.totalCredits}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Total Earned',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${credits.spentCredits}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Total Spent',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionOptions(CoLivingCredits credits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Redeem Credits',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildRedemptionCard(
              'Ad-Free 24h',
              '100 Credits',
              Icons.block,
              Colors.blue,
              credits.availableCredits >= 100,
              () => _redeemCredits('ad_free', 100),
            ),
            _buildRedemptionCard(
              'Cloud Storage',
              '400 Credits',
              Icons.cloud,
              Colors.green,
              credits.availableCredits >= 400,
              () => _redeemCredits('cloud_storage', 400),
            ),
            _buildRedemptionCard(
              'Lucky Draw',
              '50 Credits',
              Icons.casino,
              Colors.orange,
              credits.availableCredits >= 50,
              () => _redeemCredits('lucky_draw', 50),
            ),
            _buildRedemptionCard(
              'Premium Theme',
              '200 Credits',
              Icons.palette,
              Colors.purple,
              credits.availableCredits >= 200,
              () => _redeemCredits('premium_theme', 200),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRedemptionCard(
    String title,
    String cost,
    IconData icon,
    Color color,
    bool canAfford,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: canAfford ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: canAfford ? null : Colors.grey[100],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: canAfford ? color : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: canAfford ? Colors.black : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                cost,
                style: TextStyle(
                  color: canAfford ? color : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(CoLivingCredits credits) {
    final recentTransactions = credits.transactions
        .take(10)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (recentTransactions.isEmpty)
          const Center(
            child: Text(
              'No transactions yet',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = recentTransactions[index];
              return _buildTransactionCard(transaction);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionCard(CreditTransaction transaction) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isEarned ? Colors.green : Colors.red,
          child: Icon(
            transaction.isEarned ? Icons.add : Icons.remove,
            color: Colors.white,
          ),
        ),
        title: Text(transaction.description ?? _getReasonDescription(transaction.reason)),
        subtitle: Text(_formatDate(transaction.createdAt)),
        trailing: Text(
          '${transaction.isEarned ? '+' : '-'}${transaction.amount}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction.isEarned ? Colors.green : Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsTab(GamificationState state) {
    if (state is AchievementsLoaded) {
      return _buildAchievementsView(state.achievements, state.userAchievements);
    }

    return const Center(
      child: Text('No achievements data available'),
    );
  }

  Widget _buildAchievementsView(
    List<Achievement> achievements,
    List<UserAchievement> userAchievements,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GamificationCubit>().loadAchievements();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final userAchievement = userAchievements.firstWhere(
            (ua) => ua.achievementId == achievement.id,
            orElse: () => UserAchievement(
              id: 'temp',
              userId: 'current_user',
              achievementId: achievement.id,
              currentProgress: 0,
              isUnlocked: false,
              createdAt: DateTime.now(),
            ),
          );
          return _buildAchievementCard(achievement, userAchievement);
        },
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, UserAchievement userAchievement) {
    final progress = userAchievement.currentProgress / achievement.requiredCount;
    final isUnlocked = userAchievement.isUnlocked;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnlocked ? Colors.gold : Colors.transparent,
          width: isUnlocked ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? Colors.gold : Colors.grey[300],
              ),
              child: Icon(
                _getAchievementIcon(achievement.iconName),
                size: 30,
                color: isUnlocked ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.gold : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUnlocked ? Colors.gold : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${userAchievement.currentProgress}/${achievement.requiredCount}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (isUnlocked)
                  const Icon(Icons.check_circle, color: Colors.gold, size: 24)
                else
                  Icon(Icons.lock, color: Colors.grey[400], size: 24),
                const SizedBox(height: 4),
                Text(
                  '${achievement.creditsReward}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.gold : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab(GamificationState state) {
    if (state is StatsLoaded) {
      return _buildStatsView(state.stats);
    }

    return const Center(
      child: Text('No stats data available'),
    );
  }

  Widget _buildStatsView(GamificationStats stats) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GamificationCubit>().loadUserStats();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsGrid(stats),
            const SizedBox(height: 24),
            _buildStreakInfo(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(GamificationStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard('Tasks Completed', '${stats.totalTasksCompleted}', Icons.task_alt, Colors.blue),
        _buildStatCard('Bills Paid', '${stats.totalBillsPaid}', Icons.payment, Colors.green),
        _buildStatCard('Votes Cast', '${stats.totalVotesCast}', Icons.how_to_vote, Colors.orange),
        _buildStatCard('Credits Earned', '${stats.totalCreditsEarned}', Icons.stars, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakInfo(GamificationStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Streak Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.local_fire_department, size: 32, color: Colors.orange),
                    const SizedBox(height: 8),
                    Text(
                      '${stats.currentTaskStreak}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Text('Current Streak'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.emoji_events, size: 32, color: Colors.gold),
                    const SizedBox(height: 8),
                    Text(
                      '${stats.longestTaskStreak}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.gold,
                      ),
                    ),
                    const Text('Best Streak'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getReasonDescription(CreditReason reason) {
    switch (reason) {
      case CreditReason.taskCompletion:
        return 'Task completed';
      case CreditReason.billPayment:
        return 'Bill payment';
      case CreditReason.voting:
        return 'Voting participation';
      case CreditReason.communityParticipation:
        return 'Community participation';
      case CreditReason.scheduleCompletion:
        return 'Schedule completed';
      case CreditReason.streakBonus:
        return 'Streak bonus';
      case CreditReason.achievement:
        return 'Achievement unlocked';
    }
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'task_alt':
        return Icons.task_alt;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'people':
        return Icons.people;
      case 'payment':
        return Icons.payment;
      case 'how_to_vote':
        return Icons.how_to_vote;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _redeemCredits(String type, int cost) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Credits'),
        content: Text('Are you sure you want to spend $cost credits on this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<GamificationCubit>().redeemCredits(type, cost);
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}