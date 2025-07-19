import 'package:flutter/material.dart';
import 'cubit/lucky_draw_cubit.dart';

class PhysicalRewardsPage extends StatelessWidget {
  const PhysicalRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Physical Rewards Catalog'),
        backgroundColor: Colors.orange.shade50,
        foregroundColor: Colors.orange.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.amber.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 48,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ZiberLive Merchandise',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Win amazing prizes through our lucky draw system!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rewards catalog
            Text(
              'Available Rewards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            // Reward items
            ..._getAvailableRewards().map((reward) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RewardCard(reward: reward),
            )),
            
            const SizedBox(height: 24),
            
            // How to win section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How to Win Rewards',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildStep(
                    number: '1',
                    title: 'Earn Coins',
                    description: 'Complete tasks, vote on polls, or watch ads to earn coins',
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStep(
                    number: '2',
                    title: 'Buy Tickets',
                    description: 'Purchase lucky draw tickets for 50 coins each',
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStep(
                    number: '3',
                    title: 'Wait for Draw',
                    description: 'Participate in scheduled draws and cross your fingers!',
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStep(
                    number: '4',
                    title: 'Claim Prize',
                    description: 'If you win, we\'ll contact you for shipping details',
                    color: Colors.blue.shade600,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Shipping info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        color: Colors.green.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Shipping Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoItem(
                    icon: Icons.location_on,
                    title: 'Shipping Areas',
                    description: 'We ship worldwide with tracking',
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoItem(
                    icon: Icons.schedule,
                    title: 'Delivery Time',
                    description: '7-14 business days for most locations',
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoItem(
                    icon: Icons.money_off,
                    title: 'Shipping Cost',
                    description: 'FREE shipping for all prize winners!',
                    color: Colors.green.shade600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MockPhysicalReward> _getAvailableRewards() {
    return [
      MockPhysicalReward(
        id: 'tshirt_1',
        name: 'ZiberLive T-Shirt',
        description: 'Premium quality cotton t-shirt with ZiberLive logo. Available in multiple sizes and colors.',
        category: 'Apparel',
      ),
      MockPhysicalReward(
        id: 'hoodie_1',
        name: 'ZiberLive Hoodie',
        description: 'Comfortable pullover hoodie perfect for community events. Soft fleece interior.',
        category: 'Apparel',
      ),
      MockPhysicalReward(
        id: 'mug_1',
        name: 'ZiberLive Coffee Mug',
        description: 'Ceramic mug with ZiberLive branding. Microwave and dishwasher safe.',
        category: 'Drinkware',
      ),
      MockPhysicalReward(
        id: 'cap_1',
        name: 'ZiberLive Baseball Cap',
        description: 'Adjustable baseball cap with embroidered ZiberLive logo. One size fits all.',
        category: 'Apparel',
      ),
      MockPhysicalReward(
        id: 'bottle_1',
        name: 'ZiberLive Water Bottle',
        description: 'Stainless steel water bottle with ZiberLive design. Keeps drinks hot or cold.',
        category: 'Drinkware',
      ),
      MockPhysicalReward(
        id: 'sticker_1',
        name: 'ZiberLive Sticker Pack',
        description: 'Pack of 10 high-quality vinyl stickers with various ZiberLive designs.',
        category: 'Accessories',
      ),
    ];
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RewardCard extends StatelessWidget {
  final MockPhysicalReward reward;
  
  const RewardCard({
    super.key,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor().withOpacity(0.2),
                  _getCategoryColor().withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(),
              color: _getCategoryColor(),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reward.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getCategoryColor(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (reward.category.toLowerCase()) {
      case 'apparel':
        return Colors.purple;
      case 'drinkware':
        return Colors.blue;
      case 'accessories':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon() {
    switch (reward.category.toLowerCase()) {
      case 'apparel':
        return Icons.checkroom;
      case 'drinkware':
        return Icons.local_cafe;
      case 'accessories':
        return Icons.star;
      default:
        return Icons.redeem;
    }
  }
} 