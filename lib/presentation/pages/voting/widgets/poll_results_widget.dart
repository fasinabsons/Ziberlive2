import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../domain/entities/vote.dart';

class PollResultsWidget extends StatefulWidget {
  final Vote vote;
  final bool showDetailedResults;
  final VoidCallback? onShowComments;

  const PollResultsWidget({
    Key? key,
    required this.vote,
    this.showDetailedResults = false,
    this.onShowComments,
  }) : super(key: key);

  @override
  State<PollResultsWidget> createState() => _PollResultsWidgetState();
}

class _PollResultsWidgetState extends State<PollResultsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showChart = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (widget.showDetailedResults) ...[
              _buildTabBar(),
              const SizedBox(height: 16),
              _buildTabContent(),
            ] else
              _buildSimpleResults(),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.vote.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStatusBadge(),
          ],
        ),
        if (widget.vote.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.vote.description,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 12),
        _buildVoteStats(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;

    if (widget.vote.status == VoteStatus.closed) {
      color = Colors.grey;
      label = 'CLOSED';
      icon = Icons.lock;
    } else if (widget.vote.isExpired) {
      color = Colors.red;
      label = 'EXPIRED';
      icon = Icons.schedule;
    } else {
      color = Colors.green;
      label = 'ACTIVE';
      icon = Icons.how_to_vote;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteStats() {
    return Row(
      children: [
        Icon(Icons.people, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${widget.vote.totalVotes} votes',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.percent, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${(widget.vote.participationRate * 100).toInt()}% participation',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (widget.vote.isAnonymous)
          Chip(
            label: const Text('Anonymous', style: TextStyle(fontSize: 10)),
            backgroundColor: Colors.blue.withOpacity(0.1),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Chart View'),
          Tab(text: 'List View'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 300,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildChartView(),
          _buildListView(),
        ],
      ),
    );
  }

  Widget _buildSimpleResults() {
    return _buildListView();
  }

  Widget _buildChartView() {
    final results = widget.vote.results;
    final totalVotes = widget.vote.totalVotes;

    if (totalVotes == 0) {
      return const Center(
        child: Text(
          'No votes yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final sections = widget.vote.options.map((option) {
      final voteCount = results[option.id] ?? 0;
      final percentage = voteCount / totalVotes;
      
      return PieChartSectionData(
        color: _getOptionColor(option.id),
        value: voteCount.toDouble(),
        title: '${(percentage * 100).toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLegend(),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    final results = widget.vote.results;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.vote.options.map((option) {
        final voteCount = results[option.id] ?? 0;
        final percentage = widget.vote.totalVotes > 0 
            ? voteCount / widget.vote.totalVotes 
            : 0.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getOptionColor(option.id),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.text,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$voteCount votes (${(percentage * 100).toInt()}%)',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListView() {
    final results = widget.vote.results;
    final totalVotes = widget.vote.totalVotes;
    
    // Sort options by vote count (highest first)
    final sortedOptions = List<VoteOption>.from(widget.vote.options);
    sortedOptions.sort((a, b) {
      final aVotes = results[a.id] ?? 0;
      final bVotes = results[b.id] ?? 0;
      return bVotes.compareTo(aVotes);
    });

    return Column(
      children: [
        if (widget.vote.winningOption != null) ...[
          _buildWinnerCard(),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: ListView.builder(
            itemCount: sortedOptions.length,
            itemBuilder: (context, index) {
              final option = sortedOptions[index];
              final voteCount = results[option.id] ?? 0;
              final percentage = totalVotes > 0 ? voteCount / totalVotes : 0.0;
              final isWinner = widget.vote.winningOption?.id == option.id;
              
              return _buildOptionResultCard(
                option,
                voteCount,
                percentage,
                isWinner,
                index,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerCard() {
    final winner = widget.vote.winningOption!;
    final voteCount = widget.vote.results[winner.id] ?? 0;
    final percentage = widget.vote.totalVotes > 0 
        ? voteCount / widget.vote.totalVotes 
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[100]!, Colors.amber[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Winner',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                Text(
                  winner.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$voteCount votes\n${(percentage * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionResultCard(
    VoteOption option,
    int voteCount,
    double percentage,
    bool isWinner,
    int rank,
  ) {
    return Card(
      elevation: isWinner ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isWinner ? Colors.amber : Colors.transparent,
          width: isWinner ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${rank + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '$voteCount votes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (option.description != null) ...[
              const SizedBox(height: 4),
              Text(
                option.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getOptionColor(option.id),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Text(
          'Closed: ${_formatDate(widget.vote.closedAt ?? widget.vote.deadline)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        if (widget.vote.allowComments && widget.onShowComments != null)
          TextButton.icon(
            onPressed: widget.onShowComments,
            icon: const Icon(Icons.comment, size: 16),
            label: const Text('Comments'),
          ),
        TextButton.icon(
          onPressed: () => _shareResults(),
          icon: const Icon(Icons.share, size: 16),
          label: const Text('Share'),
        ),
      ],
    );
  }

  Color _getOptionColor(String optionId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = widget.vote.options.indexWhere((option) => option.id == optionId);
    return colors[index % colors.length];
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey; // Silver
      case 2:
        return Colors.brown; // Bronze
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _shareResults() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing results...')),
    );
  }
}