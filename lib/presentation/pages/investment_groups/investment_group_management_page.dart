import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/investment_group.dart';
import '../../../domain/entities/user.dart';
import '../../core/widgets/permission_widget.dart';
import 'cubit/investment_group_cubit.dart';
import 'cubit/investment_group_state.dart';
import 'create_investment_group_page.dart';
import 'investment_group_details_page.dart';

class InvestmentGroupManagementPage extends StatefulWidget {
  const InvestmentGroupManagementPage({Key? key}) : super(key: key);

  @override
  State<InvestmentGroupManagementPage> createState() => _InvestmentGroupManagementPageState();
}

class _InvestmentGroupManagementPageState extends State<InvestmentGroupManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<InvestmentGroupCubit>().loadInvestmentGroups();
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
        title: const Text('Investment Groups'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'My Groups', icon: Icon(Icons.group)),
            Tab(text: 'All Groups', icon: Icon(Icons.groups)),
            Tab(text: 'Performance', icon: Icon(Icons.trending_up)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<InvestmentGroupCubit>().loadInvestmentGroups(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<InvestmentGroupCubit, InvestmentGroupState>(
        listener: (context, state) {
          if (state is InvestmentGroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is InvestmentGroupCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Investment group created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<InvestmentGroupCubit>().loadInvestmentGroups();
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMyGroupsTab(state),
              _buildAllGroupsTab(state),
              _buildPerformanceTab(state),
            ],
          );
        },
      ),
      floatingActionButton: PermissionWidget(
        requiredRole: UserRole.roommateAdmin,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateInvestmentGroupPage(),
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMyGroupsTab(InvestmentGroupState state) {
    if (state is InvestmentGroupLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is InvestmentGroupsLoaded) {
      // TODO: Get current user ID from context
      const currentUserId = 'current_user';
      final myGroups = state.groups
          .where((group) => group.participantIds.contains(currentUserId))
          .toList();
      return _buildGroupList(myGroups, isMyGroups: true);
    }
    
    return const Center(
      child: Text('No investment groups available'),
    );
  }

  Widget _buildAllGroupsTab(InvestmentGroupState state) {
    if (state is InvestmentGroupLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is InvestmentGroupsLoaded) {
      return _buildGroupList(state.groups);
    }
    
    return const Center(
      child: Text('No investment groups available'),
    );
  }

  Widget _buildPerformanceTab(InvestmentGroupState state) {
    if (state is InvestmentGroupsLoaded) {
      return _buildPerformanceOverview(state.groups);
    }
    
    return const Center(
      child: Text('No performance data available'),
    );
  }

  Widget _buildGroupList(List<InvestmentGroup> groups, {bool isMyGroups = false}) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMyGroups ? Icons.group : Icons.groups,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isMyGroups ? 'You are not part of any investment groups' : 'No investment groups found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (isMyGroups) ...[
              const SizedBox(height: 8),
              Text(
                'Ask your admin to add you to a group or create a new one',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<InvestmentGroupCubit>().loadInvestmentGroups();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildGroupCard(group, isMyGroups);
        },
      ),
    );
  }

  Widget _buildGroupCard(InvestmentGroup group, bool isMyGroup) {
    const currentUserId = 'current_user'; // TODO: Get from context
    final userContribution = group.getUserContribution(currentUserId);
    final userROI = group.getUserROI(currentUserId);
    final rentCoverage = group.getRentCoveragePercentage(1500); // TODO: Get actual rent from apartment data

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isMyGroup ? Colors.green : Colors.transparent,
          width: isMyGroup ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToGroupDetails(group),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isMyGroup)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Member',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Pool',
                      '\$${group.totalContributions.toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Current Value',
                      '\$${group.currentValue.toStringAsFixed(0)}',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Monthly Returns',
                      '\$${group.monthlyReturns.toStringAsFixed(0)}',
                      Icons.monetization_on,
                      Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Rent Coverage',
                      '${rentCoverage.toStringAsFixed(1)}%',
                      Icons.home,
                      rentCoverage >= 100 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              if (isMyGroup) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Contribution',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '\$${userContribution.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
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
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${userROI >= 0 ? '+' : ''}${userROI.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: userROI >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${group.participantIds.length} members',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.business_center, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${group.investments.length} investments',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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

  Widget _buildPerformanceOverview(List<InvestmentGroup> groups) {
    if (groups.isEmpty) {
      return const Center(
        child: Text('No investment groups to show performance for'),
      );
    }

    final totalContributions = groups.fold<double>(0, (sum, group) => sum + group.totalContributions);
    final totalCurrentValue = groups.fold<double>(0, (sum, group) => sum + group.currentValue);
    final totalMonthlyReturns = groups.fold<double>(0, (sum, group) => sum + group.monthlyReturns);
    final overallROI = totalContributions > 0 ? ((totalCurrentValue - totalContributions) / totalContributions) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Performance',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceCard(
                  'Total Invested',
                  '\$${totalContributions.toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPerformanceCard(
                  'Current Value',
                  '\$${totalCurrentValue.toStringAsFixed(0)}',
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
                child: _buildPerformanceCard(
                  'Monthly Returns',
                  '\$${totalMonthlyReturns.toStringAsFixed(0)}',
                  Icons.monetization_on,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPerformanceCard(
                  'Overall ROI',
                  '${overallROI >= 0 ? '+' : ''}${overallROI.toStringAsFixed(1)}%',
                  Icons.percent,
                  overallROI >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Group Performance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...groups.map((group) => _buildGroupPerformanceCard(group)),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupPerformanceCard(InvestmentGroup group) {
    final roi = group.totalContributions > 0 
        ? ((group.currentValue - group.totalContributions) / group.totalContributions) * 100 
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roi >= 0 ? Colors.green : Colors.red,
          child: Icon(
            roi >= 0 ? Icons.trending_up : Icons.trending_down,
            color: Colors.white,
          ),
        ),
        title: Text(group.name),
        subtitle: Text('${group.participantIds.length} members • ${group.investments.length} investments'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: roi >= 0 ? Colors.green : Colors.red,
              ),
            ),
            Text(
              '\$${group.monthlyReturns.toStringAsFixed(0)}/mo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToGroupDetails(group),
      ),
    );
  }

  void _navigateToGroupDetails(InvestmentGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvestmentGroupDetailsPage(group: group),
      ),
    );
  }
}