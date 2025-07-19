import 'package:flutter/material.dart';
import '../../../../domain/entities/investment_group.dart';

class RentProgressWidget extends StatelessWidget {
  final InvestmentGroup group;
  final double monthlyRent;

  const RentProgressWidget({
    Key? key,
    required this.group,
    required this.monthlyRent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rentCoverage = group.getRentCoveragePercentage(monthlyRent);
    final isRentFree = rentCoverage >= 100;
    final monthsToRentFree = _calculateMonthsToRentFree();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isRentFree 
                ? [Colors.green[400]!, Colors.green[600]!]
                : [Colors.blue[400]!, Colors.blue[600]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isRentFree ? Icons.home : Icons.trending_up,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isRentFree ? 'Rent-Free Achieved!' : 'Rent-Free Progress',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Progress indicator
              _buildProgressIndicator(rentCoverage, isRentFree),
              
              const SizedBox(height: 16),
              
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Monthly Returns',
                      '\$${group.monthlyReturns.toStringAsFixed(0)}',
                      Icons.monetization_on,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Monthly Rent',
                      '\$${monthlyRent.toStringAsFixed(0)}',
                      Icons.home,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress text
              if (isRentFree)
                _buildRentFreeMessage()
              else
                _buildProgressMessage(rentCoverage, monthsToRentFree),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double rentCoverage, bool isRentFree) {
    final progress = (rentCoverage / 100).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${rentCoverage.toStringAsFixed(1)}% Covered',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRentFree)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withOpacity(0.3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRentFreeMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your investment returns now cover your monthly rent!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
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

  Widget _buildProgressMessage(double rentCoverage, int? monthsToRentFree) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Need \$${(monthlyRent - group.monthlyReturns).toStringAsFixed(0)} more monthly returns',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (monthsToRentFree != null) ...[
            const SizedBox(height: 4),
            Text(
              'Estimated ${monthsToRentFree} months to rent-free at current growth rate',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  int? _calculateMonthsToRentFree() {
    if (group.monthlyReturns >= monthlyRent) return 0;
    
    // Simple estimation based on current growth rate
    // This would need more sophisticated calculation in real implementation
    final monthlyGrowthRate = group.totalContributions > 0 
        ? (group.currentValue - group.totalContributions) / group.totalContributions / 12
        : 0.0;
    
    if (monthlyGrowthRate <= 0) return null;
    
    final neededReturns = monthlyRent - group.monthlyReturns;
    final neededCapital = neededReturns / monthlyGrowthRate;
    final monthlyContributions = group.totalContributions / 12; // Rough estimate
    
    if (monthlyContributions <= 0) return null;
    
    return (neededCapital / monthlyContributions).ceil();
  }
}

class RentProgressChart extends StatelessWidget {
  final List<InvestmentGroup> groups;
  final double monthlyRent;

  const RentProgressChart({
    Key? key,
    required this.groups,
    required this.monthlyRent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No investment groups to display'),
          ),
        ),
      );
    }

    final totalReturns = groups.fold<double>(0, (sum, group) => sum + group.monthlyReturns);
    final totalCoverage = (totalReturns / monthlyRent) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rent Coverage Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Overall progress
            _buildOverallProgress(totalCoverage, totalReturns),
            
            const SizedBox(height: 20),
            
            // Individual group contributions
            Text(
              'Group Contributions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            ...groups.map((group) => _buildGroupContribution(group, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(double totalCoverage, double totalReturns) {
    final progress = (totalCoverage / 100).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Coverage: ${totalCoverage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                '\$${totalReturns.toStringAsFixed(0)} / \$${monthlyRent.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              totalCoverage >= 100 ? Colors.green : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupContribution(InvestmentGroup group, BuildContext context) {
    final groupCoverage = group.getRentCoveragePercentage(monthlyRent);
    final contributionPercentage = monthlyRent > 0 ? (group.monthlyReturns / monthlyRent) * 100 : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${group.participantIds.length} members',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${group.monthlyReturns.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                '${contributionPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class IndividualROIWidget extends StatelessWidget {
  final InvestmentGroup group;
  final String userId;

  const IndividualROIWidget({
    Key? key,
    required this.group,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userContribution = group.getUserContribution(userId);
    final userROI = group.getUserROI(userId);
    final userShare = group.totalContributions > 0 
        ? (userContribution / group.totalContributions) * 100 
        : 0.0;
    final userMonthlyReturns = (group.monthlyReturns * userShare / 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Your Investment',
                    '\$${userContribution.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Your ROI',
                    '${userROI >= 0 ? '+' : ''}${userROI.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    userROI >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Monthly Returns',
                    '\$${userMonthlyReturns.toStringAsFixed(0)}',
                    Icons.monetization_on,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Group Share',
                    '${userShare.toStringAsFixed(1)}%',
                    Icons.pie_chart,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your monthly returns contribute to reducing your share of rent costs',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}