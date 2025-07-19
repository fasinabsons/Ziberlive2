import '../../domain/entities/violation_report.dart';
import '../error/failures.dart';
import '../utils/result.dart';
import 'rule_notification_service.dart';

abstract class RuleDisputeService {
  Future<Result<RuleDispute>> createDispute(
    String apartmentId,
    String ruleId,
    String disputedBy,
    String reason,
    String description, {
    String? violationReportId,
  });
  
  Future<Result<void>> castDisputeVote(String disputeId, String userId, bool supportDispute);
  Future<Result<RuleDispute>> resolveDispute(String disputeId, String resolvedBy);
  Future<Result<List<RuleDispute>>> getApartmentDisputes(String apartmentId);
  Future<Result<List<RuleDispute>>> getUserDisputes(String userId);
  Future<Result<RuleDispute>> getDisputeById(String disputeId);
}

class RuleDisputeServiceImpl implements RuleDisputeService {
  final RuleNotificationService _notificationService;
  
  RuleDisputeServiceImpl(this._notificationService);
  
  @override
  Future<Result<RuleDispute>> createDispute(
    String apartmentId,
    String ruleId,
    String disputedBy,
    String reason,
    String description, {
    String? violationReportId,
  }) async {
    try {
      final dispute = RuleDispute(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        apartmentId: apartmentId,
        ruleId: ruleId,
        violationReportId: violationReportId,
        disputedBy: disputedBy,
        reason: reason,
        description: description,
        status: DisputeStatus.pending,
        createdAt: DateTime.now(),
        votes: {},
      );
      
      // Save dispute to database
      await _saveDispute(dispute);
      
      // Notify apartment members
      await _notificationService.notifyDisputeCreated(dispute);
      
      // Start voting period (automatically move to voting status)
      final votingDispute = dispute.copyWith(status: DisputeStatus.voting);
      await _saveDispute(votingDispute);
      
      return Success(votingDispute);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to create dispute: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> castDisputeVote(String disputeId, String userId, bool supportDispute) async {
    try {
      final disputeResult = await getDisputeById(disputeId);
      
      return disputeResult.fold(
        (failure) => Error(failure),
        (dispute) async {
          if (dispute.status != DisputeStatus.voting) {
            return Error(ValidationFailure(
              field: 'status',
              message: 'Dispute is not in voting status',
            ));
          }
          
          // Update votes
          final updatedVotes = Map<String, bool>.from(dispute.votes ?? {});
          updatedVotes[userId] = supportDispute;
          
          final updatedDispute = dispute.copyWith(votes: updatedVotes);
          await _saveDispute(updatedDispute);
          
          // Check if voting is complete
          await _checkVotingCompletion(updatedDispute);
          
          return Success(null);
        },
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to cast vote: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<RuleDispute>> resolveDispute(String disputeId, String resolvedBy) async {
    try {
      final disputeResult = await getDisputeById(disputeId);
      
      return disputeResult.fold(
        (failure) => Error(failure),
        (dispute) async {
          if (dispute.status == DisputeStatus.resolved) {
            return Error(ValidationFailure(
              field: 'status',
              message: 'Dispute is already resolved',
            ));
          }
          
          // Calculate voting results
          final votes = dispute.votes ?? {};
          final supportVotes = votes.values.where((vote) => vote).length;
          final opposeVotes = votes.values.where((vote) => !vote).length;
          
          String resolution;
          if (supportVotes > opposeVotes) {
            resolution = 'Dispute upheld by community vote ($supportVotes support, $opposeVotes oppose)';
          } else {
            resolution = 'Dispute dismissed by community vote ($supportVotes support, $opposeVotes oppose)';
          }
          
          final resolvedDispute = dispute.copyWith(
            status: DisputeStatus.resolved,
            resolvedAt: DateTime.now(),
            resolution: resolution,
            resolvedBy: resolvedBy,
          );
          
          await _saveDispute(resolvedDispute);
          
          // Notify apartment members of resolution
          await _notificationService.notifyDisputeResolved(resolvedDispute);
          
          return Success(resolvedDispute);
        },
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to resolve dispute: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<RuleDispute>>> getApartmentDisputes(String apartmentId) async {
    try {
      // TODO: Load from database
      final disputes = <RuleDispute>[
        RuleDispute(
          id: '1',
          apartmentId: apartmentId,
          ruleId: 'quiet_hours',
          disputedBy: 'user1',
          reason: 'Unfair enforcement',
          description: 'The quiet hours rule is being enforced inconsistently',
          status: DisputeStatus.voting,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          votes: {
            'user1': true,
            'user2': false,
            'user3': true,
          },
        ),
        RuleDispute(
          id: '2',
          apartmentId: apartmentId,
          ruleId: 'guest_policy',
          disputedBy: 'user2',
          reason: 'Rule too restrictive',
          description: 'The guest policy is too restrictive for normal social activities',
          status: DisputeStatus.resolved,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
          resolution: 'Dispute dismissed by community vote (2 support, 5 oppose)',
          resolvedBy: 'admin1',
          votes: {
            'user1': false,
            'user2': true,
            'user3': false,
            'user4': false,
            'admin1': false,
          },
        ),
      ];
      
      return Success(disputes);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get apartment disputes: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<RuleDispute>>> getUserDisputes(String userId) async {
    try {
      final apartmentDisputes = await getApartmentDisputes('current_apartment'); // TODO: Get user's apartment
      
      return apartmentDisputes.fold(
        (failure) => Error(failure),
        (disputes) => Success(
          disputes.where((dispute) => dispute.disputedBy == userId).toList(),
        ),
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get user disputes: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<RuleDispute>> getDisputeById(String disputeId) async {
    try {
      // TODO: Load from database
      // For now, return mock data
      final dispute = RuleDispute(
        id: disputeId,
        apartmentId: 'apt_001',
        ruleId: 'quiet_hours',
        disputedBy: 'user1',
        reason: 'Unfair enforcement',
        description: 'The quiet hours rule is being enforced inconsistently',
        status: DisputeStatus.voting,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        votes: {
          'user1': true,
          'user2': false,
          'user3': true,
        },
      );
      
      return Success(dispute);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get dispute: ${e.toString()}'));
    }
  }
  
  // Helper methods
  
  Future<void> _saveDispute(RuleDispute dispute) async {
    // TODO: Save to database
    print('Saving dispute: ${dispute.id} - ${dispute.status.name}');
  }
  
  Future<void> _checkVotingCompletion(RuleDispute dispute) async {
    // Get total apartment members
    final totalMembers = await _getApartmentMemberCount(dispute.apartmentId);
    final votesCount = dispute.votes?.length ?? 0;
    
    // Check if majority has voted (more than 50% of members)
    if (votesCount > totalMembers / 2) {
      // Auto-resolve if voting period is complete
      await resolveDispute(dispute.id, 'system');
    }
  }
  
  Future<int> _getApartmentMemberCount(String apartmentId) async {
    // TODO: Get actual count from database
    return 5; // Mock count
  }
}