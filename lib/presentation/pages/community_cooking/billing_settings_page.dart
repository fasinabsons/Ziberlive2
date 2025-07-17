import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/community_cooking_billing_service.dart';
import '../../core/theme/app_theme.dart';

class BillingSettingsPage extends StatefulWidget {
  const BillingSettingsPage({super.key});

  @override
  State<BillingSettingsPage> createState() => _BillingSettingsPageState();
}

class _BillingSettingsPageState extends State<BillingSettingsPage> {
  BillingMode _selectedMode = BillingMode.fixed;
  double _fixedRate = 100.0;
  bool _creditExcess = true;
  double _creditConversionRate = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showBillingHelp(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Billing mode selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.payment,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Billing Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<BillingMode>(
                    title: const Text('Fixed Billing'),
                    subtitle: const Text('Each user pays a fixed amount per week'),
                    value: BillingMode.fixed,
                    groupValue: _selectedMode,
                    onChanged: (value) {
                      setState(() {
                        _selectedMode = value!;
                      });
                    },
                  ),
                  RadioListTile<BillingMode>(
                    title: const Text('Variable Billing'),
                    subtitle: const Text('Users split the actual grocery costs'),
                    value: BillingMode.variable,
                    groupValue: _selectedMode,
                    onChanged: (value) {
                      setState(() {
                        _selectedMode = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Fixed rate configuration (only for fixed mode)
          if (_selectedMode == BillingMode.fixed) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fixed Rate Configuration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _fixedRate.toStringAsFixed(0),
                      decoration: const InputDecoration(
                        labelText: 'Fixed Rate per User',
                        prefixText: '\$',
                        suffix: Text('per week'),
                        border: OutlineInputBorder(),
                        helperText: 'Amount each user pays regardless of actual spending',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      onChanged: (value) {
                        _fixedRate = double.tryParse(value) ?? 100.0;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Credit Excess as Co-Living Credits'),
                      subtitle: const Text(
                        'When spending is less than fixed rate, credit the difference',
                      ),
                      value: _creditExcess,
                      onChanged: (value) {
                        setState(() {
                          _creditExcess = value;
                        });
                      },
                    ),
                    if (_creditExcess) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _creditConversionRate.toStringAsFixed(0),
                        decoration: const InputDecoration(
                          labelText: 'Credit Conversion Rate',
                          suffix: Text('credits per \$1'),
                          border: OutlineInputBorder(),
                          helperText: 'How many credits equal \$1 of excess',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          _creditConversionRate = double.tryParse(value) ?? 100.0;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Billing preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Billing Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBillingPreview(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mode comparison
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Mode Comparison',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _showDetailedComparison(context),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildComparisonSummary(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Save button
          ElevatedButton(
            onPressed: _saveBillingSettings,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save Billing Settings',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingPreview() {
    // Sample data for preview
    const sampleUsers = 4;
    const sampleSpending = 320.0;
    
    if (_selectedMode == BillingMode.fixed) {
      final totalCharged = _fixedRate * sampleUsers;
      final excess = totalCharged - sampleSpending;
      final creditsPerUser = _creditExcess && excess > 0 
          ? (excess / sampleUsers * _creditConversionRate).round()
          : 0;
      
      return Column(
        children: [
          _buildPreviewRow('Sample Users', '$sampleUsers users'),
          _buildPreviewRow('Weekly Spending', '\$${sampleSpending.toStringAsFixed(2)}'),
          _buildPreviewRow('Fixed Rate per User', '\$${_fixedRate.toStringAsFixed(2)}'),
          _buildPreviewRow('Total Charged', '\$${totalCharged.toStringAsFixed(2)}'),
          if (excess > 0) ...[
            _buildPreviewRow('Excess Amount', '\$${excess.toStringAsFixed(2)}', 
                color: AppTheme.paidGreen),
            if (_creditExcess)
              _buildPreviewRow('Credits per User', '$creditsPerUser credits', 
                  color: AppTheme.primaryGreen),
          ] else if (excess < 0) ...[
            _buildPreviewRow('Shortfall', '\$${(-excess).toStringAsFixed(2)}', 
                color: AppTheme.unpaidRed),
          ],
        ],
      );
    } else {
      final costPerUser = sampleSpending / sampleUsers;
      
      return Column(
        children: [
          _buildPreviewRow('Sample Users', '$sampleUsers users'),
          _buildPreviewRow('Weekly Spending', '\$${sampleSpending.toStringAsFixed(2)}'),
          _buildPreviewRow('Cost per User', '\$${costPerUser.toStringAsFixed(2)}'),
          _buildPreviewRow('Total Charged', '\$${sampleSpending.toStringAsFixed(2)}'),
        ],
      );
    }
  }

  Widget _buildPreviewRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSummary() {
    // Sample comparison data
    const sampleSpending = 320.0;
    const sampleUsers = 4;
    
    final fixedTotal = _fixedRate * sampleUsers;
    final variableTotal = sampleSpending;
    final difference = (fixedTotal - variableTotal).abs();
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedMode == BillingMode.fixed 
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedMode == BillingMode.fixed 
                        ? AppTheme.primaryGreen
                        : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Fixed Mode',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${fixedTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _selectedMode == BillingMode.fixed 
                            ? AppTheme.primaryGreen
                            : null,
                      ),
                    ),
                    const Text(
                      'total charged',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedMode == BillingMode.variable 
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedMode == BillingMode.variable 
                        ? AppTheme.primaryGreen
                        : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Variable Mode',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${variableTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _selectedMode == BillingMode.variable 
                            ? AppTheme.primaryGreen
                            : null,
                      ),
                    ),
                    const Text(
                      'actual cost',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.warningOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            fixedTotal > variableTotal
                ? 'Fixed mode costs \$${difference.toStringAsFixed(2)} more'
                : fixedTotal < variableTotal
                    ? 'Fixed mode saves \$${difference.toStringAsFixed(2)}'
                    : 'Both modes cost the same',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.warningOrange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showBillingHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Billing Modes Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fixed Billing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '• Each user pays the same amount every week\n'
                '• Predictable budgeting for users\n'
                '• Excess money can be credited as Co-Living Credits\n'
                '• Good when spending is consistent',
              ),
              SizedBox(height: 16),
              Text(
                'Variable Billing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '• Users split the actual grocery costs\n'
                '• Pay only what was actually spent\n'
                '• Costs vary week to week\n'
                '• Good when spending fluctuates significantly',
              ),
              SizedBox(height: 16),
              Text(
                'Co-Living Credits',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '• Earned when fixed billing has excess\n'
                '• Can be used for ad removal and premium features\n'
                '• Default: 100 credits = \$1',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showDetailedComparison(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detailed Comparison'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Based on sample data (4 users, \$320 weekly spending):',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildDetailedComparisonTable(),
            ],
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

  Widget _buildDetailedComparisonTable() {
    const sampleSpending = 320.0;
    const sampleUsers = 4;
    
    final fixedTotal = _fixedRate * sampleUsers;
    final fixedExcess = fixedTotal - sampleSpending;
    final fixedCreditsPerUser = _creditExcess && fixedExcess > 0 
        ? (fixedExcess / sampleUsers * _creditConversionRate).round()
        : 0;
    
    final variableCostPerUser = sampleSpending / sampleUsers;
    
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Colors.grey),
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('Fixed Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('Variable Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Cost per User'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('\$${_fixedRate.toStringAsFixed(2)}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('\$${variableCostPerUser.toStringAsFixed(2)}'),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Total Charged'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('\$${fixedTotal.toStringAsFixed(2)}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('\$${sampleSpending.toStringAsFixed(2)}'),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Credits per User'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('$fixedCreditsPerUser credits'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('0 credits'),
            ),
          ],
        ),
      ],
    );
  }

  void _saveBillingSettings() {
    final config = CommunityBillingConfig(
      mode: _selectedMode,
      fixedRate: _fixedRate,
      creditExcessAsCoLivingCredits: _creditExcess,
      creditConversionRate: _creditConversionRate,
    );
    
    // TODO: Save configuration through BLoC
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Billing settings saved successfully'),
        backgroundColor: AppTheme.paidGreen,
      ),
    );
    
    Navigator.pop(context);
  }
}