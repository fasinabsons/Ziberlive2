import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/investment_group.dart';
import '../../../domain/entities/user.dart';
import 'cubit/investment_group_cubit.dart';

class CreateInvestmentGroupPage extends StatefulWidget {
  const CreateInvestmentGroupPage({Key? key}) : super(key: key);

  @override
  State<CreateInvestmentGroupPage> createState() => _CreateInvestmentGroupPageState();
}

class _CreateInvestmentGroupPageState extends State<CreateInvestmentGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final List<String> _selectedMembers = [];
  final List<User> _availableUsers = []; // TODO: Load from user repository
  
  bool _isAutoInvest = false;
  double _monthlyContribution = 100.0;
  double _targetAmount = 10000.0;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadAvailableUsers() {
    // TODO: Load users from repository
    // For now, using mock data
    setState(() {
      // _availableUsers = mockUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Investment Group'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveInvestmentGroup,
            child: const Text(
              'Create',
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
              _buildMemberSelectionSection(),
              const SizedBox(height: 24),
              _buildInvestmentSettingsSection(),
              const SizedBox(height: 24),
              _buildAutoInvestSection(),
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
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g., Apartment 4B Investment Club',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a group name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Describe the investment goals and strategy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Members',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Select roommates to invite to this investment group',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            if (_availableUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No roommates available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure other users are registered in your apartment',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _availableUsers.map((user) {
                  final isSelected = _selectedMembers.contains(user.id);
                  return CheckboxListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    secondary: CircleAvatar(
                      child: Text(user.name.substring(0, 1).toUpperCase()),
                    ),
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedMembers.add(user.id);
                        } else {
                          _selectedMembers.remove(user.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            if (_selectedMembers.isNotEmpty) ...[
              const Divider(),
              Text(
                '${_selectedMembers.length} members selected',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _targetAmount.toStringAsFixed(0),
              decoration: const InputDecoration(
                labelText: 'Target Amount (\$)',
                hintText: '10000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final amount = double.tryParse(value);
                if (amount != null) {
                  setState(() => _targetAmount = amount);
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Investment Goal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This group aims to collectively invest \$${_targetAmount.toStringAsFixed(0)} to generate monthly returns that can help cover rent and living expenses.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoInvestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auto-Investment (Optional)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Set up automatic monthly contributions for group members',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Auto-Investment'),
              subtitle: const Text('Members will be prompted to contribute monthly'),
              value: _isAutoInvest,
              onChanged: (value) {
                setState(() => _isAutoInvest = value);
              },
            ),
            if (_isAutoInvest) ...[
              const Divider(),
              TextFormField(
                initialValue: _monthlyContribution.toStringAsFixed(0),
                decoration: const InputDecoration(
                  labelText: 'Suggested Monthly Contribution (\$)',
                  hintText: '100',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  if (amount != null) {
                    setState(() => _monthlyContribution = amount);
                  }
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calculate, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Projected Timeline',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            _calculateProjectedTimeline(),
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _calculateProjectedTimeline() {
    if (_monthlyContribution <= 0 || _selectedMembers.isEmpty) {
      return 'Add members and set contribution amount';
    }
    
    final totalMonthlyContribution = _monthlyContribution * (_selectedMembers.length + 1); // +1 for current user
    final monthsToTarget = (_targetAmount / totalMonthlyContribution).ceil();
    
    if (monthsToTarget <= 12) {
      return 'Target reached in $monthsToTarget months';
    } else {
      final years = (monthsToTarget / 12).floor();
      final remainingMonths = monthsToTarget % 12;
      return 'Target reached in $years year${years > 1 ? 's' : ''} ${remainingMonths > 0 ? 'and $remainingMonths month${remainingMonths > 1 ? 's' : ''}' : ''}';
    }
  }

  void _saveInvestmentGroup() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one member for the group'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Add current user to the group
    final allMembers = [..._selectedMembers, 'current_user']; // TODO: Get current user ID

    final group = InvestmentGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      apartmentId: 'apartment_1', // TODO: Get from context
      participantIds: allMembers,
      contributions: {}, // Empty initially
      totalContributions: 0.0,
      currentValue: 0.0,
      monthlyReturns: 0.0,
      investments: [],
      createdAt: DateTime.now(),
    );

    context.read<InvestmentGroupCubit>().createInvestmentGroup(group);
    Navigator.of(context).pop();
  }
}