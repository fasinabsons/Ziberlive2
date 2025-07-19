import 'package:flutter/material.dart';
import '../../../../core/services/reward_coin_service.dart';

class CoinTransactionCard extends StatelessWidget {
  final CoinTransaction transaction;

  const CoinTransactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isEarned 
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          child: Icon(
            transaction.isEarned ? Icons.add : Icons.remove,
            color: transaction.isEarned ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getReasonLabel(transaction.reason),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateTime(transaction.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  transaction.isEarned ? '+' : '-',
                  style: TextStyle(
                    color: transaction.isEarned ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${transaction.amount}',
                  style: TextStyle(
                    color: transaction.isEarned ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 16,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getReasonColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getReasonBadge(transaction.reason),
                style: TextStyle(
                  fontSize: 10,
                  color: _getReasonColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReasonLabel(CoinEarnReason reason) {
    switch (reason) {
      case CoinEarnReason.adViewing:
        return 'Advertisement';
      case CoinEarnReason.taskCompletion:
        return 'Task Completion';
      case CoinEarnReason.voting:
        return 'Voting Participation';
      case CoinEarnReason.dailyBonus:
        return 'Daily Bonus';
      case CoinEarnReason.streakBonus:
        return 'Streak Bonus';
      case CoinEarnReason.achievement:
        return 'Achievement';
    }
  }

  String _getReasonBadge(CoinEarnReason reason) {
    switch (reason) {
      case CoinEarnReason.adViewing:
        return 'AD';
      case CoinEarnReason.taskCompletion:
        return 'TASK';
      case CoinEarnReason.voting:
        return 'VOTE';
      case CoinEarnReason.dailyBonus:
        return 'DAILY';
      case CoinEarnReason.streakBonus:
        return 'STREAK';
      case CoinEarnReason.achievement:
        return 'ACHIEVE';
    }
  }

  Color _getReasonColor() {
    switch (transaction.reason) {
      case CoinEarnReason.adViewing:
        return Colors.blue;
      case CoinEarnReason.taskCompletion:
        return Colors.green;
      case CoinEarnReason.voting:
        return Colors.purple;
      case CoinEarnReason.dailyBonus:
        return Colors.orange;
      case CoinEarnReason.streakBonus:
        return Colors.red;
      case CoinEarnReason.achievement:
        return Colors.amber;
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