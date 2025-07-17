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
          AdminOnlyWidget(
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin bill settings coming soon!')),
                );
              },
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('Bills feature coming soon!'),
      ),
      floatingActionButton: PermissionWidget(
        permission: Permission.createBill,
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Add bill functionality
          },
          child: const Icon(Icons.add),
        ),
        fallback: null, // Hide FAB for users without permission
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
          AdminOnlyWidget(
            child: IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task scheduling coming soon!')),
                );
              },
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('Tasks feature coming soon!'),
      ),
      floatingActionButton: PermissionWidget(
        permission: Permission.createTask,
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Add task functionality
          },
          child: const Icon(Icons.add),
        ),
        fallback: null, // Hide FAB for users without permission
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
          AdminOnlyWidget(
            child: IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          RoleBasedWidget(
            adminWidget: const Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Panel',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Manage users, bills, and apartment settings'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            userWidget: const Card(
              margin: EdgeInsets.all(16),
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
          ),
          const Expanded(
            child: Center(
              child: Text('Community features coming soon!'),
            ),
          ),
        ],
      ),
    );
  }
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