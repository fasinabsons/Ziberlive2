import 'package:flutter/material.dart';
import '../../../../domain/entities/violation_report.dart';

class ViolationReportCard extends StatelessWidget {
  final ViolationReport report;
  final Function(String)? onResolve;
  final VoidCallback? onDismiss;
  final bool showActions;
  final bool isMyReport;

  const ViolationReportCard({
    Key? key,
    required this.report,
    this.onResolve,
    this.onDismiss,
    this.showActions = false,
    this.isMyReport = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildDescription(),
            const SizedBox(height: 12),
            _buildMetadata(),
            if (report.resolution != null) ...[
              const SizedBox(height: 12),
              _buildResolution(),
            ],
            if (showActions && report.status == ViolationStatus.pending) ...[
              const SizedBox(height: 16),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getSeverityColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getSeverityColor().withOpacity(0.3),
            ),
          ),
          child: Text(
            _getSeverityLabel(),
            style: TextStyle(
              color: _getSeverityColor(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor().withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(),
                size: 12,
                color: _getStatusColor(),
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusLabel(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (report.isAnonymous)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_off,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Anonymous',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
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
                Icons.description,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Report Details',
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
            report.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Column(
      children: [
        _buildMetadataRow(
          Icons.rule,
          'Rule',
          _getRuleName(),
        ),
        if (report.violatorId != null && !report.isAnonymous)
          _buildMetadataRow(
            Icons.person,
            'Reported User',
            _getUserName(report.violatorId!),
          ),
        if (!report.isAnonymous && report.reportedBy != null)
          _buildMetadataRow(
            Icons.person_outline,
            'Reported By',
            _getUserName(report.reportedBy!),
          ),
        _buildMetadataRow(
          Icons.access_time,
          'Reported',
          _formatDateTime(report.reportedAt),
        ),
        if (report.resolvedAt != null)
          _buildMetadataRow(
            Icons.check_circle,
            'Resolved',
            _formatDateTime(report.resolvedAt!),
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

  Widget _buildResolution() {
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
            report.resolution!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (report.resolvedBy != null) ...[
            const SizedBox(height: 8),
            Text(
              'Resolved by: ${_getUserName(report.resolvedBy!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showResolveDialog(context),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Resolve'),
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
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Dismiss'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  void _showResolveDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Violation Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a resolution summary:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter resolution details...',
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
              if (controller.text.trim().isNotEmpty) {
                onResolve?.call(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor() {
    switch (report.severity) {
      case ViolationSeverity.minor:
        return Colors.yellow[700]!;
      case ViolationSeverity.moderate:
        return Colors.orange[700]!;
      case ViolationSeverity.major:
        return Colors.red[700]!;
    }
  }

  String _getSeverityLabel() {
    switch (report.severity) {
      case ViolationSeverity.minor:
        return 'MINOR';
      case ViolationSeverity.moderate:
        return 'MODERATE';
      case ViolationSeverity.major:
        return 'MAJOR';
    }
  }

  Color _getStatusColor() {
    switch (report.status) {
      case ViolationStatus.pending:
        return Colors.orange;
      case ViolationStatus.underReview:
        return Colors.blue;
      case ViolationStatus.resolved:
        return Colors.green;
      case ViolationStatus.dismissed:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (report.status) {
      case ViolationStatus.pending:
        return 'PENDING';
      case ViolationStatus.underReview:
        return 'UNDER REVIEW';
      case ViolationStatus.resolved:
        return 'RESOLVED';
      case ViolationStatus.dismissed:
        return 'DISMISSED';
    }
  }

  IconData _getStatusIcon() {
    switch (report.status) {
      case ViolationStatus.pending:
        return Icons.pending;
      case ViolationStatus.underReview:
        return Icons.visibility;
      case ViolationStatus.resolved:
        return Icons.check_circle;
      case ViolationStatus.dismissed:
        return Icons.cancel;
    }
  }

  String _getRuleName() {
    // TODO: Get actual rule name from repository
    switch (report.ruleId) {
      case 'quiet_hours':
        return 'Quiet Hours (10 PM - 6 AM)';
      case 'common_area':
        return 'Common Area Cleanliness';
      case 'guest_policy':
        return 'Guest Policy';
      case 'smoking':
        return 'No Smoking Policy';
      default:
        return 'Unknown Rule';
    }
  }

  String _getUserName(String userId) {
    // TODO: Get actual user name from repository
    switch (userId) {
      case 'user1':
        return 'Alice Johnson';
      case 'user2':
        return 'Bob Smith';
      case 'user3':
        return 'Carol Davis';
      case 'user4':
        return 'David Wilson';
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