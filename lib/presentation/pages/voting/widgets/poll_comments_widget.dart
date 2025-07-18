import 'package:flutter/material.dart';
import '../../../../domain/entities/vote.dart';

class PollCommentsWidget extends StatefulWidget {
  final Vote vote;
  final List<VoteComment> comments;
  final Function(String comment, bool isAnonymous) onAddComment;
  final Function(String commentId)? onDeleteComment;

  const PollCommentsWidget({
    Key? key,
    required this.vote,
    required this.comments,
    required this.onAddComment,
    this.onDeleteComment,
  }) : super(key: key);

  @override
  State<PollCommentsWidget> createState() => _PollCommentsWidgetState();
}

class _PollCommentsWidgetState extends State<PollCommentsWidget> {
  final _commentController = TextEditingController();
  bool _isAnonymous = false;
  bool _isExpanded = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.vote.allowComments) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              _buildCommentInput(),
              const SizedBox(height: 16),
              _buildCommentsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Row(
        children: [
          Icon(
            Icons.comment,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Comments (${widget.comments.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Share your thoughts on this poll...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value ?? false;
                        });
                      },
                    ),
                    const Text('Post anonymously'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _canPostComment() ? _postComment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (widget.comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No comments yet',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                'Be the first to share your thoughts!',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Sort comments by creation date (newest first)
    final sortedComments = List<VoteComment>.from(widget.comments);
    sortedComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${widget.comments.length})',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedComments.length,
          separatorBuilder: (context, index) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final comment = sortedComments[index];
            return _buildCommentCard(comment);
          },
        ),
      ],
    );
  }

  Widget _buildCommentCard(VoteComment comment) {
    final isCurrentUser = comment.userId == 'current_user'; // TODO: Get from context
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentUser ? Colors.blue[200]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: comment.isAnonymous 
                    ? Colors.grey 
                    : Theme.of(context).colorScheme.primary,
                child: Icon(
                  comment.isAnonymous ? Icons.person : Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.isAnonymous ? 'Anonymous' : _getUserName(comment.userId),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatCommentDate(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentUser && widget.onDeleteComment != null)
                IconButton(
                  onPressed: () => _deleteComment(comment),
                  icon: const Icon(Icons.delete, size: 16),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.comment,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  bool _canPostComment() {
    return _commentController.text.trim().isNotEmpty;
  }

  void _postComment() {
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      widget.onAddComment(commentText, _isAnonymous);
      _commentController.clear();
      setState(() {
        _isAnonymous = false;
      });
    }
  }

  void _deleteComment(VoteComment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDeleteComment?.call(comment.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getUserName(String userId) {
    // TODO: Get actual user name from user service
    return 'User $userId';
  }

  String _formatCommentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class PollCommentsDialog extends StatefulWidget {
  final Vote vote;
  final List<VoteComment> comments;
  final Function(String comment, bool isAnonymous) onAddComment;
  final Function(String commentId)? onDeleteComment;

  const PollCommentsDialog({
    Key? key,
    required this.vote,
    required this.comments,
    required this.onAddComment,
    this.onDeleteComment,
  }) : super(key: key);

  @override
  State<PollCommentsDialog> createState() => _PollCommentsDialogState();
}

class _PollCommentsDialogState extends State<PollCommentsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Comments on "${widget.vote.question}"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: PollCommentsWidget(
                vote: widget.vote,
                comments: widget.comments,
                onAddComment: widget.onAddComment,
                onDeleteComment: widget.onDeleteComment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentNotification extends StatelessWidget {
  final VoteComment comment;
  final String pollQuestion;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const CommentNotification({
    Key? key,
    required this.comment,
    required this.pollQuestion,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.comment, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New comment on poll',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pollQuestion,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.comment,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}