import 'package:flutter/material.dart';
import '../leaderboard_page.dart';

class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final bool showAnonymous;
  final Color color;
  final VoidCallback? onTap;

  const LeaderboardCard({
    Key? key,
    required this.entry,
    required this.rank,
    required this.showAnonymous,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    final displayName = showAnonymous ? entry.anonymousName : entry.userName;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: isTopThree
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getRankColor(rank).withOpacity(0.1),
                    _getRankColor(rank).withOpacity(0.05),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isTopThree
              ? Border.all(color: _getRankColor(rank).withOpacity(0.3), width: 2)
              : null,
        ),
        child: Card(
          elevation: isTopThree ? 4 : 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Rank badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isTopThree ? _getRankColor(rank) : Colors.grey[400],
                    shape: BoxShape.circle,
                    boxShadow: isTopThree
                        ? [
                            BoxShadow(
                              color: _getRankColor(rank).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isTopThree
                        ? Icon(
                            _getRankIcon(rank),
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '$rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isTopThree ? _getRankColor(rank) : Colors.black87,
                              ),
                            ),
                          ),
                          if (isTopThree)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRankColor(rank),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getRankLabel(rank),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.stars, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.totalCredits} credits',
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (entry.currentStreak > 0) ...[
                            Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.currentStreak}d',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatChip(
                            '${entry.tasksCompleted}',
                            'tasks',
                            Icons.task_alt,
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(
                            '${entry.billsPaid}',
                            'bills',
                            Icons.receipt,
                            Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(
                            '${entry.votesCast}',
                            'votes',
                            Icons.how_to_vote,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow indicator
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey; // Silver
      case 3:
        return Colors.brown; // Bronze
      default:
        return Colors.grey;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.workspace_premium; // Badge
      default:
        return Icons.star;
    }
  }

  String _getRankLabel(int rank) {
    switch (rank) {
      case 1:
        return 'CHAMPION';
      case 2:
        return 'RUNNER-UP';
      case 3:
        return 'BRONZE';
      default:
        return '';
    }
  }
}