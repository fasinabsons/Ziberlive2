import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/reward_coin_service.dart';
import 'cubit/reward_coins_cubit.dart';
import 'cubit/reward_coins_state.dart';
import 'widgets/coin_balance_card.dart';
import 'widgets/coin_transaction_card.dart';
import 'widgets/coin_earning_options.dart';

class RewardCoinsPage extends StatefulWidget {
  const RewardCoinsPage({Key? key}) : super(key: key);

  @override
  State<RewardCoinsPage> createState() => _RewardCoinsPageState();
}

class _RewardCoinsPageState extends State<RewardCoinsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<RewardCoinsCubit>().loadCoins();
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
        title: const Text('Reward Coins'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Balance', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Earn', icon: Icon(Icons.add_circle)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: BlocConsumer<RewardCoinsCubit, RewardCoinsState>(
        listener: (context, state) {
          if (state is RewardCoinsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CoinsEarned) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Earned ${state.amount} coins!'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () => _tabController.animateTo(0),
                ),
              ),
            );
          } else if (state is CoinsRedeemed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully redeemed ${state.coinCost} coins!'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBalanceTab(state),
              _buildEarnTab(state),
              _buildHistoryTab(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceTab(RewardCoinsState state) {
    if (state is RewardCoinsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is RewardCoinsLoaded) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoinBalanceCard(coins: state.coins),
            const SizedBox(height: 24),
            _buildRedemptionOptions(state.coins),
            const SizedBox(height: 24),
            _buildQuickStats(state.coins),
          ],
        ),
      );
    }

    return _buildErrorState();
  }

  Widget _buildEarnTab(RewardCoinsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earn More Coins',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CoinEarningOptions(
            onWatchAd: () => _watchAdForCoins(),
            onCompleteTask: () => _navigateToTasks(),
            onVote: () => _navigateToVoting(),
          ),
          const SizedBox(height: 24),
          _buildEarningTips(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(RewardCoinsState state) {
    if (state is RewardCoinsLoaded) {
      if (state.coins.transactions.isEmpty) {
        return _buildEmptyHistory();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.coins.transactions.length,
        itemBuilder: (context, index) {
          final transaction = state.coins.transactions[index];
          return CoinTransactionCard(transaction: transaction);
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildRedemptionOptions(RewardCoins coins) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Redeem Coins',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRedemptionOption(
              'Ad-Free Experience',
              '24 hours without ads',
              100,
              Icons.block,
              Colors.blue,
              coins.availableCoins >= 100,
              () => _redeemCoins(RedemptionType.adFreeExperience, 100),
            ),
            const SizedBox(height: 12),
            _buildRedemptionOption(
              'Lucky Draw Ticket',
              'Enter the lucky draw',
              50,
              Icons.casino,
              Colors.purple,
              coins.availableCoins >= 50,
              () => _redeemCoins(RedemptionType.luckyDrawTicket, 50),
            ),
            const SizedBox(height: 12),
            _buildRedemptionOption(
              'Premium Features',
              'Unlock premium features',
              200,
              Icons.star,
              Colors.amber,
              coins.availableCoins >= 200,
              () => _redeemCoins(RedemptionType.premiumFeatures, 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionOption(
    String title,
    String description,
    int cost,
    IconData icon,
    Color color,
    bool canAfford,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: canAfford ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: canAfford ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canAfford ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: canAfford ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: canAfford ? color : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: canAfford ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: canAfford ? Colors.grey[600] : Colors.grey,
                    ),
                  ),
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
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$cost',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (!canAfford)
                  Text(
                    'Not enough coins',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(RewardCoins coins) {
    final earnedToday = coins.transactions
        .where((t) => t.isEarned && _isToday(t.createdAt))
        .fold(0, (sum, t) => sum + t.amount);
    
    final spentThisWeek = coins.transactions
        .where((t) => !t.isEarned && _isThisWeek(t.createdAt))
        .fold(0, (sum, t) => sum + t.amount);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Earned Today',
                    '$earnedToday',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Spent This Week',
                    '$spentThisWeek',
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningTips() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Earning Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTip('Watch ads daily to earn 2 coins each time'),
            _buildTip('Complete tasks to earn 5-10 bonus coins'),
            _buildTip('Participate in voting to earn 3 coins per vote'),
            _buildTip('Maintain streaks for bonus coin rewards'),
            _buildTip('Check back daily for login bonuses'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transaction history',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start earning coins to see your history here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load coins',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<RewardCoinsCubit>().loadCoins(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _watchAdForCoins() {
    context.read<RewardCoinsCubit>().watchAdForCoins();
  }

  void _redeemCoins(RedemptionType type, int cost) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Text('Are you sure you want to redeem $cost coins?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RewardCoinsCubit>().redeemCoins(type, cost);
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  void _navigateToTasks() {
    Navigator.pushNamed(context, '/tasks');
  }

  void _navigateToVoting() {
    Navigator.pushNamed(context, '/voting');
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return date.isAfter(weekStart);
  }
}