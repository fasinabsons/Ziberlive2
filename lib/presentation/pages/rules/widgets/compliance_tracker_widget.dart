import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/rule_compliance_service.dart';
import '../cubit/rule_compliance_cubit.dart';
import '../cubit/rule_compliance_state.dart';

class ComplianceTrackerWidget extends StatelessWidget {
  final String? ruleId;
  final bool showFullStats;

  const ComplianceTrackerWidget({
    Key? key,
    this.ruleId,
    this.showFullStats = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RuleComplianceCubit, RuleComplianceState>(
      builder: (context, state) {
        if (state is RuleComplianceLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is RuleComplianceLoaded) {
          return showFullStats 
              ? _buildFullStatsCard(context, state.stats)
              : _buildCompactCard(context, state.stats);
        }

        if (state is RuleComplianceError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Failed to load compliance data',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCompactCard(BuildContext context, RuleComplianceStats stats) {
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
                Icon(
                  Icons.shield_outlined,
                  color: _getComplianceColor(stats.complianceRate),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Rule Compliance',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(stats.complianceRate * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getComplianceColor(stats.complianceRate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: stats.complianceRate,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getComplianceColor(stats.complianceRate),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stats.consecutiveComplianceDays} day streak',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (stats.violationsCount > 0)
                  Text(
                    '${stats.violationsCount} violations',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullStatsCard(BuildContext context, RuleComplianceStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Compliance Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Overall compliance rate
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getComplianceColor(stats.complianceRate).withOpacity(0.2),
                    _getComplianceColor(stats.complianceRate).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getComplianceColor(stats.complianceRate).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${(stats.complianceRate * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getComplianceColor(stats.complianceRate),
                    ),
                  ),
                  const Text(
                    'Overall Compliance Rate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Current Streak',
                    '${stats.consecutiveComplianceDays} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Best Streak',
                    '${stats.longestComplianceStreak} days',
                    Icons.emoji_events,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Violations',
                    '${stats.violationsCount}',
                    Icons.warning,
                    stats.violationsCount == 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Rules Tracked',
                    '${stats.totalRulesTracked}',
                    Icons.rule,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Quick actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showQuickComplianceDialog(context),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Mark Compliant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/rule-compliance'),
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('View Details'),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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

  void _showQuickComplianceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _QuickComplianceDialog(),
    );
  }

  Color _getComplianceColor(double rate) {
    if (rate >= 0.9) return Colors.green;
    if (rate >= 0.7) return Colors.orange;
    return Colors.red;
  }
}

class _QuickComplianceDialog extends StatefulWidget {
  @override
  State<_QuickComplianceDialog> createState() => _QuickComplianceDialogState();
}

class _QuickComplianceDialogState extends State<_QuickComplianceDialog> {
  String? _selectedRuleId;
  
  final List<Map<String, String>> _rules = [
    {'id': 'quiet_hours', 'name': 'Quiet Hours'},
    {'id': 'common_area', 'name': 'Common Area Cleanliness'},
    {'id': 'guest_policy', 'name': 'Guest Policy'},
    {'id': 'smoking', 'name': 'No Smoking'},
    {'id': 'noise_level', 'name': 'Noise Level'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          const Text('Mark Rule Compliance'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Which rule did you follow today?'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRuleId,
            decoration: const InputDecoration(
              labelText: 'Select Rule',
              border: OutlineInputBorder(),
            ),
            items: _rules.map((rule) {
              return DropdownMenuItem(
                value: rule['id'],
                child: Text(rule['name']!),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedRuleId = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedRuleId != null ? () => _recordCompliance() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Mark Compliant'),
        ),
      ],
    );
  }

  void _recordCompliance() {
    if (_selectedRuleId != null) {
      context.read<RuleComplianceCubit>().recordCompliance(_selectedRuleId!, true);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rule compliance recorded!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}