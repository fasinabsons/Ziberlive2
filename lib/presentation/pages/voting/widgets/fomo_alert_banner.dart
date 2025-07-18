import 'package:flutter/material.dart';
import '../../../../domain/entities/vote.dart';

class FomoAlertBanner extends StatefulWidget {
  final Vote vote;
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onVoteNow;

  const FomoAlertBanner({
    Key? key,
    required this.vote,
    required this.message,
    this.onDismiss,
    this.onVoteNow,
  }) : super(key: key);

  @override
  State<FomoAlertBanner> createState() => _FomoAlertBannerState();
}

class _FomoAlertBannerState extends State<FomoAlertBanner>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    
    // Auto-dismiss after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _slideController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeRemaining = widget.vote.timeRemaining;
    final isUrgent = timeRemaining.inHours <= 1;
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUrgent 
                ? [Colors.red[400]!, Colors.red[600]!]
                : [Colors.orange[400]!, Colors.orange[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isUrgent ? Colors.red : Colors.orange).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isUrgent ? Icons.warning : Icons.schedule,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isUrgent ? 'URGENT VOTE!' : 'Vote Reminder',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _dismiss,
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.vote.question,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.vote.totalVotes}/${widget.vote.totalEligibleVoters} voted',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildActionButtons(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            widget.onVoteNow?.call();
            _dismiss();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: widget.vote.timeRemaining.inHours <= 1 
                ? Colors.red[600] 
                : Colors.orange[600],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Vote Now',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: _dismiss,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            'Remind Later',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class FomoAlertOverlay extends StatelessWidget {
  final Vote vote;
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onVoteNow;

  const FomoAlertOverlay({
    Key? key,
    required this.vote,
    required this.message,
    this.onDismiss,
    this.onVoteNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: FomoAlertBanner(
        vote: vote,
        message: message,
        onDismiss: onDismiss,
        onVoteNow: onVoteNow,
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final DateTime deadline;
  final TextStyle? style;

  const CountdownTimer({
    Key? key,
    required this.deadline,
    this.style,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Stream<Duration> _countdownStream;

  @override
  void initState() {
    super.initState();
    _countdownStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => widget.deadline.difference(DateTime.now()),
    ).takeWhile((duration) => !duration.isNegative);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _countdownStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isNegative) {
          return Text(
            'EXPIRED',
            style: widget.style?.copyWith(color: Colors.red) ?? 
                   const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          );
        }

        final duration = snapshot.data!;
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        final seconds = duration.inSeconds % 60;

        String timeText;
        Color? textColor;

        if (hours > 0) {
          timeText = '${hours}h ${minutes}m';
          textColor = hours <= 6 ? Colors.orange : null;
        } else if (minutes > 0) {
          timeText = '${minutes}m ${seconds}s';
          textColor = minutes <= 30 ? Colors.red : Colors.orange;
        } else {
          timeText = '${seconds}s';
          textColor = Colors.red;
        }

        return Text(
          timeText,
          style: widget.style?.copyWith(color: textColor) ?? 
                 TextStyle(color: textColor, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}