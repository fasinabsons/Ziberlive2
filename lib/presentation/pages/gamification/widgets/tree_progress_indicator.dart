import 'package:flutter/material.dart';
import '../../../../domain/entities/gamification.dart';

class TreeProgressIndicator extends StatelessWidget {
  final int currentCredits;
  final TreeGrowthLevel currentLevel;
  final int nextLevelCredits;

  const TreeProgressIndicator({
    Key? key,
    required this.currentCredits,
    required this.currentLevel,
    required this.nextLevelCredits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final creditsNeeded = nextLevelCredits - currentCredits;
    final isMaxLevel = currentLevel == TreeGrowthLevel.mysticalTree;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getLevelName(currentLevel),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (!isMaxLevel)
                Text(
                  _getLevelName(_getNextLevel(currentLevel)),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: isMaxLevel ? 1.0 : progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isMaxLevel ? Colors.purple : Colors.green,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentCredits credits',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (!isMaxLevel)
                Text(
                  '$nextLevelCredits credits',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          
          if (!isMaxLevel) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    '$creditsNeeded more credits to next level',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Colors.purple[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Maximum level achieved!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Level benefits
          _buildLevelBenefits(),
        ],
      ),
    );
  }

  Widget _buildLevelBenefits() {
    final benefits = _getLevelBenefits(currentLevel);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 4),
              Text(
                'Level Benefits',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 12, color: Colors.green[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  double _calculateProgress() {
    if (currentLevel == TreeGrowthLevel.mysticalTree) return 1.0;
    
    final previousLevelCredits = _getPreviousLevelCredits(currentLevel);
    final levelRange = nextLevelCredits - previousLevelCredits;
    final currentProgress = currentCredits - previousLevelCredits;
    
    return (currentProgress / levelRange).clamp(0.0, 1.0);
  }

  int _getPreviousLevelCredits(TreeGrowthLevel level) {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return 0;
      case TreeGrowthLevel.sapling:
        return 500;
      case TreeGrowthLevel.youngTree:
        return 1000;
      case TreeGrowthLevel.matureTree:
        return 2000;
      case TreeGrowthLevel.ancientTree:
        return 4000;
      case TreeGrowthLevel.mysticalTree:
        return 8000;
    }
  }

  TreeGrowthLevel _getNextLevel(TreeGrowthLevel level) {
    final currentIndex = level.index;
    if (currentIndex < TreeGrowthLevel.values.length - 1) {
      return TreeGrowthLevel.values[currentIndex + 1];
    }
    return level; // Already at max level
  }

  String _getLevelName(TreeGrowthLevel level) {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return 'Seedling';
      case TreeGrowthLevel.sapling:
        return 'Sapling';
      case TreeGrowthLevel.youngTree:
        return 'Young Tree';
      case TreeGrowthLevel.matureTree:
        return 'Mature Tree';
      case TreeGrowthLevel.ancientTree:
        return 'Ancient Tree';
      case TreeGrowthLevel.mysticalTree:
        return 'Mystical Tree';
    }
  }

  List<String> _getLevelBenefits(TreeGrowthLevel level) {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return [
          'Basic community participation',
          'Credit earning from tasks and bills',
        ];
      case TreeGrowthLevel.sapling:
        return [
          'Enhanced credit multipliers',
          'Access to community polls',
          'Basic tree decorations',
        ];
      case TreeGrowthLevel.youngTree:
        return [
          'Seasonal tree variations',
          'Branch and leaf animations',
          'Community milestone celebrations',
        ];
      case TreeGrowthLevel.matureTree:
        return [
          'Advanced tree features',
          'Root system visualization',
          'Enhanced particle effects',
        ];
      case TreeGrowthLevel.ancientTree:
        return [
          'Wisdom bonus credits',
          'Advanced seasonal decorations',
          'Community leadership recognition',
        ];
      case TreeGrowthLevel.mysticalTree:
        return [
          'Mystical glow effects',
          'Maximum credit multipliers',
          'Legendary community status',
          'Special tree sharing features',
        ];
    }
  }
}