import '../../domain/entities/rule.dart';
import '../../domain/entities/violation_report.dart';
import '../../domain/entities/gamification.dart';
import '../error/failures.dart';
import '../utils/result.dart';
import 'gamification_service.dart';

abstract class RuleComplianceService {
  Future<Result<RuleComplianceStats>> getUserComplianceStats(String userId);
  Future<Result<List<RuleComplianceRecord>>> getUserComplianceHistory(String userId);
  Future<Result<void>> recordRuleCompliance(String userId, String ruleId, bool isCompliant);
  Future<Result<void>> processViolationReport(ViolationReport report);
  Future<Result<ComplianceRewards>> calculateComplianceRewards(String userId);
  Future<Result<List<RuleComplianceStats>>> getApartmentComplianceStats(String apartmentId);
}

class RuleComplianceServiceImpl implements RuleComplianceService {
  final GamificationService _gamificationService;
  
  RuleComplianceServiceImpl(this._gamificationService);
  
  @override
  Future<Result<RuleComplianceStats>> getUserComplianceStats(String userId) async {
    try {
      // TODO: Load from database
      // For now, return mock data
      final stats = RuleComplianceStats(
        userId: userId,
        totalRulesTracked: 5,
        complianceRate: 0.85,
        violationsCount: 2,
        consecutiveComplianceDays: 14,
        longestComplianceStreak: 30,
        lastViolationDate: DateTime.now().subtract(const Duration(days: 7)),
        complianceByRule: {
          'quiet_hours': 0.90,
          'common_area': 0.80,
          'guest_policy': 1.0,
          'smoking': 1.0,
          'noise_level': 0.75,
        },
        lastUpdated: DateTime.now(),
      );
      
      return Success(stats);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get compliance stats: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<RuleComplianceRecord>>> getUserComplianceHistory(String userId) async {
    try {
      // TODO: Load from database
      final history = <RuleComplianceRecord>[
        RuleComplianceRecord(
          id: '1',
          userId: userId,
          ruleId: 'quiet_hours',
          isCompliant: true,
          recordedAt: DateTime.now().subtract(const Duration(days: 1)),
          notes: 'Maintained quiet hours',
        ),
        RuleComplianceRecord(
          id: '2',
          userId: userId,
          ruleId: 'common_area',
          isCompliant: false,
          recordedAt: DateTime.now().subtract(const Duration(days: 3)),
          notes: 'Left dishes in sink',
          violationReportId: 'violation_123',
        ),
      ];
      
      return Success(history);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get compliance history: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> recordRuleCompliance(String userId, String ruleId, bool isCompliant) async {
    try {
      // Create compliance record
      final record = RuleComplianceRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        ruleId: ruleId,
        isCompliant: isCompliant,
        recordedAt: DateTime.now(),
        notes: isCompliant ? 'Rule followed' : 'Rule violation detected',
      );
      
      // TODO: Save to database
      await _saveComplianceRecord(record);
      
      // Update compliance stats
      await _updateComplianceStats(userId, ruleId, isCompliant);
      
      // Award credits for compliance
      if (isCompliant) {
        await _awardComplianceCredits(userId, ruleId);
      }
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to record compliance: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> processViolationReport(ViolationReport report) async {
    try {
      // Record non-compliance for the violator
      if (report.violatorId != null) {
        await recordRuleCompliance(report.violatorId!, report.ruleId, false);
      }
      
      // Award credits to reporter for community participation
      if (report.reportedBy != null && !report.isAnonymous) {
        await _gamificationService.awardCredits(
          report.reportedBy!,
          5, // 5 credits for reporting violations
          CreditReason.communityParticipation,
          description: 'Reported rule violation',
          relatedEntityId: report.id,
        );
      }
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to process violation report: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<ComplianceRewards>> calculateComplianceRewards(String userId) async {
    try {
      final statsResult = await getUserComplianceStats(userId);
      
      return statsResult.fold(
        (failure) => Error(failure),
        (stats) async {
          final rewards = ComplianceRewards(
            userId: userId,
            weeklyComplianceBonus: _calculateWeeklyBonus(stats),
            streakBonus: _calculateStreakBonus(stats),
            perfectComplianceBonus: _calculatePerfectComplianceBonus(stats),
            totalRewards: 0,
            calculatedAt: DateTime.now(),
          );
          
          final totalRewards = rewards.weeklyComplianceBonus + 
                              rewards.streakBonus + 
                              rewards.perfectComplianceBonus;
          
          final finalRewards = rewards.copyWith(totalRewards: totalRewards);
          
          return Success(finalRewards);
        },
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to calculate rewards: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<RuleComplianceStats>>> getApartmentComplianceStats(String apartmentId) async {
    try {
      // TODO: Load all users in apartment and their compliance stats
      final apartmentStats = <RuleComplianceStats>[];
      
      return Success(apartmentStats);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get apartment stats: ${e.toString()}'));
    }
  }
  
  // Helper methods
  
  Future<void> _saveComplianceRecord(RuleComplianceRecord record) async {
    // TODO: Save to database
    print('Saving compliance record: ${record.userId} - ${record.ruleId} - ${record.isCompliant}');
  }
  
  Future<void> _updateComplianceStats(String userId, String ruleId, bool isCompliant) async {
    // TODO: Update user's compliance statistics
    print('Updating compliance stats for user $userId, rule $ruleId: $isCompliant');
  }
  
  Future<void> _awardComplianceCredits(String userId, String ruleId) async {
    // Award base compliance credits
    await _gamificationService.awardCredits(
      userId,
      2, // 2 credits per rule compliance
      CreditReason.ruleCompliance,
      description: 'Rule compliance: ${_getRuleName(ruleId)}',
      relatedEntityId: ruleId,
    );
    
    // Check for streak bonuses
    final statsResult = await getUserComplianceStats(userId);
    statsResult.fold(
      (failure) => null,
      (stats) async {
        if (stats.consecutiveComplianceDays > 0 && stats.consecutiveComplianceDays % 7 == 0) {
          // Weekly streak bonus
          await _gamificationService.awardCredits(
            userId,
            stats.consecutiveComplianceDays ~/ 7 * 5, // 5 credits per week
            CreditReason.streakBonus,
            description: 'Rule compliance streak: ${stats.consecutiveComplianceDays} days',
          );
        }
      },
    );
  }
  
  int _calculateWeeklyBonus(RuleComplianceStats stats) {
    if (stats.complianceRate >= 0.9) {
      return 20; // High compliance bonus
    } else if (stats.complianceRate >= 0.8) {
      return 10; // Good compliance bonus
    }
    return 0;
  }
  
  int _calculateStreakBonus(RuleComplianceStats stats) {
    if (stats.consecutiveComplianceDays >= 30) {
      return 50; // Monthly streak bonus
    } else if (stats.consecutiveComplianceDays >= 14) {
      return 25; // Bi-weekly streak bonus
    } else if (stats.consecutiveComplianceDays >= 7) {
      return 10; // Weekly streak bonus
    }
    return 0;
  }
  
  int _calculatePerfectComplianceBonus(RuleComplianceStats stats) {
    return stats.complianceRate == 1.0 ? 30 : 0;
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
      case 'noise_level':
        return 'Noise Level';
      default:
        return 'Unknown Rule';
    }
  }
}

// Data models for rule compliance

class RuleComplianceStats {
  final String userId;
  final int totalRulesTracked;
  final double complianceRate;
  final int violationsCount;
  final int consecutiveComplianceDays;
  final int longestComplianceStreak;
  final DateTime? lastViolationDate;
  final Map<String, double> complianceByRule;
  final DateTime lastUpdated;

  const RuleComplianceStats({
    required this.userId,
    required this.totalRulesTracked,
    required this.complianceRate,
    required this.violationsCount,
    required this.consecutiveComplianceDays,
    required this.longestComplianceStreak,
    this.lastViolationDate,
    required this.complianceByRule,
    required this.lastUpdated,
  });

  RuleComplianceStats copyWith({
    String? userId,
    int? totalRulesTracked,
    double? complianceRate,
    int? violationsCount,
    int? consecutiveComplianceDays,
    int? longestComplianceStreak,
    DateTime? lastViolationDate,
    Map<String, double>? complianceByRule,
    DateTime? lastUpdated,
  }) {
    return RuleComplianceStats(
      userId: userId ?? this.userId,
      totalRulesTracked: totalRulesTracked ?? this.totalRulesTracked,
      complianceRate: complianceRate ?? this.complianceRate,
      violationsCount: violationsCount ?? this.violationsCount,
      consecutiveComplianceDays: consecutiveComplianceDays ?? this.consecutiveComplianceDays,
      longestComplianceStreak: longestComplianceStreak ?? this.longestComplianceStreak,
      lastViolationDate: lastViolationDate ?? this.lastViolationDate,
      complianceByRule: complianceByRule ?? this.complianceByRule,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class RuleComplianceRecord {
  final String id;
  final String userId;
  final String ruleId;
  final bool isCompliant;
  final DateTime recordedAt;
  final String? notes;
  final String? violationReportId;

  const RuleComplianceRecord({
    required this.id,
    required this.userId,
    required this.ruleId,
    required this.isCompliant,
    required this.recordedAt,
    this.notes,
    this.violationReportId,
  });

  RuleComplianceRecord copyWith({
    String? id,
    String? userId,
    String? ruleId,
    bool? isCompliant,
    DateTime? recordedAt,
    String? notes,
    String? violationReportId,
  }) {
    return RuleComplianceRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ruleId: ruleId ?? this.ruleId,
      isCompliant: isCompliant ?? this.isCompliant,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
      violationReportId: violationReportId ?? this.violationReportId,
    );
  }
}

class ComplianceRewards {
  final String userId;
  final int weeklyComplianceBonus;
  final int streakBonus;
  final int perfectComplianceBonus;
  final int totalRewards;
  final DateTime calculatedAt;

  const ComplianceRewards({
    required this.userId,
    required this.weeklyComplianceBonus,
    required this.streakBonus,
    required this.perfectComplianceBonus,
    required this.totalRewards,
    required this.calculatedAt,
  });

  ComplianceRewards copyWith({
    String? userId,
    int? weeklyComplianceBonus,
    int? streakBonus,
    int? perfectComplianceBonus,
    int? totalRewards,
    DateTime? calculatedAt,
  }) {
    return ComplianceRewards(
      userId: userId ?? this.userId,
      weeklyComplianceBonus: weeklyComplianceBonus ?? this.weeklyComplianceBonus,
      streakBonus: streakBonus ?? this.streakBonus,
      perfectComplianceBonus: perfectComplianceBonus ?? this.perfectComplianceBonus,
      totalRewards: totalRewards ?? this.totalRewards,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}