import 'package:equatable/equatable.dart';

enum CreditReason { 
  billPayment, 
  taskCompletion, 
  voting, 
  communityParticipation,
  scheduleCompletion,
  streakBonus,
  achievement,
  ruleCompliance
}

enum AchievementType {
  taskMaster,
  streakKeeper,
  communityHelper,
  billPayer,
  voter,
  chef,
  cleaner
}

class CoLivingCredits extends Equatable {
  final String userId;
  final int totalCredits;
  final int availableCredits;
  final int spentCredits;
  final List<CreditTransaction> transactions;
  final DateTime lastUpdated;

  const CoLivingCredits({
    required this.userId,
    required this.totalCredits,
    required this.availableCredits,
    required this.spentCredits,
    required this.transactions,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        userId,
        totalCredits,
        availableCredits,
        spentCredits,
        transactions,
        lastUpdated,
      ];

  CoLivingCredits copyWith({
    String? userId,
    int? totalCredits,
    int? availableCredits,
    int? spentCredits,
    List<CreditTransaction>? transactions,
    DateTime? lastUpdated,
  }) {
    return CoLivingCredits(
      userId: userId ?? this.userId,
      totalCredits: totalCredits ?? this.totalCredits,
      availableCredits: availableCredits ?? this.availableCredits,
      spentCredits: spentCredits ?? this.spentCredits,
      transactions: transactions ?? this.transactions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_credits': totalCredits,
      'available_credits': availableCredits,
      'spent_credits': spentCredits,
      'transactions_json': transactions.map((t) => t.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory CoLivingCredits.fromJson(Map<String, dynamic> json) {
    return CoLivingCredits(
      userId: json['user_id'],
      totalCredits: json['total_credits'],
      availableCredits: json['available_credits'],
      spentCredits: json['spent_credits'],
      transactions: (json['transactions_json'] as List)
          .map((t) => CreditTransaction.fromJson(t))
          .toList(),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}

class CreditTransaction extends Equatable {
  final String id;
  final String userId;
  final int amount;
  final bool isEarned; // true for earned, false for spent
  final CreditReason reason;
  final String? description;
  final String? relatedEntityId; // task id, bill id, etc.
  final DateTime createdAt;

  const CreditTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.isEarned,
    required this.reason,
    this.description,
    this.relatedEntityId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        isEarned,
        reason,
        description,
        relatedEntityId,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'is_earned': isEarned ? 1 : 0,
      'reason': reason.toString().split('.').last,
      'description': description,
      'related_entity_id': relatedEntityId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'],
      isEarned: json['is_earned'] == 1,
      reason: CreditReason.values.firstWhere(
        (e) => e.toString().split('.').last == json['reason'],
      ),
      description: json['description'],
      relatedEntityId: json['related_entity_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CompletionStreak extends Equatable {
  final String userId;
  final String type; // 'task', 'schedule', 'bill'
  final int currentStreak;
  final int longestStreak;
  final DateTime lastCompletionDate;
  final DateTime streakStartDate;
  final bool isActive;

  const CompletionStreak({
    required this.userId,
    required this.type,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCompletionDate,
    required this.streakStartDate,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        userId,
        type,
        currentStreak,
        longestStreak,
        lastCompletionDate,
        streakStartDate,
        isActive,
      ];

  CompletionStreak copyWith({
    String? userId,
    String? type,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletionDate,
    DateTime? streakStartDate,
    bool? isActive,
  }) {
    return CompletionStreak(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_completion_date': lastCompletionDate.toIso8601String(),
      'streak_start_date': streakStartDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory CompletionStreak.fromJson(Map<String, dynamic> json) {
    return CompletionStreak(
      userId: json['user_id'],
      type: json['type'],
      currentStreak: json['current_streak'],
      longestStreak: json['longest_streak'],
      lastCompletionDate: DateTime.parse(json['last_completion_date']),
      streakStartDate: DateTime.parse(json['streak_start_date']),
      isActive: json['is_active'] == 1,
    );
  }
}

class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final int requiredCount;
  final int creditsReward;
  final String iconName;
  final bool isSystemAchievement;
  final DateTime createdAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.requiredCount,
    required this.creditsReward,
    required this.iconName,
    this.isSystemAchievement = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        requiredCount,
        creditsReward,
        iconName,
        isSystemAchievement,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'required_count': requiredCount,
      'credits_reward': creditsReward,
      'icon_name': iconName,
      'is_system_achievement': isSystemAchievement ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      requiredCount: json['required_count'],
      creditsReward: json['credits_reward'],
      iconName: json['icon_name'],
      isSystemAchievement: json['is_system_achievement'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class UserAchievement extends Equatable {
  final String id;
  final String userId;
  final String achievementId;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final DateTime createdAt;

  const UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        achievementId,
        currentProgress,
        isUnlocked,
        unlockedAt,
        createdAt,
      ];

  UserAchievement copyWith({
    String? id,
    String? userId,
    String? achievementId,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    DateTime? createdAt,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'achievement_id': achievementId,
      'current_progress': currentProgress,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'],
      userId: json['user_id'],
      achievementId: json['achievement_id'],
      currentProgress: json['current_progress'],
      isUnlocked: json['is_unlocked'] == 1,
      unlockedAt: json['unlocked_at'] != null 
          ? DateTime.parse(json['unlocked_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class GamificationStats extends Equatable {
  final String userId;
  final int totalTasksCompleted;
  final int totalBillsPaid;
  final int totalVotesCast;
  final int totalCreditsEarned;
  final int currentTaskStreak;
  final int longestTaskStreak;
  final List<UserAchievement> achievements;
  final DateTime lastUpdated;

  const GamificationStats({
    required this.userId,
    required this.totalTasksCompleted,
    required this.totalBillsPaid,
    required this.totalVotesCast,
    required this.totalCreditsEarned,
    required this.currentTaskStreak,
    required this.longestTaskStreak,
    required this.achievements,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        userId,
        totalTasksCompleted,
        totalBillsPaid,
        totalVotesCast,
        totalCreditsEarned,
        currentTaskStreak,
        longestTaskStreak,
        achievements,
        lastUpdated,
      ];

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_tasks_completed': totalTasksCompleted,
      'total_bills_paid': totalBillsPaid,
      'total_votes_cast': totalVotesCast,
      'total_credits_earned': totalCreditsEarned,
      'current_task_streak': currentTaskStreak,
      'longest_task_streak': longestTaskStreak,
      'achievements_json': achievements.map((a) => a.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory GamificationStats.fromJson(Map<String, dynamic> json) {
    return GamificationStats(
      userId: json['user_id'],
      totalTasksCompleted: json['total_tasks_completed'],
      totalBillsPaid: json['total_bills_paid'],
      totalVotesCast: json['total_votes_cast'],
      totalCreditsEarned: json['total_credits_earned'],
      currentTaskStreak: json['current_task_streak'],
      longestTaskStreak: json['longest_task_streak'],
      achievements: (json['achievements_json'] as List)
          .map((a) => UserAchievement.fromJson(a))
          .toList(),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}
// Community Tree related enums and classes
enum TreeGrowthLevel {
  seedling,
  sapling,
  youngTree,
  matureTree,
  ancientTree,
  mysticalTree,
}

enum Season {
  spring,
  summer,
  autumn,
  winter,
}

enum ContributionType {
  task,
  bill,
  vote,
  investment,
  community,
}

class CommunityContribution extends Equatable {
  final String userName;
  final int credits;
  final ContributionType type;
  final DateTime timestamp;

  const CommunityContribution({
    required this.userName,
    required this.credits,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [userName, credits, type, timestamp];
}

class CommunityTree extends Equatable {
  final String apartmentId;
  final TreeGrowthLevel level;
  final int totalCredits;
  final List<CommunityContribution> recentContributions;
  final DateTime lastUpdated;
  final Map<String, dynamic>? seasonalData;

  const CommunityTree({
    required this.apartmentId,
    required this.level,
    required this.totalCredits,
    required this.recentContributions,
    required this.lastUpdated,
    this.seasonalData,
  });

  @override
  List<Object?> get props => [
    apartmentId, level, totalCredits, recentContributions, 
    lastUpdated, seasonalData
  ];

  CommunityTree copyWith({
    String? apartmentId,
    TreeGrowthLevel? level,
    int? totalCredits,
    List<CommunityContribution>? recentContributions,
    DateTime? lastUpdated,
    Map<String, dynamic>? seasonalData,
  }) {
    return CommunityTree(
      apartmentId: apartmentId ?? this.apartmentId,
      level: level ?? this.level,
      totalCredits: totalCredits ?? this.totalCredits,
      recentContributions: recentContributions ?? this.recentContributions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      seasonalData: seasonalData ?? this.seasonalData,
    );
  }
}