import 'package:flutter/material.dart';
import '../../../../domain/entities/gamification.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final UserAchievement userAchievement;
  final VoidCallback? onTap;

  const AchievementCard({
    Key? key,
    required this.achievement,
    required this.userAchievement,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = userAchievement.isUnlocked;
    final progress = userAchievement.currentProgress / achievement.requiredCount;
    final color = _getAchievementColor(achievement.type);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isUnlocked ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isUnlocked ? color : Colors.transparent,
            width: isUnlocked ? 2 : 0,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUnlocked 
                            ? color 
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getAchievementIcon(achievement.type),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              'Unlocked',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (userAchievement.currentProgress > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'In Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Achievement name
                Text(
                  achievement.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? color : Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Achievement description
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Progress or completion info
                if (isUnlocked) ...[
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${achievement.creditsReward}',
                        style: TextStyle(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (userAchievement.unlockedAt != null)
                        Text(
                          _formatDate(userAchievement.unlockedAt!),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
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
                            '${userAchievement.currentProgress}/${achievement.requiredCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.stars, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '${achievement.creditsReward}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
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
    return '${date.day}/${date.month}';
  }
}