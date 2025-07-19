import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/investment_group.dart';
import 'cubit/investment_group_cubit.dart';

class InvestmentProposalPage extends StatefulWidget {
  final String groupId;

  const InvestmentProposalPage({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<InvestmentProposalPage> createState() => _InvestmentProposalPageState();
}

class _InvestmentProposalPageState extends State<InvestmentProposalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _expectedReturnController = TextEditingController();
  
  InvestmentType _selectedType = InvestmentType.stocks;
  DateTime? _maturityDate;
  bool _hasMaturityDate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _expectedReturnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propose Investment'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _submitProposal,
            child: const Text(
              'Propose',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildInvestmentDetailsSection(),
              const SizedBox(height: 24),
              _buildRiskAndReturnSection(),
              const SizedBox(height: 24),
              _buildTimelineSection(),
              const SizedBox(height: 24),
              _buildProposalSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Investment Name',
                hintText: 'e.g., Tech Stock Portfolio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_center),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an investment name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the investment opportunity and strategy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Type & Amount',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InvestmentType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Investment Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: InvestmentType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getInvestmentTypeIcon(type)),
                      const SizedBox(width: 8),
                      Text(_getInvestmentTypeLabel(type)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Investment Amount (\$)',
                hintText: '1000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAndReturnSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expected Returns',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expectedReturnController,
              decoration: const InputDecoration(
                labelText: 'Expected Annual Return (%)',
                hintText: '8.5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.trending_up),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter expected return';
                }
                final returnRate = double.tryParse(value);
                if (returnRate == null) {
                  return 'Please enter a valid percentage';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Risk Disclaimer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                        Text(
                          'All investments carry risk. Past performance does not guarantee future results.',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  Widget _buildTimelineSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Timeline',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Set Maturity Date'),
              subtitle: const Text('When should this investment be reviewed or liquidated?'),
              value: _hasMaturityDate,
              onChanged: (value) {
                setState(() {
                  _hasMaturityDate = value;
                  if (!value) _maturityDate = null;
                });
              },
            ),
            if (_hasMaturityDate) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Maturity Date'),
                subtitle: Text(_maturityDate != null 
                    ? _formatDate(_maturityDate!) 
                    : 'Select maturity date'),
                onTap: () => _selectMaturityDate(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProposalSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final expectedReturn = double.tryParse(_expectedReturnController.text) ?? 0.0;
    final monthlyReturn = amount * (expectedReturn / 100) / 12;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proposal Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Investment',
                    '\$${amount.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Expected Monthly',
                    '\$${monthlyReturn.toStringAsFixed(0)}',
                    Icons.monetization_on,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Annual Return',
                    '${expectedReturn.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Type',
                    _getInvestmentTypeLabel(_selectedType),
                    _getInvestmentTypeIcon(_selectedType),
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This proposal will be sent to all group members for voting. A majority approval is required to proceed.',
                      style: TextStyle(
                        color: Colors.blue[700],
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

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getInvestmentTypeLabel(InvestmentType type) {
    switch (type) {
      case InvestmentType.stocks:
        return 'Stocks';
      case InvestmentType.bonds:
        return 'Bonds';
      case InvestmentType.realEstate:
        return 'Real Estate';
      case InvestmentType.crypto:
        return 'Cryptocurrency';
      case InvestmentType.mutualFunds:
        return 'Mutual Funds';
      case InvestmentType.other:
        return 'Other';
    }
  }

  IconData _getInvestmentTypeIcon(InvestmentType type) {
    switch (type) {
      case InvestmentType.stocks:
        return Icons.show_chart;
      case InvestmentType.bonds:
        return Icons.account_balance;
      case InvestmentType.realEstate:
        return Icons.home;
      case InvestmentType.crypto:
        return Icons.currency_bitcoin;
      case InvestmentType.mutualFunds:
        return Icons.pie_chart;
      case InvestmentType.other:
        return Icons.business_center;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectMaturityDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _maturityDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date != null) {
      setState(() => _maturityDate = date);
    }
  }

  void _submitProposal() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final expectedReturn = double.parse(_expectedReturnController.text);

    final investment = Investment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: amount,
      type: _selectedType,
      expectedReturn: expectedReturn,
      status: InvestmentStatus.proposed,
      investmentDate: DateTime.now(),
      maturityDate: _maturityDate,
      proposedBy: 'current_user', // TODO: Get current user ID
    );

    context.read<InvestmentGroupCubit>().proposeInvestment(widget.groupId, investment);
    Navigator.of(context).pop();
  }
}