import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/investment_group.dart';
import '../../../domain/entities/user.dart';
import '../../core/widgets/permission_widget.dart';
import 'cubit/investment_group_cubit.dart';
import 'cubit/investment_group_state.dart';

class InvestmentGroupDetailsPage extends StatefulWidget {
  final InvestmentGroup group;

  const InvestmentGroupDetailsPage({
    Key? key,
    required this.group,
  }) : super(key: key);

  @override
  State<InvestmentGroupDetailsPage> createState() => _InvestmentGroupDetailsPageState();
}

class _InvestmentGroupDetailsPageState extends State<InvestmentGroupDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: Text(widget.group.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Members', icon: Icon(Icons.people)),
            Tab(text: 'Investments', icon: Icon(Icons.business_center)),
            Tab(text: 'Performance', icon: Icon(Icons.trending_up)),
          ],
        ),
        actions: [
          PermissionWidget(
            requiredRole: UserRole.roommateAdmin,
            child: PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit Group'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'add_member',
                  child: ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Add Member'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'update_value',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Update Value'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete Group', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocListener<InvestmentGroupCubit, InvestmentGroupState>(
        listener: (context, state) {
          if (state is InvestmentGroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ContributionAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contribution added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MemberAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Member added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildMembersTab(),
            _buildInvestmentsTab(),
            _buildPerformanceTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildOverviewTab() {
    final rentCoverage = widget.group.getRentCoveragePercentage(1500); // TODO: Get actual rent
    const currentUserId = 'current_user'; // TODO: Get from context
    final userContribution = widget.group.getUserContribution(currentUserId);
    final userROI = widget.group.getUserROI(currentUserId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Pool',
                  '\$${widget.group.totalContributions.toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Current Value',
                  '\$${widget.group.currentValue.toStringAsFixed(0)}',
                  Icons.trending_up,
                  Colors.green,
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
                  '\$${widget.group.monthlyReturns.toStringAsFixed(0)}',
                  Icons.monetization_on,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Rent Coverage',
                  '${rentCoverage.toStringAsFixed(1)}%',
                  Icons.home,
                  rentCoverage >= 100 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Your Investment Section
          if (widget.group.participantIds.contains(currentUserId)) ...[
            Text(
              'Your Investment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Contribution',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '\$${userContribution.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
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
                                'Your ROI',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${userROI >= 0 ? '+' : ''}${userROI.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: userROI >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddContributionDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Contribution'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildActivityItem(
                    'Group created',
                    _formatDate(widget.group.createdAt),
                    Icons.group_add,
                    Colors.blue,
                  ),
                  if (widget.group.investments.isNotEmpty) ...[
                    const Divider(),
                    ...widget.group.investments.take(3).map((investment) =>
                      _buildActivityItem(
                        'Investment: ${investment.name}',
                        _formatDate(investment.investmentDate),
                        Icons.business_center,
                        _getInvestmentStatusColor(investment.status),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group Members (${widget.group.participantIds.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              PermissionWidget(
                requiredRole: UserRole.roommateAdmin,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddMemberDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Member'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.group.participantIds.map((userId) => _buildMemberCard(userId)),
        ],
      ),
    );
  }

  Widget _buildInvestmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Investments (${widget.group.investments.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: () => _showProposeInvestmentDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Propose'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.group.investments.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.business_center,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No investments yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Propose an investment to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            ...widget.group.investments.map((investment) => _buildInvestmentCard(investment)),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final totalROI = widget.group.totalContributions > 0 
        ? ((widget.group.currentValue - widget.group.totalContributions) / widget.group.totalContributions) * 100 
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total ROI',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${totalROI >= 0 ? '+' : ''}${totalROI.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: totalROI >= 0 ? Colors.green : Colors.red,
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
                              'Monthly Yield',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${widget.group.totalContributions > 0 ? ((widget.group.monthlyReturns / widget.group.totalContributions) * 100).toStringAsFixed(2) : '0.00'}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Member Performance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...widget.group.participantIds.map((userId) => _buildMemberPerformanceCard(userId)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(String userId) {
    final contribution = widget.group.getUserContribution(userId);
    final roi = widget.group.getUserROI(userId);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(userId.substring(0, 1).toUpperCase()), // TODO: Get user name
        ),
        title: Text('User $userId'), // TODO: Get user name
        subtitle: Text('Member since ${_formatDate(widget.group.createdAt)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${contribution.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: roi >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentCard(Investment investment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getInvestmentStatusColor(investment.status),
          child: Icon(
            _getInvestmentStatusIcon(investment.status),
            color: Colors.white,
          ),
        ),
        title: Text(investment.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(investment.description),
            const SizedBox(height: 4),
            Text(
              '${_getInvestmentTypeLabel(investment.type)} • \$${investment.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getInvestmentStatusLabel(investment.status),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getInvestmentStatusColor(investment.status),
              ),
            ),
            Text(
              '${investment.expectedReturn.toStringAsFixed(1)}% exp.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberPerformanceCard(String userId) {
    final contribution = widget.group.getUserContribution(userId);
    final roi = widget.group.getUserROI(userId);
    final share = widget.group.totalContributions > 0 
        ? (contribution / widget.group.totalContributions) * 100 
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(userId.substring(0, 1).toUpperCase()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User $userId', // TODO: Get user name
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${share.toStringAsFixed(1)}% of total pool',
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
                  '\$${contribution.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: roi >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0: // Overview
        return FloatingActionButton(
          onPressed: () => _showAddContributionDialog(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2: // Investments
        return FloatingActionButton(
          onPressed: () => _showProposeInvestmentDialog(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.business_center, color: Colors.white),
        );
      default:
        return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getInvestmentStatusColor(InvestmentStatus status) {
    switch (status) {
      case InvestmentStatus.proposed:
        return Colors.orange;
      case InvestmentStatus.approved:
        return Colors.blue;
      case InvestmentStatus.active:
        return Colors.green;
      case InvestmentStatus.completed:
        return Colors.purple;
      case InvestmentStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getInvestmentStatusIcon(InvestmentStatus status) {
    switch (status) {
      case InvestmentStatus.proposed:
        return Icons.pending;
      case InvestmentStatus.approved:
        return Icons.check;
      case InvestmentStatus.active:
        return Icons.trending_up;
      case InvestmentStatus.completed:
        return Icons.check_circle;
      case InvestmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getInvestmentStatusLabel(InvestmentStatus status) {
    switch (status) {
      case InvestmentStatus.proposed:
        return 'Proposed';
      case InvestmentStatus.approved:
        return 'Approved';
      case InvestmentStatus.active:
        return 'Active';
      case InvestmentStatus.completed:
        return 'Completed';
      case InvestmentStatus.cancelled:
        return 'Cancelled';
    }
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
        return 'Crypto';
      case InvestmentType.mutualFunds:
        return 'Mutual Funds';
      case InvestmentType.other:
        return 'Other';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _showEditGroupDialog();
        break;
      case 'add_member':
        _showAddMemberDialog();
        break;
      case 'update_value':
        _showUpdateValueDialog();
        break;
      case 'delete':
        _showDeleteConfirmationDialog();
        break;
    }
  }

  void _showAddContributionDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Amount (\$)',
                hintText: '100',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                context.read<InvestmentGroupCubit>().addContribution(
                  widget.group.id,
                  'current_user', // TODO: Get current user ID
                  amount,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    // TODO: Implement add member dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add member functionality coming soon')),
    );
  }

  void _showProposeInvestmentDialog() {
    // TODO: Implement propose investment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Propose investment functionality coming soon')),
    );
  }

  void _showEditGroupDialog() {
    // TODO: Implement edit group dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit group functionality coming soon')),
    );
  }

  void _showUpdateValueDialog() {
    final controller = TextEditingController(
      text: widget.group.currentValue.toStringAsFixed(0),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Group Value'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Current Value (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                context.read<InvestmentGroupCubit>().updateGroupValue(
                  widget.group.id,
                  value,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Investment Group'),
        content: Text(
          'Are you sure you want to delete "${widget.group.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<InvestmentGroupCubit>().deleteInvestmentGroup(widget.group.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to list
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}