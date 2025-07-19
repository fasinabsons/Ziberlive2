import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/gamification.dart';
import '../../../domain/entities/user.dart';
import 'cubit/leaderboard_cubit.dart';
import 'cubit/leaderboard_state.dart';
import 'widgets/leaderboard_card.dart';
import 'widgets/user_rank_widget.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAnonymous = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<LeaderboardCubit>().loadLeaderboards();
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
        title: const Text('Community Leaderboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overall', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Tasks', icon: Icon(Icons.task_alt)),
            Tab(text: 'Community', icon: Icon(Icons.people)),
            Tab(text: 'Streaks', icon: Icon(Icons.local_fire_department)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _toggleAnonymousMode(),
            icon: Icon(_showAnonymous ? Icons.visibility_off : Icons.visibility),
            tooltip: _showAnonymous ? 'Show Names' : 'Show Anonymous',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Leaderboard'),
                ),
              ),
              const PopupMenuItem(
                value: 'filter',
                child: ListTile(
                  leading: Icon(Icons.filter_list),
                  title: Text('Filter Options'),
                ),
              ),
              const PopupMenuItem(
                value: 'recognition',
                child: ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Community Recognition'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<LeaderboardCubit, LeaderboardState>(
        listener: (context, state) {
          if (state is LeaderboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildCurrentUserRank(state),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverallTab(state),
                    _buildTasksTab(state),
                    _buildCommunityTab(state),
                    _buildStreaksTab(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentUserRank(LeaderboardState state) {
    if (state is LeaderboardsLoaded) {
      final currentUserRank = state.currentUserRank;
      if (currentUserRank != null) {
        return UserRankWidget(
          rank: currentUserRank,
          showAnonymous: _showAnonymous,
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[400],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rank',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Loading...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallTab(LeaderboardState state) {
    if (state is LeaderboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LeaderboardsLoaded) {
      return _buildLeaderboardList(
        state.overallLeaderboard,
        'Overall Performance',
        Icons.emoji_events,
        Colors.amber,
      );
    }

    return _buildEmptyState('No leaderboard data available');
  }

  Widget _buildTasksTab(LeaderboardState state) {
    if (state is LeaderboardsLoaded) {
      return _buildLeaderboardList(
        state.taskLeaderboard,
        'Task Completion',
        Icons.task_alt,
        Colors.blue,
      );
    }

    return _buildEmptyState('No task leaderboard data available');
  }

  Widget _buildCommunityTab(LeaderboardState state) {
    if (state is LeaderboardsLoaded) {
      return _buildLeaderboardList(
        state.communityLeaderboard,
        'Community Participation',
        Icons.people,
        Colors.green,
      );
    }

    return _buildEmptyState('No community leaderboard data available');
  }

  Widget _buildStreaksTab(LeaderboardState state) {
    if (state is LeaderboardsLoaded) {
      return _buildLeaderboardList(
        state.streakLeaderboard,
        'Longest Streaks',
        Icons.local_fire_department,
        Colors.orange,
      );
    }

    return _buildEmptyState('No streak leaderboard data available');
  }

  Widget _buildLeaderboardList(
    List<LeaderboardEntry> entries,
    String title,
    IconData icon,
    Color color,
  ) {
    if (entries.isEmpty) {
      return _buildEmptyState('No $title data available');
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: color.withOpacity(0.1),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '${entries.length} participants',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return LeaderboardCard(
                entry: entry,
                rank: index + 1,
                showAnonymous: _showAnonymous,
                color: color,
                onTap: () => _showUserDetails(entry),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete more activities to see rankings!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleAnonymousMode() {
    setState(() {
      _showAnonymous = !_showAnonymous;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareLeaderboard();
        break;
      case 'filter':
        _showFilterDialog();
        break;
      case 'recognition':
        _showCommunityRecognition();
        break;
    }
  }

  void _shareLeaderboard() {
    // TODO: Implement leaderboard sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leaderboard sharing coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Anonymous'),
              subtitle: const Text('Hide real names for privacy'),
              value: _showAnonymous,
              onChanged: (value) {
                setState(() => _showAnonymous = value);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Time Period'),
              subtitle: const Text('All time'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement time period filter
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Category Filter'),
              subtitle: const Text('All categories'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement category filter
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCommunityRecognition() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Community Recognition'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Outstanding Contributors This Month:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildRecognitionItem(
                'Task Champion',
                'Anonymous User #1',
                '45 tasks completed',
                Icons.task_alt,
                Colors.blue,
              ),
              _buildRecognitionItem(
                'Community Helper',
                'Anonymous User #3',
                'Helped 12 roommates',
                Icons.people,
                Colors.green,
              ),
              _buildRecognitionItem(
                'Streak Master',
                'Anonymous User #2',
                '28-day streak',
                Icons.local_fire_department,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recognition is based on consistent participation and helping others in the community.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionItem(
    String title,
    String user,
    String achievement,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 16,
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  user,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  achievement,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(LeaderboardEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_showAnonymous ? entry.anonymousName : entry.userName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total Credits', '${entry.totalCredits}', Icons.stars, Colors.amber),
            _buildStatRow('Tasks Completed', '${entry.tasksCompleted}', Icons.task_alt, Colors.blue),
            _buildStatRow('Bills Paid', '${entry.billsPaid}', Icons.receipt, Colors.green),
            _buildStatRow('Votes Cast', '${entry.votesCast}', Icons.how_to_vote, Colors.purple),
            _buildStatRow('Current Streak', '${entry.currentStreak} days', Icons.local_fire_department, Colors.orange),
            const SizedBox(height: 16),
            if (entry.achievements.isNotEmpty) ...[
              const Text(
                'Recent Achievements:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...entry.achievements.take(3).map((achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(child: Text(achievement, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!_showAnonymous)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _sendAppreciation(entry);
              },
              icon: const Icon(Icons.thumb_up),
              label: const Text('Appreciate'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _sendAppreciation(LeaderboardEntry entry) {
    // TODO: Implement appreciation system
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent appreciation to ${entry.userName}!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Supporting classes
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String anonymousName;
  final int totalCredits;
  final int tasksCompleted;
  final int billsPaid;
  final int votesCast;
  final int currentStreak;
  final int longestStreak;
  final List<String> achievements;
  final DateTime lastActive;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.anonymousName,
    required this.totalCredits,
    required this.tasksCompleted,
    required this.billsPaid,
    required this.votesCast,
    required this.currentStreak,
    required this.longestStreak,
    required this.achievements,
    required this.lastActive,
  });
}