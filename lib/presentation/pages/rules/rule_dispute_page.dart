import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/rule_dispute_service.dart';
import '../../../core/services/rule_notification_service.dart';
import '../../core/widgets/permission_widget.dart';
import 'cubit/rule_dispute_cubit.dart';
import 'cubit/rule_dispute_state.dart';

class RuleDisputePage extends StatefulWidget {
  const RuleDisputePage({Key? key}) : super(key: key);

  @override
  State<RuleDisputePage> createState() => _RuleDisputePageState();
}

class _RuleDisputePageState extends State<RuleDisputePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<RuleDisputeCubit>().loadDisputes();
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
        title: const Text('Rule Disputes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.how_to_vote)),
            Tab(text: 'My Disputes', icon: Icon(Icons.person)),
            Tab(text: 'Resolved', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: BlocConsumer<RuleDisputeCubit, RuleDisputeState>(
        listener: (context, state) {
          if (state is RuleDisputeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is DisputeCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dispute created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is VoteCast) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vote cast successfully'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildActiveDisputesTab(state),
              _buildMyDisputesTab(state),
              _buildResolvedDisputesTab(state),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDisputeDialog(),
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.gavel, color: Colors.white),
        label: const Text('Create Dispute', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildActiveDisputesTab(RuleDisputeState state) {
    if (state is RuleDisputeLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is RuleDisputesLoaded) {
      final activeDisputes = state.disputes
          .where((dispute) => dispute.status == DisputeStatus.voting)
          .toList();

      if (activeDisputes.isEmpty) {
        return _buildEmptyState(
          'No active disputes',
          'Community disputes requiring votes will appear here',
          Icons.how_to_vote,
          Colors.blue,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeDisputes.length,
        itemBuilder: (context, index) {
          final dispute = activeDisputes[index];
          return _buildDisputeCard(dispute, showVoting: true);
        },
      );
    }

    return _buildErrorState();
  }

  Widget _buildMyDisputesTab(RuleDisputeState state) {
    if (state is RuleDisputesLoaded) {
      const currentUserId = 'current_user'; // TODO: Get from context
      final myDisputes = state.disputes
          .where((dispute) => dispute.disputedBy == currentUserId)
          .toList();

      if (myDisputes.isEmpty) {
        return _buildEmptyState(
          'No disputes created',
          'Disputes you create will appear here',
          Icons.person,
          Colors.grey,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myDisputes.length,
        itemBuilder: (context, index) {
          final dispute = myDisputes[index];
          return _buildDisputeCard(dispute, showVoting: false);
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildResolvedDisputesTab(RuleDisputeState state) {
    if (state is RuleDisputesLoaded) {
      final resolvedDisputes = state.disputes
          .where((dispute) => dispute.status == DisputeStatus.resolved)
          .toList();

      if (resolvedDisputes.isEmpty) {
        return _buildEmptyState(
          'No resolved disputes',
          'Resolved disputes will appear here',
          Icons.check_circle,
          Colors.green,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resolvedDisputes.length,
        itemBuilder: (context, index) {
          final dispute = resolvedDisputes[index];
          return _buildDisputeCard(dispute, showVoting: false);
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildDisputeCard(RuleDispute dispute, {required bool showVoting}) {
    const currentUserId = 'current_user'; // TODO: Get from context
    final hasVoted = dispute.votes?.containsKey(currentUserId) ?? false;
    final userVote = dispute.votes?[currentUserId];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(dispute.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisputeHeader(dispute),
            const SizedBox(height: 12),
            _buildDisputeContent(dispute),
            const SizedBox(height: 12),
            _buildDisputeMetadata(dispute),
            if (dispute.resolution != null) ...[
              const SizedBox(height: 12),
              _buildResolution(dispute),
            ],
            if (showVoting && dispute.status == DisputeStatus.voting) ...[
              const SizedBox(height: 16),
              _buildVotingSection(dispute, hasVoted, userVote),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisputeHeader(RuleDispute dispute) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(dispute.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(dispute.status).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(dispute.status),
                size: 12,
                color: _getStatusColor(dispute.status),
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusLabel(dispute.status),
                style: TextStyle(
                  color: _getStatusColor(dispute.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _getRuleName(dispute.ruleId),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisputeContent(RuleDispute dispute) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Dispute Reason: ${dispute.reason}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dispute.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeMetadata(RuleDispute dispute) {
    final votes = dispute.votes ?? {};
    final supportVotes = votes.values.where((vote) => vote).length;
    final opposeVotes = votes.values.where((vote) => !vote).length;

    return Column(
      children: [
        _buildMetadataRow(
          Icons.person,
          'Disputed By',
          _getUserName(dispute.disputedBy),
        ),
        _buildMetadataRow(
          Icons.access_time,
          'Created',
          _formatDateTime(dispute.createdAt),
        ),
        if (dispute.status == DisputeStatus.voting)
          _buildMetadataRow(
            Icons.how_to_vote,
            'Votes',
            '$supportVotes support, $opposeVotes oppose',
          ),
        if (dispute.resolvedAt != null)
          _buildMetadataRow(
            Icons.check_circle,
            'Resolved',
            _formatDateTime(dispute.resolvedAt!),
          ),
      ],
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolution(RuleDispute dispute) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Resolution',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dispute.resolution!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingSection(RuleDispute dispute, bool hasVoted, bool? userVote) {
    if (hasVoted) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              userVote! ? Icons.thumb_up : Icons.thumb_down,
              color: userVote ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'You voted to ${userVote ? 'support' : 'dismiss'} this dispute',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _castVote(dispute.id, true),
            icon: const Icon(Icons.thumb_up, size: 16),
            label: const Text('Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _castVote(dispute.id, false),
            icon: const Icon(Icons.thumb_down, size: 16),
            label: const Text('Dismiss'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: color.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return _buildEmptyState(
      'Failed to load disputes',
      'Please try again later',
      Icons.error,
      Colors.red,
    );
  }

  void _showCreateDisputeDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateDisputeDialog(
        onSubmit: (ruleId, reason, description) {
          context.read<RuleDisputeCubit>().createDispute(
            ruleId,
            reason,
            description,
          );
        },
      ),
    );
  }

  void _castVote(String disputeId, bool supportDispute) {
    context.read<RuleDisputeCubit>().castVote(disputeId, supportDispute);
  }

  Color _getStatusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return Colors.orange;
      case DisputeStatus.voting:
        return Colors.blue;
      case DisputeStatus.resolved:
        return Colors.green;
      case DisputeStatus.dismissed:
        return Colors.grey;
    }
  }

  String _getStatusLabel(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return 'PENDING';
      case DisputeStatus.voting:
        return 'VOTING';
      case DisputeStatus.resolved:
        return 'RESOLVED';
      case DisputeStatus.dismissed:
        return 'DISMISSED';
    }
  }

  IconData _getStatusIcon(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return Icons.pending;
      case DisputeStatus.voting:
        return Icons.how_to_vote;
      case DisputeStatus.resolved:
        return Icons.check_circle;
      case DisputeStatus.dismissed:
        return Icons.cancel;
    }
  }

  String _getRuleName(String ruleId) {
    switch (ruleId) {
      case 'quiet_hours':
        return 'Quiet Hours';
      case 'common_area':
        return 'Common Area Cleanliness';
      case 'guest_policy':
        return 'Guest Policy';
      case 'smoking':
        return 'No Smoking';
      default:
        return 'Unknown Rule';
    }
  }

  String _getUserName(String userId) {
    switch (userId) {
      case 'user1':
        return 'Alice Johnson';
      case 'user2':
        return 'Bob Smith';
      case 'user3':
        return 'Carol Davis';
      case 'admin1':
        return 'Admin User';
      default:
        return 'Unknown User';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class _CreateDisputeDialog extends StatefulWidget {
  final Function(String ruleId, String reason, String description) onSubmit;

  const _CreateDisputeDialog({required this.onSubmit});

  @override
  State<_CreateDisputeDialog> createState() => _CreateDisputeDialogState();
}

class _CreateDisputeDialogState extends State<_CreateDisputeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedRuleId;
  
  final List<Map<String, String>> _rules = [
    {'id': 'quiet_hours', 'name': 'Quiet Hours'},
    {'id': 'common_area', 'name': 'Common Area Cleanliness'},
    {'id': 'guest_policy', 'name': 'Guest Policy'},
    {'id': 'smoking', 'name': 'No Smoking'},
    {'id': 'noise_level', 'name': 'Noise Level'},
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.gavel, color: Colors.orange),
          const SizedBox(width: 8),
          const Text('Create Rule Dispute'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedRuleId,
                decoration: const InputDecoration(
                  labelText: 'Which rule do you want to dispute?',
                  border: OutlineInputBorder(),
                ),
                items: _rules.map((rule) {
                  return DropdownMenuItem(
                    value: rule['id'],
                    child: Text(rule['name']!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedRuleId = value),
                validator: (value) => value == null ? 'Please select a rule' : null,
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Dispute Reason',
                  hintText: 'e.g., Unfair enforcement, Too restrictive',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description',
                  hintText: 'Explain your concerns in detail...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a detailed description';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your dispute will be put to a community vote. All apartment members will be able to vote on whether to uphold or dismiss your dispute.',
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitDispute,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create Dispute'),
        ),
      ],
    );
  }

  void _submitDispute() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      _selectedRuleId!,
      _reasonController.text.trim(),
      _descriptionController.text.trim(),
    );
    
    Navigator.of(context).pop();
  }
}