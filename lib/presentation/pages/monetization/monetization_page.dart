import 'package:flutter/material.dart';

class MonetizationPage extends StatelessWidget {
  const MonetizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Features'),
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.purple.shade800,
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
                  colors: [Colors.purple.shade100, Colors.indigo.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.star,
                    size: 48,
                    color: Colors.purple.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ZiberLive Premium',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock premium features and enhance your community experience!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.purple.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Current Balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Coin Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          '250 Coins',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showTopUpDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange.shade600,
                    ),
                    child: const Text('Top Up'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Premium Features
            Text(
              'Premium Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            // Ad-Free Experience
            PremiumFeatureCard(
              icon: Icons.block,
              title: 'Ad-Free Experience',
              description: 'Remove all banner ads for 24 hours',
              price: '100 coins',
              duration: '24 hours',
              color: Colors.indigo,
              onPurchase: () => _purchaseAdFree(context),
            ),
            
            const SizedBox(height: 12),
            
            // Cloud Storage
            PremiumFeatureCard(
              icon: Icons.cloud,
              title: 'Cloud Storage Access',
              description: 'Backup and sync your data across devices',
              price: '400 coins',
              duration: '1 month',
              color: Colors.blue,
              onPurchase: () => _purchaseCloudStorage(context),
            ),
            
            const SizedBox(height: 12),
            
            // Priority Support
            PremiumFeatureCard(
              icon: Icons.support_agent,
              title: 'Priority Support',
              description: 'Get faster response times for support requests',
              price: '200 coins',
              duration: '1 month',
              color: Colors.green,
              onPurchase: () => _purchasePrioritySupport(context),
            ),
            
            const SizedBox(height: 24),
            
            // Coin Packages
            Text(
              'Coin Packages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: CoinPackageCard(
                    coins: 100,
                    price: '\$1.00',
                    isPopular: false,
                    onPurchase: () => _purchaseCoins(context, 100, 1.00),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CoinPackageCard(
                    coins: 500,
                    price: '\$4.00',
                    isPopular: true,
                    bonus: 100,
                    onPurchase: () => _purchaseCoins(context, 500, 4.00),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: CoinPackageCard(
                    coins: 1000,
                    price: '\$7.00',
                    isPopular: false,
                    bonus: 300,
                    onPurchase: () => _purchaseCoins(context, 1000, 7.00),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CoinPackageCard(
                    coins: 2500,
                    price: '\$15.00',
                    isPopular: false,
                    bonus: 1000,
                    onPurchase: () => _purchaseCoins(context, 2500, 15.00),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Ways to Earn Coins
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
                        Icons.lightbulb,
                        color: Colors.green.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Free Ways to Earn Coins',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildEarnMethod(
                    icon: Icons.task_alt,
                    title: 'Complete Tasks',
                    description: 'Earn 10-50 coins per completed task',
                    coins: '10-50',
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildEarnMethod(
                    icon: Icons.how_to_vote,
                    title: 'Vote on Polls',
                    description: 'Get 5 coins for each vote you cast',
                    coins: '5',
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildEarnMethod(
                    icon: Icons.ads_click,
                    title: 'Watch Ads',
                    description: 'Earn 2-10 coins per ad watched',
                    coins: '2-10',
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildEarnMethod(
                    icon: Icons.emoji_events,
                    title: 'Win Lucky Draws',
                    description: 'Prize winners get bonus coins',
                    coins: '50-200',
                    color: Colors.green.shade600,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Terms and Support
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    'Support ZiberLive',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your purchases help us maintain and improve the ZiberLive platform for everyone. All transactions are secure and processed through trusted payment providers.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _showTermsDialog(context),
                        child: const Text('Terms & Conditions'),
                      ),
                      const Text(' • '),
                      TextButton(
                        onPressed: () => _showSupportDialog(context),
                        child: const Text('Support'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top Up Coins'),
        content: const Text('Choose a coin package to purchase from the options below.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _purchaseAdFree(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Ad-Free Experience'),
        content: const Text('Remove all ads for 24 hours for 100 coins?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ad-free experience activated!')),
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _purchaseCloudStorage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Cloud Storage'),
        content: const Text('Get 1 month of cloud storage access for 400 coins?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cloud storage access activated!')),
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _purchasePrioritySupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Priority Support'),
        content: const Text('Get priority support for 1 month for 200 coins?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Priority support activated!')),
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _purchaseCoins(BuildContext context, int coins, double price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Coins'),
        content: Text('Purchase $coins coins for \$${price.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$coins coins added to your account!')),
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'ZiberLive Premium Terms:\n\n'
            '• All purchases are final and non-refundable\n'
            '• Premium features are account-specific\n'
            '• Ad-free experience lasts for specified duration\n'
            '• Cloud storage includes 1GB of backup space\n'
            '• Priority support guarantees response within 24 hours\n'
            '• Coin balances do not expire\n'
            '• Features may be modified or discontinued with notice\n\n'
            'By purchasing, you agree to these terms.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support'),
        content: const Text(
          'Need help with purchases or premium features?\n\n'
          'Contact us at: support@ziberlive.com\n'
          'Or use the in-app support chat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnMethod({
    required IconData icon,
    required String title,
    required String description,
    required String coins,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '+$coins',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
          ),
        ),
      ],
    );
  }
}

class PremiumFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String price;
  final String duration;
  final Color color;
  final VoidCallback onPurchase;
  
  const PremiumFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.color,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
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
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Buy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CoinPackageCard extends StatelessWidget {
  final int coins;
  final String price;
  final bool isPopular;
  final int? bonus;
  final VoidCallback onPurchase;
  
  const CoinPackageCard({
    super.key,
    required this.coins,
    required this.price,
    required this.isPopular,
    this.bonus,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular ? Colors.orange.shade400 : Colors.grey.shade300,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPopular ? Colors.orange : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          Icon(
            Icons.monetization_on,
            color: isPopular ? Colors.orange.shade600 : Colors.grey.shade600,
            size: 32,
          ),
          const SizedBox(height: 8),
          
          Text(
            '$coins',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPopular ? Colors.orange.shade600 : Colors.grey.shade700,
            ),
          ),
          const Text(
            'Coins',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          
          if (bonus != null) ...[
            const SizedBox(height: 4),
            Text(
              '+$bonus bonus',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          Text(
            price,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPopular ? Colors.orange.shade600 : Colors.grey.shade700,
            ),
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? Colors.orange.shade600 : Colors.grey.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Buy'),
            ),
          ),
        ],
      ),
    );
  }
} 