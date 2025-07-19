import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/gamification.dart';
import '../../../core/services/gamification_service.dart';
import 'widgets/animated_community_tree.dart';
import 'widgets/tree_progress_indicator.dart';
import 'widgets/seasonal_decorations.dart';

class CommunityTreePage extends StatefulWidget {
  const CommunityTreePage({Key? key}) : super(key: key);

  @override
  State<CommunityTreePage> createState() => _CommunityTreePageState();
}

class _CommunityTreePageState extends State<CommunityTreePage>
    with TickerProviderStateMixin {
  late AnimationController _treeGrowthController;
  late AnimationController _particleController;
  late AnimationController _seasonalController;
  
  TreeGrowthLevel _currentLevel = TreeGrowthLevel.seedling;
  Season _currentSeason = Season.spring;
  int _totalCommunityCredits = 0;
  List<CommunityContribution> _recentContributions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCommunityData();
  }

  void _initializeAnimations() {
    _treeGrowthController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _seasonalController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
  }

  void _loadCommunityData() {
    // TODO: Load actual community data
    setState(() {
      _totalCommunityCredits = 2450; // Mock data
      _currentLevel = _calculateTreeLevel(_totalCommunityCredits);
      _currentSeason = _getCurrentSeason();
      _recentContributions = _getMockContributions();
    });
    
    _treeGrowthController.forward();
    _seasonalController.forward();
  }

  @override
  void dispose() {
    _treeGrowthController.dispose();
    _particleController.dispose();
    _seasonalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Tree'),
        backgroundColor: _getSeasonalColor(_currentSeason),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showTreeInfo,
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: _shareTreeScreenshot,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: _getSeasonalGradient(_currentSeason),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTreeHeader(),
              Expanded(
                child: Stack(
                  children: [
                    // Background seasonal decorations
                    SeasonalDecorations(
                      season: _currentSeason,
                      animationController: _seasonalController,
                    ),
                    
                    // Main tree
                    Center(
                      child: AnimatedCommunityTree(
                        level: _currentLevel,
                        season: _currentSeason,
                        growthController: _treeGrowthController,
                        particleController: _particleController,
                        onTreeTap: _onTreeTapped,
                      ),
                    ),
                    
                    // Progress indicator
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: TreeProgressIndicator(
                        currentCredits: _totalCommunityCredits,
                        currentLevel: _currentLevel,
                        nextLevelCredits: _getNextLevelCredits(_currentLevel),
                      ),
                    ),
                  ],
                ),
              ),
              _buildContributionsPanel(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showContributeDialog,
        backgroundColor: _getSeasonalColor(_currentSeason),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Contribute', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTreeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Community Tree',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getTreeLevelDescription(_currentLevel),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                'Total Credits',
                _totalCommunityCredits.toString(),
                Icons.stars,
                Colors.amber,
              ),
              _buildStatCard(
                'Tree Level',
                '${_currentLevel.index + 1}',
                Icons.park,
                Colors.green,
              ),
              _buildStatCard(
                'Season',
                _getSeasonName(_currentSeason),
                _getSeasonIcon(_currentSeason),
                _getSeasonalColor(_currentSeason),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionsPanel() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Recent Contributions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _recentContributions.length,
              itemBuilder: (context, index) {
                final contribution = _recentContributions[index];
                return _buildContributionCard(contribution);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionCard(CommunityContribution contribution) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getContributionTypeColor(contribution.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getContributionTypeColor(contribution.type).withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getContributionTypeIcon(contribution.type),
            color: _getContributionTypeColor(contribution.type),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            '+${contribution.credits}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getContributionTypeColor(contribution.type),
              fontSize: 12,
            ),
          ),
          Text(
            contribution.userName,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  TreeGrowthLevel _calculateTreeLevel(int credits) {
    if (credits < 500) return TreeGrowthLevel.seedling;
    if (credits < 1000) return TreeGrowthLevel.sapling;
    if (credits < 2000) return TreeGrowthLevel.youngTree;
    if (credits < 4000) return TreeGrowthLevel.matureTree;
    if (credits < 8000) return TreeGrowthLevel.ancientTree;
    return TreeGrowthLevel.mysticalTree;
  }

  int _getNextLevelCredits(TreeGrowthLevel level) {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return 500;
      case TreeGrowthLevel.sapling:
        return 1000;
      case TreeGrowthLevel.youngTree:
        return 2000;
      case TreeGrowthLevel.matureTree:
        return 4000;
      case TreeGrowthLevel.ancientTree:
        return 8000;
      case TreeGrowthLevel.mysticalTree:
        return 16000;
    }
  }

  String _getTreeLevelDescription(TreeGrowthLevel level) {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return 'A small seedling beginning to grow from community efforts';
      case TreeGrowthLevel.sapling:
        return 'Growing stronger with each contribution from roommates';
      case TreeGrowthLevel.youngTree:
        return 'A young tree flourishing from collaborative spirit';
      case TreeGrowthLevel.matureTree:
        return 'A mature tree providing shelter and unity';
      case TreeGrowthLevel.ancientTree:
        return 'An ancient tree, wise from countless shared experiences';
      case TreeGrowthLevel.mysticalTree:
        return 'A mystical tree radiating the power of perfect harmony';
    }
  }

  Season _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }

  String _getSeasonName(Season season) {
    switch (season) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.autumn:
        return 'Autumn';
      case Season.winter:
        return 'Winter';
    }
  }

  IconData _getSeasonIcon(Season season) {
    switch (season) {
      case Season.spring:
        return Icons.local_florist;
      case Season.summer:
        return Icons.wb_sunny;
      case Season.autumn:
        return Icons.eco;
      case Season.winter:
        return Icons.ac_unit;
    }
  }

  Color _getSeasonalColor(Season season) {
    switch (season) {
      case Season.spring:
        return Colors.green[600]!;
      case Season.summer:
        return Colors.orange[600]!;
      case Season.autumn:
        return Colors.brown[600]!;
      case Season.winter:
        return Colors.blue[600]!;
    }
  }

  LinearGradient _getSeasonalGradient(Season season) {
    switch (season) {
      case Season.spring:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green[300]!, Colors.green[100]!],
        );
      case Season.summer:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange[300]!, Colors.yellow[100]!],
        );
      case Season.autumn:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.brown[300]!, Colors.orange[100]!],
        );
      case Season.winter:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[300]!, Colors.blue[50]!],
        );
    }
  }

  Color _getContributionTypeColor(ContributionType type) {
    switch (type) {
      case ContributionType.task:
        return Colors.blue;
      case ContributionType.bill:
        return Colors.green;
      case ContributionType.vote:
        return Colors.purple;
      case ContributionType.investment:
        return Colors.amber;
      case ContributionType.community:
        return Colors.pink;
    }
  }

  IconData _getContributionTypeIcon(ContributionType type) {
    switch (type) {
      case ContributionType.task:
        return Icons.task_alt;
      case ContributionType.bill:
        return Icons.receipt;
      case ContributionType.vote:
        return Icons.how_to_vote;
      case ContributionType.investment:
        return Icons.trending_up;
      case ContributionType.community:
        return Icons.people;
    }
  }

  List<CommunityContribution> _getMockContributions() {
    return [
      CommunityContribution(
        userName: 'Alice',
        credits: 15,
        type: ContributionType.task,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityContribution(
        userName: 'Bob',
        credits: 25,
        type: ContributionType.bill,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      CommunityContribution(
        userName: 'Carol',
        credits: 10,
        type: ContributionType.vote,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      CommunityContribution(
        userName: 'Dave',
        credits: 30,
        type: ContributionType.investment,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  void _onTreeTapped() {
    // Add sparkle animation when tree is tapped
    _particleController.reset();
    _particleController.forward();
    
    // Show encouraging message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.park, color: Colors.white),
            const SizedBox(width: 8),
            Text('Your community tree is thriving! Keep contributing!'),
          ],
        ),
        backgroundColor: _getSeasonalColor(_currentSeason),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showTreeInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: _getSeasonalColor(_currentSeason)),
            const SizedBox(width: 8),
            const Text('Community Tree'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The Community Tree grows based on collective contributions from all roommates.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tree Growth Levels:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...TreeGrowthLevel.values.map((level) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.park, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('${level.name}: ${_getNextLevelCredits(level)} credits'),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              const Text(
                'Seasonal Changes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('The tree changes appearance with real-world seasons, creating a dynamic and engaging experience throughout the year.'),
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

  void _shareTreeScreenshot() {
    // TODO: Implement screenshot sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Screenshot sharing coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showContributeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contribute to Community Tree'),
        content: const Text(
          'Contribute to the community tree by:\n\n'
          '• Completing tasks\n'
          '• Paying bills on time\n'
          '• Participating in votes\n'
          '• Contributing to investments\n'
          '• Helping roommates\n\n'
          'Every action helps the tree grow!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}