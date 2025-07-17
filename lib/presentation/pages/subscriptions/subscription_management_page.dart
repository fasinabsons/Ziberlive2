import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/user/manage_subscription_usecase.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/permissions/permission_service.dart';
import '../../core/widgets/permission_widget.dart';
import 'cubit/subscription_cubit.dart';

class SubscriptionManagementPage extends StatefulWidget {
  final User user;
  final bool isAdminView;

  const SubscriptionManagementPage({
    super.key,
    required this.user,
    this.isAdminView = false,
  });

  @override
  State<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionCubit(getIt<ManageSubscriptionUseCase>())
        ..loadUserSubscriptions(widget.user.id),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isAdminView 
              ? 'Manage ${widget.user.name}\'s Subscriptions'
              : 'My Subscriptions'),
          actions: [
            AdminOnlyWidget(
              child: IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => _showSubscriptionHistory(),
              ),
            ),
          ],
        ),
        body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is SubscriptionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoCard(),
                  const SizedBox(height: 16),
                  _buildActiveSubscriptionsSection(),
                  const SizedBox(height: 16),
                  _buildAvailableSubscriptionsSection(),
                  const SizedBox(height: 16),
                  _buildPendingApprovalsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.user.role == UserRole.roommateAdmin 
                  ? Colors.orange 
                  : Colors.green,
              child: Icon(
                widget.user.role == UserRole.roommateAdmin 
                    ? Icons.admin_panel_settings 
                    : Icons.person,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.user.email),
                  Text(
                    '${widget.user.role == UserRole.roommateAdmin ? 'Admin' : 'Member'} • ${widget.user.coLivingCredits} credits',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionsSection() {
    final activeSubscriptions = widget.user.subscriptions
        .where((sub) => sub.isActive)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Subscriptions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (activeSubscriptions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No active subscriptions',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          ...activeSubscriptions.map((subscription) => Card(
            child: ListTile(
              leading: Icon(
                _getSubscriptionIcon(subscription.type),
                color: Colors.green,
              ),
              title: Text(subscription.customName),
              subtitle: Text(
                'Active since ${_formatDate(subscription.startDate)}',
              ),
              trailing: widget.isAdminView || 
                      PermissionService.canApproveSubscriptions(widget.user)
                  ? PopupMenuButton<String>(
                      onSelected: (value) => _handleSubscriptionAction(value, subscription),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit Name'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'deactivate',
                          child: ListTile(
                            leading: Icon(Icons.pause_circle, color: Colors.orange),
                            title: Text('Deactivate'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: const Icon(Icons.pause_circle, color: Colors.orange),
                      onPressed: () => _requestDeactivation(subscription),
                    ),
            ),
          )),
      ],
    );
  }

  Widget _buildAvailableSubscriptionsSection() {
    final availableSubscriptions = getIt<ManageSubscriptionUseCase>()
        .getAvailableSubscriptions();
    
    final userSubscriptionTypes = widget.user.subscriptions
        .where((sub) => sub.isActive)
        .map((sub) => sub.type)
        .toSet();

    final availableTypes = availableSubscriptions.entries
        .where((entry) => !userSubscriptionTypes.contains(entry.key))
        .toList();

    if (availableTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Subscriptions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...availableTypes.map((entry) => Card(
          child: ListTile(
            leading: Icon(
              _getSubscriptionIcon(entry.key),
              color: Colors.grey,
            ),
            title: Text(entry.value),
            subtitle: Text(_getSubscriptionDescription(entry.key)),
            trailing: ElevatedButton(
              onPressed: () => _addSubscription(entry.key, entry.value),
              child: const Text('Add'),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPendingApprovalsSection() {
    // TODO: Implement pending approvals from database
    return AdminOnlyWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Approvals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No pending approvals',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSubscriptionIcon(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.rent:
        return Icons.home;
      case SubscriptionType.utilities:
        return Icons.electrical_services;
      case SubscriptionType.communityCooking:
        return Icons.restaurant;
      case SubscriptionType.drinkingWater:
        return Icons.water_drop;
    }
  }

  String _getSubscriptionDescription(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.rent:
        return 'Monthly room rent payments';
      case SubscriptionType.utilities:
        return 'Electricity, gas, and other utilities';
      case SubscriptionType.communityCooking:
        return 'Shared meal planning and costs';
      case SubscriptionType.drinkingWater:
        return 'Drinking water and filtration';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleSubscriptionAction(String action, Subscription subscription) {
    switch (action) {
      case 'edit':
        _showEditNameDialog(subscription);
        break;
      case 'deactivate':
        _showDeactivateConfirmation(subscription);
        break;
    }
  }

  void _showEditNameDialog(Subscription subscription) {
    final controller = TextEditingController(text: subscription.customName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subscription Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Custom Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SubscriptionCubit>().updateSubscriptionName(
                widget.user.id,
                subscription.type,
                controller.text,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateConfirmation(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Subscription'),
        content: Text(
          'Are you sure you want to deactivate "${subscription.customName}"? '
          'This will affect future bill splits.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SubscriptionCubit>().removeSubscription(
                widget.user.id,
                subscription.type,
                requiresApproval: false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _requestDeactivation(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Deactivation'),
        content: Text(
          'Request to deactivate "${subscription.customName}"? '
          'This requires admin approval.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SubscriptionCubit>().removeSubscription(
                widget.user.id,
                subscription.type,
                requiresApproval: true,
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _addSubscription(SubscriptionType type, String defaultName) {
    final controller = TextEditingController(text: defaultName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subscription'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Custom Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SubscriptionCubit>().addSubscription(
                widget.user.id,
                type,
                controller.text,
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription history coming soon!')),
    );
  }
}