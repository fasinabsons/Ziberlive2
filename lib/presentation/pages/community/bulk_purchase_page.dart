import 'package:flutter/material.dart';

class BulkPurchasePage extends StatelessWidget {
  const BulkPurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Purchases'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
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
                  colors: [Colors.blue.shade100, Colors.cyan.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 48,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Group Purchases',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save money by coordinating bulk purchases with your community!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Current group purchases
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Group Purchases',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreatePurchaseDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Propose'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Group purchase cards
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GroupPurchaseCard(
                title: _getSampleTitles()[index],
                description: _getSampleDescriptions()[index],
                targetAmount: _getSampleTargets()[index],
                currentAmount: _getSampleCurrent()[index],
                participants: _getSampleParticipants()[index],
                timeLeft: _getSampleTimeLeft()[index],
                organizer: 'User ${index + 1}',
              ),
            )),
            
            const SizedBox(height: 24),
            
            // How it works section
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
                        Icons.help_outline,
                        color: Colors.green.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How Group Purchasing Works',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildStep(
                    number: '1',
                    title: 'Propose a Purchase',
                    description: 'Create a group purchase proposal with item details and minimum quantity',
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStep(
                    number: '2',
                    title: 'Community Joins',
                    description: 'Roommates can join the purchase and specify quantities they want',
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStep(
                    number: '3',
                    title: 'Reach Target',
                    description: 'Once minimum quantity is reached, the purchase moves forward',
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStep(
                    number: '4',
                    title: 'Split Costs',
                    description: 'Costs are automatically calculated and split based on quantities',
                    color: Colors.green.shade600,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Benefits section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.savings,
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Benefits of Group Purchasing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildBenefit(
                    icon: Icons.attach_money,
                    title: 'Save Money',
                    description: 'Get bulk discounts by purchasing larger quantities together',
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildBenefit(
                    icon: Icons.local_shipping,
                    title: 'Reduce Shipping',
                    description: 'Split shipping costs or qualify for free shipping thresholds',
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildBenefit(
                    icon: Icons.eco,
                    title: 'Eco-Friendly',
                    description: 'Reduce packaging waste and environmental impact',
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildBenefit(
                    icon: Icons.people,
                    title: 'Build Community',
                    description: 'Coordinate and collaborate with your roommates',
                    color: Colors.orange.shade600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getSampleTitles() {
    return [
      'Bulk Rice Purchase - 50lb bags',
      'Cleaning Supplies Bundle',
      'Toilet Paper Mega Pack',
    ];
  }

  List<String> _getSampleDescriptions() {
    return [
      'Premium basmati rice, 50lb bags. Great for meal prep and cooking!',
      'All-purpose cleaner, dish soap, and paper towels bulk purchase',
      '48-roll mega pack from Costco. Free delivery with this quantity!',
    ];
  }

  List<double> _getSampleTargets() {
    return [200.0, 150.0, 80.0];
  }

  List<double> _getSampleCurrent() {
    return [150.0, 90.0, 65.0];
  }

  List<int> _getSampleParticipants() {
    return [6, 4, 5];
  }

  List<String> _getSampleTimeLeft() {
    return ['3 days', '1 week', '5 days'];
  }

  void _showCreatePurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreatePurchaseDialog(),
    );
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

  Widget _buildBenefit({
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

class GroupPurchaseCard extends StatelessWidget {
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final int participants;
  final String timeLeft;
  final String organizer;
  
  const GroupPurchaseCard({
    super.key,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.participants,
    required this.timeLeft,
    required this.organizer,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentAmount / targetAmount;
    final isActive = progress < 1.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Complete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green.shade700 : Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress section
            Row(
              children: [
                Text(
                  'Progress:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isActive ? Colors.blue.shade600 : Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.blue.shade600 : Colors.green.shade600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Details row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target: \$${targetAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Current: \$${currentAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$participants participants',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Time left: $timeLeft',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                if (isActive) ...[
                  ElevatedButton(
                    onPressed: () {
                      _showJoinDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Join Purchase'),
                  ),
                  const SizedBox(width: 12),
                ],
                OutlinedButton(
                  onPressed: () {
                    _showDetailsDialog(context);
                  },
                  child: const Text('View Details'),
                ),
                const Spacer(),
                Text(
                  'by $organizer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join "$title"'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Quantity you want',
                border: OutlineInputBorder(),
                suffixText: 'units',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Successfully joined the group purchase!')),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 16),
            Text('Organized by: $organizer'),
            Text('Target amount: \$${targetAmount.toStringAsFixed(0)}'),
            Text('Current amount: \$${currentAmount.toStringAsFixed(0)}'),
            Text('Participants: $participants'),
            Text('Time remaining: $timeLeft'),
          ],
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
}

class CreatePurchaseDialog extends StatelessWidget {
  const CreatePurchaseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Propose Group Purchase'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Item/Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Target Amount (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Duration (days)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Group purchase proposal created!')),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
} 