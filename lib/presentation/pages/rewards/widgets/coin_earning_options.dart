import 'package:flutter/material.dart';

class CoinEarningOptions extends StatelessWidget {
  final VoidCallback? onWatchAd;
  final VoidCallback? onCompleteTask;
  final VoidCallback? onVote;

  const CoinEarningOptions({
    Key? key,
    this.onWatchAd,
    this.onCompleteTask,
    this.onVote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEarningOption(
          'Watch Advertisement',
          'Earn 2 coins per ad',
          Icons.play_circle_filled,
          Colors.blue,
          onWatchAd,
          '2 coins',
        ),
        const SizedBox(height: 12),
        _buildEarningOption(
          'Complete Tasks',
          'Earn 5-10 coins per task',
          Icons.task_alt,
          Colors.green,
          onCompleteTask,
          '5-10 coins',
        ),
        const SizedBox(height: 12),
        _buildEarningOption(
          'Participate in Voting',
          'Earn 3 coins per vote',
          Icons.how_to_vote,
          Colors.purple,
          onVote,
          '3 coins',
        ),
        const SizedBox(height: 12),
        _buildEarningOption(
          'Daily Login Bonus',
          'Come back daily for bonus coins',
          Icons.calendar_today,
          Colors.orange,
          null, // Automatic
          '5 coins',
          isAutomatic: true,
        ),
        const SizedBox(height: 12),
        _buildEarningOption(
          'Activity Streaks',
          'Maintain streaks for bonus rewards',
          Icons.local_fire_department,
          Colors.red,
          null, // Automatic
          '10+ coins',
          isAutomatic: true,
        ),
      ],
    );
  }

  Widget _buildEarningOption(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback? onTap,
    String reward, {
    bool isAutomatic = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (isAutomatic) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Automatic',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reward,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (!isAutomatic && onTap != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Earn Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}