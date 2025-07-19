import 'package:flutter/material.dart';
import '../../../core/permissions/permission_service.dart';
import '../../core/widgets/permission_widget.dart';
import '../../core/widgets/sync_status_widget.dart';
import '../admin/user_management_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const BillsTab(),
    const TasksTab(),
    const CommunityTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              // TODO: Implement sync functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to ZiberLive!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Sync Status Widget
            const SyncStatusWidget(showDetails: true),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('Pending Bills'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('Active Tasks'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('Credits'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillsTab extends StatelessWidget {
  const BillsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        actions: [
          // AdminOnlyWidget - temporarily disabled
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Admin bill settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Bills feature coming soon!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add bill functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          // AdminOnlyWidget - temporarily disabled
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task scheduling coming soon!')),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Tasks feature coming soon!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add task functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          // AdminOnlyWidget - temporarily disabled
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community Member',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Participate in community activities and voting'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rules & Compliance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureGrid(context, [
              _FeatureItem(
                title: 'Rule Violations',
                subtitle: 'Report and manage violations',
                icon: Icons.report,
                color: Colors.red,
                route: '/rule-violations',
              ),
              _FeatureItem(
                title: 'Compliance Tracking',
                subtitle: 'Track your rule compliance',
                icon: Icons.shield,
                color: Colors.green,
                route: '/rule-compliance',
              ),
              _FeatureItem(
                title: 'Rule Disputes',
                subtitle: 'Community dispute resolution',
                icon: Icons.gavel,
                color: Colors.orange,
                route: '/rule-disputes',
              ),
            ]),
            const SizedBox(height: 16),
            const Text(
              'Communication',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureGrid(context, [
              _FeatureItem(
                title: 'Bluetooth Chat',
                subtitle: 'Offline messaging with roommates',
                icon: Icons.bluetooth,
                color: Colors.blue,
                route: '/bluetooth-chat',
              ),
            ]),
            const SizedBox(height: 16),
            const Text(
              'Rewards & Gamification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureGrid(context, [
              _FeatureItem(
                title: 'Reward Coins',
                subtitle: 'Earn and redeem coins',
                icon: Icons.monetization_on,
                color: Colors.amber,
                route: '/reward-coins',
              ),
              _FeatureItem(
                title: 'Co-Living Credits',
                subtitle: 'Your community credits',
                icon: Icons.stars,
                color: Colors.purple,
                route: '/credits',
              ),
              _FeatureItem(
                title: 'Community Tree',
                subtitle: 'Watch our community grow',
                icon: Icons.park,
                color: Colors.green,
                route: '/community-tree',
              ),
              _FeatureItem(
                title: 'Achievements',
                subtitle: 'Unlock achievements',
                icon: Icons.emoji_events,
                color: Colors.amber,
                route: '/achievements',
              ),
              _FeatureItem(
                title: 'Leaderboard',
                subtitle: 'Community rankings',
                icon: Icons.leaderboard,
                color: Colors.indigo,
                route: '/leaderboard',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, List<_FeatureItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, item.route),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 32,
                    color: item.color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile features coming soon!'),
      ),
    );
  }
}