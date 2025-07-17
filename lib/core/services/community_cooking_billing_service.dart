import '../utils/result.dart';
import '../error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/grocery_team.dart';

enum BillingMode { fixed, variable }

class CommunityBillingConfig {
  final BillingMode mode;
  final double fixedRate; // $100 per user for fixed mode
  final bool creditExcessAsCoLivingCredits;
  final double creditConversionRate; // 1 dollar = 100 credits

  const CommunityBillingConfig({
    required this.mode,
    required this.fixedRate,
    required this.creditExcessAsCoLivingCredits,
    this.creditConversionRate = 100.0,
  });

  CommunityBillingConfig copyWith({
    BillingMode? mode,
    double? fixedRate,
    bool? creditExcessAsCoLivingCredits,
    double? creditConversionRate,
  }) {
    return CommunityBillingConfig(
      mode: mode ?? this.mode,
      fixedRate: fixedRate ?? this.fixedRate,
      creditExcessAsCoLivingCredits: creditExcessAsCoLivingCredits ?? this.creditExcessAsCoLivingCredits,
      creditConversionRate: creditConversionRate ?? this.creditConversionRate,
    );
  }
}

class BillingCalculationResult {
  final Map<String, double> userCharges;
  final Map<String, int> creditAwards;
  final double totalSpent;
  final double totalCharged;
  final double excessAmount;
  final BillingMode mode;

  const BillingCalculationResult({
    required this.userCharges,
    required this.creditAwards,
    required this.totalSpent,
    required this.totalCharged,
    required this.excessAmount,
    required this.mode,
  });
}

class CommunityBillingService {
  /// Calculate billing for community cooking based on configuration
  Future<Result<BillingCalculationResult>> calculateBilling({
    required List<User> subscribedUsers,
    required List<GroceryExpense> expenses,
    required CommunityBillingConfig config,
  }) async {
    try {
      if (subscribedUsers.isEmpty) {
        return const Error(ValidationFailure(
          field: 'users',
          message: 'No users subscribed to community cooking',
        ));
      }

      final totalSpent = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      
      switch (config.mode) {
        case BillingMode.fixed:
          return Success(_calculateFixedBilling(
            subscribedUsers: subscribedUsers,
            totalSpent: totalSpent,
            config: config,
          ));
        case BillingMode.variable:
          return Success(_calculateVariableBilling(
            subscribedUsers: subscribedUsers,
            totalSpent: totalSpent,
            config: config,
          ));
      }
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to calculate billing: $e'));
    }
  }

  BillingCalculationResult _calculateFixedBilling({
    required List<User> subscribedUsers,
    required double totalSpent,
    required CommunityBillingConfig config,
  }) {
    final userCharges = <String, double>{};
    final creditAwards = <String, int>{};
    
    // Each user pays the fixed rate
    for (final user in subscribedUsers) {
      userCharges[user.id] = config.fixedRate;
    }
    
    final totalCharged = config.fixedRate * subscribedUsers.length;
    final excessAmount = totalCharged - totalSpent;
    
    // If there's excess and credits are enabled, award credits
    if (excessAmount > 0 && config.creditExcessAsCoLivingCredits) {
      final creditsPerUser = ((excessAmount / subscribedUsers.length) * config.creditConversionRate).round();
      for (final user in subscribedUsers) {
        creditAwards[user.id] = creditsPerUser;
      }
    }
    
    return BillingCalculationResult(
      userCharges: userCharges,
      creditAwards: creditAwards,
      totalSpent: totalSpent,
      totalCharged: totalCharged,
      excessAmount: excessAmount,
      mode: BillingMode.fixed,
    );
  }

  BillingCalculationResult _calculateVariableBilling({
    required List<User> subscribedUsers,
    required double totalSpent,
    required CommunityBillingConfig config,
  }) {
    final userCharges = <String, double>{};
    final creditAwards = <String, int>{};
    
    // Split actual cost equally among users
    final costPerUser = totalSpent / subscribedUsers.length;
    
    for (final user in subscribedUsers) {
      userCharges[user.id] = costPerUser;
    }
    
    return BillingCalculationResult(
      userCharges: userCharges,
      creditAwards: creditAwards,
      totalSpent: totalSpent,
      totalCharged: totalSpent,
      excessAmount: 0.0,
      mode: BillingMode.variable,
    );
  }

  /// Get billing summary for display
  BillingSummary getBillingSummary({
    required BillingCalculationResult result,
    required List<User> users,
  }) {
    final userSummaries = <UserBillingSummary>[];
    
    for (final user in users) {
      final charge = result.userCharges[user.id] ?? 0.0;
      final credits = result.creditAwards[user.id] ?? 0;
      
      userSummaries.add(UserBillingSummary(
        userId: user.id,
        userName: user.name,
        charge: charge,
        creditsAwarded: credits,
      ));
    }
    
    return BillingSummary(
      mode: result.mode,
      totalSpent: result.totalSpent,
      totalCharged: result.totalCharged,
      excessAmount: result.excessAmount,
      userSummaries: userSummaries,
    );
  }

  /// Calculate potential savings comparison between modes
  BillingComparison compareBillingModes({
    required List<User> subscribedUsers,
    required double totalSpent,
    required double fixedRate,
  }) {
    final fixedConfig = CommunityBillingConfig(
      mode: BillingMode.fixed,
      fixedRate: fixedRate,
      creditExcessAsCoLivingCredits: true,
    );
    
    final variableConfig = CommunityBillingConfig(
      mode: BillingMode.variable,
      fixedRate: fixedRate,
      creditExcessAsCoLivingCredits: false,
    );
    
    final fixedResult = _calculateFixedBilling(
      subscribedUsers: subscribedUsers,
      totalSpent: totalSpent,
      config: fixedConfig,
    );
    
    final variableResult = _calculateVariableBilling(
      subscribedUsers: subscribedUsers,
      totalSpent: totalSpent,
      config: variableConfig,
    );
    
    return BillingComparison(
      fixedResult: fixedResult,
      variableResult: variableResult,
      recommendedMode: _getRecommendedMode(fixedResult, variableResult),
    );
  }

  BillingMode _getRecommendedMode(
    BillingCalculationResult fixed,
    BillingCalculationResult variable,
  ) {
    // Recommend fixed if there are significant savings/credits
    if (fixed.excessAmount > 20.0) {
      return BillingMode.fixed;
    }
    
    // Recommend variable if actual cost is significantly higher than fixed
    if (variable.totalSpent > fixed.totalCharged * 1.2) {
      return BillingMode.variable;
    }
    
    // Default to fixed for predictability
    return BillingMode.fixed;
  }
}

class BillingSummary {
  final BillingMode mode;
  final double totalSpent;
  final double totalCharged;
  final double excessAmount;
  final List<UserBillingSummary> userSummaries;

  const BillingSummary({
    required this.mode,
    required this.totalSpent,
    required this.totalCharged,
    required this.excessAmount,
    required this.userSummaries,
  });
}

class UserBillingSummary {
  final String userId;
  final String userName;
  final double charge;
  final int creditsAwarded;

  const UserBillingSummary({
    required this.userId,
    required this.userName,
    required this.charge,
    required this.creditsAwarded,
  });
}

class BillingComparison {
  final BillingCalculationResult fixedResult;
  final BillingCalculationResult variableResult;
  final BillingMode recommendedMode;

  const BillingComparison({
    required this.fixedResult,
    required this.variableResult,
    required this.recommendedMode,
  });

  double get potentialSavings {
    return (fixedResult.totalCharged - variableResult.totalCharged).abs();
  }

  String get savingsDescription {
    if (fixedResult.totalCharged > variableResult.totalCharged) {
      return 'Variable billing saves \$${potentialSavings.toStringAsFixed(2)}';
    } else if (variableResult.totalCharged > fixedResult.totalCharged) {
      return 'Fixed billing saves \$${potentialSavings.toStringAsFixed(2)}';
    } else {
      return 'Both modes cost the same';
    }
  }
}