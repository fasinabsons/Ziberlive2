import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/vote.dart';
import '../../../domain/entities/user.dart';
import '../../core/widgets/permission_widget.dart';
import 'cubit/voting_cubit.dart';
import 'cubit/voting_state.dart';
import 'create_vote_page.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({Key? key}) : super(key: key);

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VoteStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<VotingCubit>().loadVotes();
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
        title: const Text('Community Voting'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.how_to_vote)),
            Tab(text: 'My Votes', icon: Icon(Icons.person)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () => context.read<VotingCubit>().loadVotes(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<VotingCubit, VotingState>(
        listener: (context, state) {
          if (state is VotingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is VoteCast) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vote cast successfully! +3 credits earned'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<VotingCubit>().loadVotes();
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildActiveVotesTab(state),
              _buildMyVotesTab(state),
              _buildHistoryTab(state),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _createQuickPoll(),
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.flash_on, color: Colors.white),
            label: const Text('Quick Poll', style: TextStyle(color: Colors.white)),
            heroTag: 'quick_poll',
          ),
          const SizedBox(height: 8),
          PermissionWidget(
            requiredRole: UserRole.roommateAdmin,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateVotePage(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
              heroTag: 'create_vote',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveVotesTab(VotingState state) {
    if (state is VotingLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is VotesLoaded) {
      final activeVotes = state.votes
          .where((vote) => vote.isActive)
          .toList();
      final filteredVotes = _filterVotes(activeVotes);
      return _buildVoteList(filteredVotes, showVoteButton: true);
    }
    
    return const Center(
      child: Text('No active votes available'),
    );
  }

  Widget _buildMyVotesTab(VotingState state) {
    // TODO: Get current user ID from context
    const currentUserId = 'current_user';
    
    if (state is VotesLoaded) {
      final myVotes = state.votes
          .where((vote) => vote.votes.containsKey(currentUserId))
          .toList();
      final filteredVotes = _filterVotes(myVotes);
      return _buildVoteList(filteredVotes, showResults: true);
    }
    
    return const Center(
      child: Text('You haven\'t voted on any polls yet'),
    );
  }

  Widget _buildHistoryTab(VotingState state) {
    if (state is VotesLoaded) {
      final closedVotes = state.votes
          .where((vote) => vote.status == VoteStatus.closed || vote.isExpired)
          .toList();
      final filteredVotes = _filterVotes(closedVotes);
      return _buildVoteList(filteredVotes, showResults: true);
    }
    
    return const Center(
      child: Text('No vote history available'),
    );
  }

  Widget _buildVoteList(List<Vote> votes, {bool showVoteButton = false, bool showResults = false}) {
    if (votes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_vote,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No votes found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<VotingCubit>().loadVotes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: votes.length,
        itemBuilder: (context, index) {
          final vote = votes[index];
          return _buildVoteCard(vote, showVoteButton: showVoteButton, showResults: showResults);
        },
      ),
    );
  }

  Widget _buildVoteCard(Vote vote, {bool showVoteButton = false, bool showResults = false}) {
    final timeRemaining = vote.timeRemaining;
    final isUrgent = timeRemaining.inHours <= 6 && vote.isActive;
    final hasVoted = vote.votes.containsKey('current_user'); // TODO: Get current user ID

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUrgent ? Colors.orange : Colors.transparent,
          width: isUrgent ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vote.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildVoteStatusChip(vote),
              ],
            ),
            if (vote.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                vote.description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  vote.isActive 
                      ? 'Closes in ${_formatTimeRemaining(timeRemaining)}'
                      : 'Closed ${_formatDate(vote.closedAt ?? vote.deadline)}',
                  style: TextStyle(
                    color: isUrgent ? Colors.orange : Colors.grey[600],
                    fontWeight: isUrgent ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${vote.totalVotes}/${vote.totalEligibleVoters} voted (${(vote.participationRate * 100).toInt()}%)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                if (vote.isAnonymous)
                  Chip(
                    label: const Text('Anonymous', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: vote.participationRate,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                vote.participationRate > 0.8 ? Colors.green :
                vote.participationRate > 0.5 ? Colors.orange : Colors.red,
              ),
            ),
            if (showResults || hasVoted) ...[
              const SizedBox(height: 16),
              _buildVoteResults(vote),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (vote.allowComments)
                  TextButton.icon(
                    onPressed: () => _showComments(vote),
                    icon: const Icon(Icons.comment, size: 16),
                    label: const Text('Comments'),
                  ),
                const SizedBox(width: 8),
                if (showVoteButton && vote.isActive && !hasVoted)
                  ElevatedButton.icon(
                    onPressed: () => _showVotingDialog(vote),
                    icon: const Icon(Icons.how_to_vote, size: 16),
                    label: const Text('Vote'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  )
                else if (hasVoted && vote.isActive)
                  TextButton.icon(
                    onPressed: () => _showVotingDialog(vote, isChanging: true),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Change Vote'),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _showVoteDetails(vote),
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Details'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteStatusChip(Vote vote) {
    Color color;
    String label;
    
    if (vote.isActive) {
      final timeRemaining = vote.timeRemaining;
      if (timeRemaining.inHours <= 6) {
        color = Colors.orange;
        label = 'Urgent';
      } else {
        color = Colors.green;
        label = 'Active';
      }
    } else if (vote.status == VoteStatus.closed) {
      color = Colors.grey;
      label = 'Closed';
    } else {
      color = Colors.red;
      label = 'Expired';
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildVoteResults(Vote vote) {
    final results = vote.results;
    final totalVotes = vote.totalVotes;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Results:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...vote.options.map((option) {
          final voteCount = results[option.id] ?? 0;
          final percentage = totalVotes > 0 ? voteCount / totalVotes : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(option.text)),
                    Text('$voteCount votes (${(percentage * 100).toInt()}%)'),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (vote.winningOption != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Winner: ${vote.winningOption!.text}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) return 'Expired';
    
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<Vote> _filterVotes(List<Vote> votes) {
    if (_filterStatus == null) return votes;
    return votes.where((vote) => vote.status == _filterStatus).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Votes'),
        content: DropdownButtonFormField<VoteStatus?>(
          value: _filterStatus,
          decoration: const InputDecoration(labelText: 'Status'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Statuses')),
            ...VoteStatus.values.map((status) => DropdownMenuItem(
              value: status,
              child: Text(status.toString().split('.').last),
            )),
          ],
          onChanged: (value) => setState(() => _filterStatus = value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _filterStatus = null);
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _createQuickPoll() {
    showDialog(
      context: context,
      builder: (context) => QuickPollDialog(
        onCreatePoll: (question, options) {
          context.read<VotingCubit>().createQuickPoll(
            question,
            options,
            'current_apartment', // TODO: Get from context
            'current_user', // TODO: Get from context
          );
        },
      ),
    );
  }

  void _showVotingDialog(Vote vote, {bool isChanging = false}) {
    showDialog(
      context: context,
      builder: (context) => VotingDialog(
        vote: vote,
        isChanging: isChanging,
        onVote: (selectedOptions, comment, rating) {
          if (isChanging) {
            context.read<VotingCubit>().changeVote(
              vote.id,
              'current_user', // TODO: Get from context
              selectedOptions,
              comment: comment,
              rating: rating,
            );
          } else {
            context.read<VotingCubit>().castVote(
              vote.id,
              'current_user', // TODO: Get from context
              selectedOptions,
              comment: comment,
              rating: rating,
            );
          }
        },
      ),
    );
  }

  void _showComments(Vote vote) {
    // TODO: Implement comments dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comments feature coming soon!')),
    );
  }

  void _showVoteDetails(Vote vote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vote.question),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vote.description.isNotEmpty) ...[
                Text('Description: ${vote.description}'),
                const SizedBox(height: 8),
              ],
              Text('Type: ${vote.type.toString().split('.').last}'),
              const SizedBox(height: 8),
              Text('Status: ${vote.status.toString().split('.').last}'),
              const SizedBox(height: 8),
              Text('Created: ${_formatDate(vote.createdAt)}'),
              const SizedBox(height: 8),
              Text('Deadline: ${_formatDate(vote.deadline)}'),
              const SizedBox(height: 8),
              Text('Anonymous: ${vote.isAnonymous ? "Yes" : "No"}'),
              const SizedBox(height: 8),
              Text('Total Votes: ${vote.totalVotes}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Quick Poll Dialog Widget
class QuickPollDialog extends StatefulWidget {
  final Function(String question, List<String> options) onCreatePoll;

  const QuickPollDialog({Key? key, required this.onCreatePoll}) : super(key: key);

  @override
  State<QuickPollDialog> createState() => _QuickPollDialogState();
}

class _QuickPollDialogState extends State<QuickPollDialog> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Quick Poll'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'e.g., New menu: Pizza?',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._optionControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          hintText: index == 0 ? 'Yes' : 'No',
                        ),
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        onPressed: () => _removeOption(index),
                        icon: const Icon(Icons.remove_circle),
                      ),
                  ],
                ),
              );
            }).toList(),
            if (_optionControllers.length < 5)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _createPoll,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _addOption() {
    if (_optionControllers.length < 5) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  void _createPoll() {
    final question = _questionController.text.trim();
    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
      return;
    }

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 2 options')),
      );
      return;
    }

    widget.onCreatePoll(question, options);
    Navigator.of(context).pop();
  }
}

// Voting Dialog Widget
class VotingDialog extends StatefulWidget {
  final Vote vote;
  final bool isChanging;
  final Function(List<String> selectedOptions, String? comment, int? rating) onVote;

  const VotingDialog({
    Key? key,
    required this.vote,
    this.isChanging = false,
    required this.onVote,
  }) : super(key: key);

  @override
  State<VotingDialog> createState() => _VotingDialogState();
}

class _VotingDialogState extends State<VotingDialog> {
  final Set<String> _selectedOptions = {};
  final _commentController = TextEditingController();
  int? _rating;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isChanging ? 'Change Your Vote' : 'Cast Your Vote'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.vote.question,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (widget.vote.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(widget.vote.description),
            ],
            const SizedBox(height: 16),
            _buildVotingOptions(),
            if (widget.vote.type == VoteType.rating) ...[
              const SizedBox(height: 16),
              _buildRatingSelector(),
            ],
            if (widget.vote.allowComments) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  hintText: 'Share your thoughts...',
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _canSubmit() ? _submitVote : null,
          child: Text(widget.isChanging ? 'Change Vote' : 'Vote'),
        ),
      ],
    );
  }

  Widget _buildVotingOptions() {
    switch (widget.vote.type) {
      case VoteType.singleChoice:
      case VoteType.yesNo:
        return Column(
          children: widget.vote.options.map((option) {
            return RadioListTile<String>(
              title: Text(option.text),
              subtitle: option.description != null ? Text(option.description!) : null,
              value: option.id,
              groupValue: _selectedOptions.isNotEmpty ? _selectedOptions.first : null,
              onChanged: (value) {
                setState(() {
                  _selectedOptions.clear();
                  if (value != null) _selectedOptions.add(value);
                });
              },
            );
          }).toList(),
        );
      case VoteType.multipleChoice:
        return Column(
          children: widget.vote.options.map((option) {
            return CheckboxListTile(
              title: Text(option.text),
              subtitle: option.description != null ? Text(option.description!) : null,
              value: _selectedOptions.contains(option.id),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedOptions.add(option.id);
                  } else {
                    _selectedOptions.remove(option.id);
                  }
                });
              },
            );
          }).toList(),
        );
      case VoteType.rating:
        return Column(
          children: widget.vote.options.map((option) {
            return ListTile(
              title: Text(option.text),
              subtitle: option.description != null ? Text(option.description!) : null,
              onTap: () {
                setState(() {
                  _selectedOptions.clear();
                  _selectedOptions.add(option.id);
                });
              },
              selected: _selectedOptions.contains(option.id),
            );
          }).toList(),
        );
    }
  }

  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final rating = index + 1;
            return IconButton(
              onPressed: () {
                setState(() {
                  _rating = rating;
                });
              },
              icon: Icon(
                _rating != null && _rating! >= rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
            );
          }),
        ),
      ],
    );
  }

  bool _canSubmit() {
    if (_selectedOptions.isEmpty) return false;
    if (widget.vote.type == VoteType.rating && _rating == null) return false;
    return true;
  }

  void _submitVote() {
    widget.onVote(
      _selectedOptions.toList(),
      _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      _rating,
    );
    Navigator.of(context).pop();
  }
}