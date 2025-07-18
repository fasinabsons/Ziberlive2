import 'package:flutter/material.dart';
import '../../../../domain/entities/vote.dart';
import 'dart:async';

class LiveVoteProgress extends StatefulWidget {
  final Vote vote;
  final VoidCallback? onTap;

  const LiveVoteProgress({
    Key? key,
    required this.vote,
    this.onTap,
  }) : super(key: key);

  @override
  State<LiveVoteProgress> createState() => _LiveVoteProgressState();
}

class _LiveVoteProgressState extends State<LiveVoteProgress>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  Timer? _updateTimer;
  int _previousVoteCount = 0;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.vote.participationRate,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
    
    _previousVoteCount = widget.vote.totalVotes;
    _progressController.forward();
    
    // Start live updates
    _startLiveUpdates();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(LiveVoteProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.vote.totalVotes != widget.vote.totalVotes) {
      _animateVoteUpdate();
    }
  }

  void _startLiveUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Simulate live updates - in real app this would come from the cubit
      if (mounted) {
        setState(() {
          // This would be updated by the parent widget/cubit
        });
      }
    });
  }

  void _animateVoteUpdate() {
    // Animate progress bar update
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: widget.vote.participationRate,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressController.reset();
    _progressController.forward();
    
    // Pulse animation for new votes
    if (widget.vote.totalVotes > _previousVoteCount) {
      _pulseController.reset();
      _pulseController.forward();
    }
    
    _previousVoteCount = widget.vote.totalVotes;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildProgressSection(),
              const SizedBox(height: 12),
              _buildTimeRemaining(),
              if (widget.vote.isActive) ...[
                const SizedBox(height: 12),
                _buildLiveIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.vote.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;
    
    if (widget.vote.isActive) {
      final timeRemaining = widget.vote.timeRemaining;
      if (timeRemaining.inHours <= 1) {
        color = Colors.red;
        label = 'URGENT';
        icon = Icons.warning;
      } else if (timeRemaining.inHours <= 6) {
        color = Colors.orange;
        label = 'CLOSING SOON';
        icon = Icons.schedule;
      } else {
        color = Colors.green;
        label = 'ACTIVE';
        icon = Icons.how_to_vote;
      }
    } else {
      color = Colors.grey;
      label = 'CLOSED';
      icon = Icons.lock;
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

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Text(
                '${widget.vote.totalVotes}/${widget.vote.totalEligibleVoters} voted',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Text(
              '${(widget.vote.participationRate * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(_progressAnimation.value),
              ),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeRemaining() {
    final timeRemaining = widget.vote.timeRemaining;
    final isUrgent = timeRemaining.inHours <= 6 && widget.vote.isActive;
    
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: isUrgent ? Colors.orange : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          widget.vote.isActive
              ? 'Closes in ${_formatTimeRemaining(timeRemaining)}'
              : 'Closed ${_formatDate(widget.vote.closedAt ?? widget.vote.deadline)}',
          style: TextStyle(
            color: isUrgent ? Colors.orange : Colors.grey[600],
            fontWeight: isUrgent ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveIndicator() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Live updates',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) return 'Expired';
    
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}