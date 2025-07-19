import 'package:flutter/material.dart';
import 'widgets/tip_card.dart';
import 'widgets/event_card.dart';
import 'widgets/deal_card.dart';

class CommunityBoardPage extends StatelessWidget {
  const CommunityBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community Board'),
          backgroundColor: Colors.green.shade50,
          foregroundColor: Colors.green.shade800,
          elevation: 0,
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.tips_and_updates), text: 'Tips'),
              Tab(icon: Icon(Icons.event), text: 'Events'),
              Tab(icon: Icon(Icons.local_offer), text: 'Deals'),
            ],
            labelColor: Colors.green.shade700,
            unselectedLabelColor: Colors.green.shade400,
            indicatorColor: Colors.green.shade600,
          ),
        ),
        body: const TabBarView(
          children: [
            TipsTab(),
            EventsTab(),
            DealsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateDialog(context),
          backgroundColor: Colors.green.shade600,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What would you like to create?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: Icon(Icons.tips_and_updates, color: Colors.blue.shade600),
              title: const Text('Share a Tip'),
              subtitle: const Text('Share useful information with the community'),
              onTap: () {
                Navigator.pop(context);
                _showCreateTipDialog(context);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.event, color: Colors.orange.shade600),
              title: const Text('Create Event'),
              subtitle: const Text('Organize a community event'),
              onTap: () {
                Navigator.pop(context);
                _showCreateEventDialog(context);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.local_offer, color: Colors.green.shade600),
              title: const Text('Share Deal'),
              subtitle: const Text('Share a local deal or discount'),
              onTap: () {
                Navigator.pop(context);
                _showCreateDealDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateTipDialog(),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateEventDialog(),
    );
  }

  void _showCreateDealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateDealDialog(),
    );
  }
}

class TipsTab extends StatelessWidget {
  const TipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter and sort options
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'all',
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Categories')),
                    DropdownMenuItem(value: 'deals', child: Text('Deals & Discounts')),
                    DropdownMenuItem(value: 'services', child: Text('Services')),
                    DropdownMenuItem(value: 'activities', child: Text('Activities')),
                  ],
                  onChanged: (value) {
                    // Handle category change
                  },
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: 'newest',
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Newest')),
                  DropdownMenuItem(value: 'popular', child: Text('Popular')),
                  DropdownMenuItem(value: 'trending', child: Text('Trending')),
                ],
                onChanged: (value) {
                  // Handle sort change
                },
              ),
            ],
          ),
        ),
        
        // Tips list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3, // Sample count
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TipCard(tip: null), // Sample data
              );
            },
          ),
        ),
      ],
    );
  }
}

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2, // Sample count
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCard(event: null), // Sample data
        );
      },
    );
  }
}

class DealsTab extends StatelessWidget {
  const DealsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2, // Sample count
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DealCard(deal: null), // Sample data
        );
      },
    );
  }
}

// Placeholder dialogs
class CreateTipDialog extends StatelessWidget {
  const CreateTipDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share a Tip'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Title',
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
              const SnackBar(content: Text('Tip shared successfully!')),
            );
          },
          child: const Text('Share'),
        ),
      ],
    );
  }
}

class CreateEventDialog extends StatelessWidget {
  const CreateEventDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Event'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Event Title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Description',
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
              const SnackBar(content: Text('Event created successfully!')),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class CreateDealDialog extends StatelessWidget {
  const CreateDealDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Deal'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Deal Title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Store Name',
              border: OutlineInputBorder(),
            ),
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
              const SnackBar(content: Text('Deal shared successfully!')),
            );
          },
          child: const Text('Share'),
        ),
      ],
    );
  }
} 