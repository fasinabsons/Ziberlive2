import '../../domain/entities/rule.dart';
import '../../domain/entities/violation_report.dart';
import '../error/failures.dart';
import '../utils/result.dart';

abstract class RuleNotificationService {
  Future<Result<void>> notifyRuleChange(String apartmentId, Rule rule, RuleChangeType changeType);
  Future<Result<void>> notifyViolationReport(ViolationReport report);
  Future<Result<void>> notifyDisputeCreated(RuleDispute dispute);
  Future<Result<void>> notifyDisputeResolved(RuleDispute dispute);
  Future<Result<List<RuleNotification>>> getUserNotifications(String userId);
  Future<Result<void>> markNotificationAsRead(String notificationId);
  Future<Result<void>> scheduleRuleReminder(String userId, String ruleId, DateTime reminderTime);
}

class RuleNotificationServiceImpl implements RuleNotificationService {
  
  @override
  Future<Result<void>> notifyRuleChange(String apartmentId, Rule rule, RuleChangeType changeType) async {
    try {
      // Get all users in the apartment
      final apartmentUsers = await _getApartmentUsers(apartmentId);
      
      // Create notification for each user
      for (final userId in apartmentUsers) {
        final notification = RuleNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          type: RuleNotificationType.ruleChange,
          title: _getRuleChangeTitle(changeType, rule.title),
          message: _getRuleChangeMessage(changeType, rule),
          relatedEntityId: rule.id,
          isRead: false,
          createdAt: DateTime.now(),
          priority: _getRuleChangePriority(changeType),
        );
        
        await _saveNotification(notification);
        await _sendPushNotification(notification);
      }
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to notify rule change: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> notifyViolationReport(ViolationReport report) async {
    try {
      // Notify admins about the new violation report
      final adminUsers = await _getApartmentAdmins(report.apartmentId);
      
      for (final adminId in adminUsers) {
        final notification = RuleNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: adminId,
          type: RuleNotificationType.violationReport,
          title: 'New Rule Violation Report',
          message: 'A ${report.severity.name} violation has been reported${report.isAnonymous ? ' anonymously' : ''}',
          relatedEntityId: report.id,
          isRead: false,
          createdAt: DateTime.now(),
          priority: _getViolationPriority(report.severity),
        );
        
        await _saveNotification(notification);
        await _sendPushNotification(notification);
      }
      
      // Notify the violator if identified and not anonymous
      if (report.violatorId != null && !report.isAnonymous) {
        final violatorNotification = RuleNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: report.violatorId!,
          type: RuleNotificationType.violationNotice,
          title: 'Rule Violation Notice',
          message: 'You have been reported for a rule violation. Please review the community guidelines.',
          relatedEntityId: report.id,
          isRead: false,
          createdAt: DateTime.now(),
          priority: NotificationPriority.high,
        );
        
        await _saveNotification(violatorNotification);
        await _sendPushNotification(violatorNotification);
      }
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to notify violation report: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> notifyDisputeCreated(RuleDispute dispute) async {
    try {
      // Notify all apartment members about the dispute
      final apartmentUsers = await _getApartmentUsers(dispute.apartmentId);
      
      for (final userId in apartmentUsers) {
        final notification = RuleNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          type: RuleNotificationType.disputeCreated,
          title: 'Rule Dispute Created',
          message: 'A community member has disputed a rule decision. Your vote is needed.',
          relatedEntityId: dispute.id,
          isRead: false,
          createdAt: DateTime.now(),
          priority: NotificationPriority.medium,
        );
        
        await _saveNotification(notification);
        await _sendPushNotification(notification);
      }
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to notify dispute creation: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> notifyDisputeResolved(RuleDispute dispute) async {
    try {
      // Notify all apartment members about the resolution
      final apartmentUsers = await _getApartmentUsers(dispute.apartmentId);
      
      for (final userId in apartmentUsers) {
        final notification = RuleNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          type: RuleNotificationType.disputeResolved,
          title: 'Rule Dispute Resolved',
          message: 'The rule dispute has been resolved: ${dispute.resolution}',
          relatedEntityId: dispute.id,
          isRead: false,
          createdAt: DateTime.now(),
          priority: NotificationPriority.medium,
        );
        
        await _saveNotification(notification);
        await _sendPushNotification(notification);
      }
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to notify dispute resolution: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<RuleNotification>>> getUserNotifications(String userId) async {
    try {
      // TODO: Load from database
      final notifications = <RuleNotification>[
        RuleNotification(
          id: '1',
          userId: userId,
          type: RuleNotificationType.ruleChange,
          title: 'Quiet Hours Updated',
          message: 'Quiet hours have been changed to 10 PM - 7 AM',
          relatedEntityId: 'quiet_hours',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          priority: NotificationPriority.medium,
        ),
        RuleNotification(
          id: '2',
          userId: userId,
          type: RuleNotificationType.violationReport,
          title: 'Violation Report Submitted',
          message: 'Your violation report has been submitted for admin review',
          relatedEntityId: 'report_123',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          priority: NotificationPriority.low,
        ),
      ];
      
      return Success(notifications);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get notifications: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> markNotificationAsRead(String notificationId) async {
    try {
      // TODO: Update in database
      print('Marking notification $notificationId as read');
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to mark notification as read: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> scheduleRuleReminder(String userId, String ruleId, DateTime reminderTime) async {
    try {
      // TODO: Schedule local notification
      print('Scheduling rule reminder for user $userId, rule $ruleId at $reminderTime');
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to schedule reminder: ${e.toString()}'));
    }
  }
  
  // Helper methods
  
  Future<List<String>> _getApartmentUsers(String apartmentId) async {
    // TODO: Load from database
    return ['user1', 'user2', 'user3', 'admin1'];
  }
  
  Future<List<String>> _getApartmentAdmins(String apartmentId) async {
    // TODO: Load from database
    return ['admin1'];
  }
  
  Future<void> _saveNotification(RuleNotification notification) async {
    // TODO: Save to database
    print('Saving notification: ${notification.title}');
  }
  
  Future<void> _sendPushNotification(RuleNotification notification) async {
    // TODO: Send push notification
    print('Sending push notification: ${notification.title}');
  }
  
  String _getRuleChangeTitle(RuleChangeType changeType, String ruleTitle) {
    switch (changeType) {
      case RuleChangeType.created:
        return 'New Rule: $ruleTitle';
      case RuleChangeType.updated:
        return 'Rule Updated: $ruleTitle';
      case RuleChangeType.deleted:
        return 'Rule Removed: $ruleTitle';
    }
  }
  
  String _getRuleChangeMessage(RuleChangeType changeType, Rule rule) {
    switch (changeType) {
      case RuleChangeType.created:
        return 'A new rule has been added: ${rule.description}';
      case RuleChangeType.updated:
        return 'The rule has been updated: ${rule.description}';
      case RuleChangeType.deleted:
        return 'This rule has been removed from the community guidelines';
    }
  }
  
  NotificationPriority _getRuleChangePriority(RuleChangeType changeType) {
    switch (changeType) {
      case RuleChangeType.created:
        return NotificationPriority.high;
      case RuleChangeType.updated:
        return NotificationPriority.medium;
      case RuleChangeType.deleted:
        return NotificationPriority.medium;
    }
  }
  
  NotificationPriority _getViolationPriority(ViolationSeverity severity) {
    switch (severity) {
      case ViolationSeverity.minor:
        return NotificationPriority.low;
      case ViolationSeverity.moderate:
        return NotificationPriority.medium;
      case ViolationSeverity.major:
        return NotificationPriority.high;
    }
  }
}

// Data models for rule notifications and disputes

enum RuleChangeType { created, updated, deleted }

enum RuleNotificationType {
  ruleChange,
  violationReport,
  violationNotice,
  disputeCreated,
  disputeResolved,
  reminder,
}

enum NotificationPriority { low, medium, high }

enum DisputeStatus { pending, voting, resolved, dismissed }

class RuleNotification {
  final String id;
  final String userId;
  final RuleNotificationType type;
  final String title;
  final String message;
  final String? relatedEntityId;
  final bool isRead;
  final DateTime createdAt;
  final NotificationPriority priority;

  const RuleNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
    required this.priority,
  });

  RuleNotification copyWith({
    String? id,
    String? userId,
    RuleNotificationType? type,
    String? title,
    String? message,
    String? relatedEntityId,
    bool? isRead,
    DateTime? createdAt,
    NotificationPriority? priority,
  }) {
    return RuleNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
    );
  }
}

class RuleDispute {
  final String id;
  final String apartmentId;
  final String ruleId;
  final String? violationReportId;
  final String disputedBy;
  final String reason;
  final String description;
  final DisputeStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolution;
  final String? resolvedBy;
  final Map<String, bool>? votes; // userId -> vote (true = support dispute, false = dismiss)

  const RuleDispute({
    required this.id,
    required this.apartmentId,
    required this.ruleId,
    this.violationReportId,
    required this.disputedBy,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolution,
    this.resolvedBy,
    this.votes,
  });

  RuleDispute copyWith({
    String? id,
    String? apartmentId,
    String? ruleId,
    String? violationReportId,
    String? disputedBy,
    String? reason,
    String? description,
    DisputeStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolution,
    String? resolvedBy,
    Map<String, bool>? votes,
  }) {
    return RuleDispute(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      ruleId: ruleId ?? this.ruleId,
      violationReportId: violationReportId ?? this.violationReportId,
      disputedBy: disputedBy ?? this.disputedBy,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      votes: votes ?? this.votes,
    );
  }
}