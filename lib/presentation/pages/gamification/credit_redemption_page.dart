import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/gamification.dart';
import '../../../core/services/gamification_service.dart';
import 'cubit/credit_redemption_cubit.dart';
import 'cubit/credit_redemption_state.dart';

class CreditRedemptionPage extends StatefulWidget {
  const CreditRedemptionPage({Key? key}) : super(key: key);

  @override
  State<CreditRedemptionPage> createState() => _CreditRedemptionPageState();
}

class _CreditRedemptionPageState extends State<CreditRedemptionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userCredits = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserCredits();
  }

  void _loadUserCredits() {
    // TODO: Load actual user credits
    setState(() {
      _userCredits = 250; // Mock data
    });
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
        title: const Text('Credit Redemption'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Premium', icon: Icon(Icons.star)),
            Tab(text: 'Services', icon: Icon(Icons.cloud)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildCreditsHeader(),
          Expanded(
            child: BlocConsumer<CreditRedemptionCubit, CreditRedemptionState>(
              listener: (context, state) {
                if (state is RedemptionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully redeemed: ${state.itemName}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadUserCredits(); // Refresh credits
                } else if (state is RedemptionError) {
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
                    _buildPremiumTab(state),
                    _buildServicesTab(state),
                    _buildHistoryTab(state),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[400]!, Colors.amber[600]!],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.stars,
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
                  'Available Credits',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$_userCredits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '1 credit = \$0.01',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTab(CreditRedemptionState state) {
    final premiumItems = [
      RedemptionItem(
        id: 'ad_removal_24h',
        name: '24-Hour Ad Removal',
        description: 'Enjoy an ad-free experience for 24 hours',
        creditsRequired: 100,
        category: RedemptionCategory.premium,
        icon: Icons.block,
        color: Colors.red,
        benefits: [
          'No banner ads during sync',
          'No interstitial ads',
          'Faster app experience',
          'Premium user badge',
        ],
      ),
      RedemptionItem(
        id: 'ad_removal_week',
        name: '7-Day Ad Removal',
        description: 'One week of premium ad-free experience',
        creditsRequired: 600,
        category: RedemptionCategory.premium,
        icon: Icons.block,
        color: Colors.red,
        benefits: [
          'All 24-hour benefits',
          'Extended premium period',
          'Priority customer support',
          'Beta feature access',
        ],
        discount: 100, // Save 100 credits vs daily
      ),
      RedemptionItem(
        id: 'premium_theme',
        name: 'Premium Themes',
        description: 'Unlock exclusive app themes and customizations',
        creditsRequired: 200,
        category: RedemptionCategory.premium,
        icon: Icons.palette,
        color: Colors.purple,
        benefits: [
          'Exclusive color schemes',
          'Custom app icons',
          'Animated backgrounds',
          'Seasonal themes',
        ],
      ),
    ];

    return _buildRedemptionGrid(premiumItems, state);
  }

  Widget _buildServicesTab(CreditRedemptionState state) {
    final serviceItems = [
      RedemptionItem(
        id: 'cloud_storage_month',
        name: 'Cloud Storage (1 Month)',
        description: 'Secure cloud backup and sync for 30 days',
        creditsRequired: 400,
        category: RedemptionCategory.service,
        icon: Icons.cloud,
        color: Colors.blue,
        benefits: [
          'Automatic data backup',
          'Cross-device sync',
          '10GB storage space',
          'Data recovery support',
        ],
      ),
      RedemptionItem(
        id: 'priority_support',
        name: 'Priority Support',
        description: 'Get priority customer support for 30 days',
        creditsRequired: 150,
        category: RedemptionCategory.service,
        icon: Icons.support_agent,
        color: Colors.green,
        benefits: [
          'Faster response times',
          'Direct developer access',
          'Feature request priority',
          'Bug fix priority',
        ],
      ),
      RedemptionItem(
        id: 'data_export',
        name: 'Data Export Service',
        description: 'Export all your data in multiple formats',
        creditsRequired: 50,
        category: RedemptionCategory.service,
        icon: Icons.download,
        color: Colors.orange,
        benefits: [
          'CSV export',
          'JSON export',
          'PDF reports',
          'Email delivery',
        ],
      ),
      RedemptionItem(
        id: 'custom_notifications',
        name: 'Custom Notifications',
        description: 'Personalized notification settings and sounds',
        creditsRequired: 75,
        category: RedemptionCategory.service,
        icon: Icons.notifications_active,
        color: Colors.teal,
        benefits: [
          'Custom notification sounds',
          'Advanced scheduling',
          'Smart reminders',
          'Notification analytics',
        ],
      ),
    ];

    return _buildRedemptionGrid(serviceItems, state);
  }

  Widget _buildHistoryTab(CreditRedemptionState state) {
    // Mock redemption history
    final history = [
      RedemptionHistory(
        id: '1',
        itemName: '24-Hour Ad Removal',
        creditsSpent: 100,
        redeemedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: RedemptionStatus.active,
        expiresAt: DateTime.now().add(const Duration(hours: 22)),
      ),
      RedemptionHistory(
        id: '2',
        itemName: 'Cloud Storage (1 Month)',
        creditsSpent: 400,
        redeemedAt: DateTime.now().subtract(const Duration(days: 15)),
        status: RedemptionStatus.expired,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RedemptionHistory(
        id: '3',
        itemName: 'Data Export Service',
        creditsSpent: 50,
        redeemedAt: DateTime.now().subtract(const Duration(days: 30)),
        status: RedemptionStatus.completed,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return _buildHistoryCard(item);
      },
    );
  }

  Widget _buildRedemptionGrid(List<RedemptionItem> items, CreditRedemptionState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 2.5,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildRedemptionCard(item, state);
      },
    );
  }

  Widget _buildRedemptionCard(RedemptionItem item, CreditRedemptionState state) {
    final canAfford = _userCredits >= item.creditsRequired;
    final isLoading = state is RedemptionLoading;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item.color.withOpacity(0.1),
              item.color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (item.discount != null) ...[
                        Text(
                          '${item.creditsRequired + item.discount!}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          'Save ${item.discount}!',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${item.creditsRequired}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: canAfford ? item.color : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Benefits
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: item.benefits.take(2).map((benefit) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 10,
                      color: item.color,
                    ),
                  ),
                )).toList(),
              ),
              
              const Spacer(),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canAfford && !isLoading
                          ? () => _showRedemptionDialog(item)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford ? item.color : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(canAfford ? 'Redeem' : 'Insufficient Credits'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showItemDetails(item),
                    icon: Icon(Icons.info_outline, color: item.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(RedemptionHistory item) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (item.status) {
      case RedemptionStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Active';
        break;
      case RedemptionStatus.expired:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Expired';
        break;
      case RedemptionStatus.completed:
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        statusText = 'Completed';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(item.itemName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Redeemed: ${_formatDate(item.redeemedAt)}'),
            if (item.expiresAt != null)
              Text(
                item.status == RedemptionStatus.active
                    ? 'Expires: ${_formatDate(item.expiresAt!)}'
                    : 'Expired: ${_formatDate(item.expiresAt!)}',
                style: TextStyle(
                  color: item.status == RedemptionStatus.active
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '-${item.creditsSpent} credits',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedemptionDialog(RedemptionItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(item.icon, color: item.color),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 16),
            const Text(
              'Benefits:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...item.benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(benefit)),
                ],
              ),
            )),
            const SizedBox(height: 16),
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
                    'Cost: ${item.creditsRequired} credits',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CreditRedemptionCubit>().redeemItem(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: item.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Redemption'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(RedemptionItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description),
              const SizedBox(height: 16),
              const Text(
                'All Benefits:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...item.benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.star, color: item.color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              )),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Supporting classes
enum RedemptionCategory { premium, service }
enum RedemptionStatus { active, expired, completed }

class RedemptionItem {
  final String id;
  final String name;
  final String description;
  final int creditsRequired;
  final RedemptionCategory category;
  final IconData icon;
  final Color color;
  final List<String> benefits;
  final int? discount;

  RedemptionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.creditsRequired,
    required this.category,
    required this.icon,
    required this.color,
    required this.benefits,
    this.discount,
  });
}

class RedemptionHistory {
  final String id;
  final String itemName;
  final int creditsSpent;
  final DateTime redeemedAt;
  final RedemptionStatus status;
  final DateTime? expiresAt;

  RedemptionHistory({
    required this.id,
    required this.itemName,
    required this.creditsSpent,
    required this.redeemedAt,
    required this.status,
    this.expiresAt,
  });
}