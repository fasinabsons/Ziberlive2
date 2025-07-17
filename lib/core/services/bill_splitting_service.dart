import '../utils/result.dart';
import '../error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/bill.dart';

class BillSplittingService {
  /// Recalculates bill splits when users join or leave
  Future<Result<Map<String, double>>> recalculateBillSplits({
    required Bill bill,
    required List<User> currentUsers,
    required bool adminIncluded,
  }) async {
    try {
      final newSplits = calculateBillSplits(
        users: currentUsers,
        billType: bill.type,
        totalAmount: bill.amount,
        adminIncluded: adminIncluded,
      );

      if (newSplits.isEmpty) {
        return const Error(ValidationFailure(
          field: 'users',
          message: 'No eligible users found for bill splitting',
        ));
      }

      return Success(newSplits);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to recalculate bill splits: $e'));
    }
  }

  /// Calculates custom split ratios for specific scenarios
  Map<String, double> calculateCustomSplits({
    required List<User> users,
    required double totalAmount,
    required Map<String, double> customRatios,
  }) {
    final splits = <String, double>{};
    
    // Validate that ratios sum to 1.0
    final totalRatio = customRatios.values.fold(0.0, (sum, ratio) => sum + ratio);
    if ((totalRatio - 1.0).abs() > 0.01) {
      throw ArgumentError('Custom ratios must sum to 1.0');
    }

    for (final user in users) {
      final ratio = customRatios[user.id] ?? 0.0;
      if (ratio > 0) {
        splits[user.id] = totalAmount * ratio;
      }
    }

    return splits;
  }

  /// Core bill splitting algorithm
  Map<String, double> calculateBillSplits({
    required List<User> users,
    required BillType billType,
    required double totalAmount,
    required bool adminIncluded,
  }) {
    // Filter users based on subscription type and admin inclusion
    final eligibleUsers = users.where((user) {
      // Check if admin should be included
      if (user.role == UserRole.roommateAdmin && !adminIncluded) {
        return false;
      }

      // Check if user has matching subscription
      return _hasMatchingSubscription(user, billType);
    }).toList();

    if (eligibleUsers.isEmpty) {
      return {};
    }

    // Calculate equal split
    final splitAmount = _roundToTwoDecimals(totalAmount / eligibleUsers.length);
    
    final splits = <String, double>{};
    double totalAssigned = 0.0;

    // Assign equal amounts to all but the last user
    for (int i = 0; i < eligibleUsers.length - 1; i++) {
      splits[eligibleUsers[i].id] = splitAmount;
      totalAssigned += splitAmount;
    }

    // Assign remaining amount to last user to handle rounding
    if (eligibleUsers.isNotEmpty) {
      final lastUserId = eligibleUsers.last.id;
      splits[lastUserId] = _roundToTwoDecimals(totalAmount - totalAssigned);
    }

    return splits;
  }

  /// Calculates the impact of a user joining or leaving
  BillSplitImpact calculateSplitImpact({
    required Bill originalBill,
    required List<User> newUsers,
    required bool adminIncluded,
  }) {
    final originalSplits = originalBill.paymentStatuses.map(
      (userId, status) => MapEntry(userId, status.amount),
    );

    final newSplits = calculateBillSplits(
      users: newUsers,
      billType: originalBill.type,
      totalAmount: originalBill.amount,
      adminIncluded: adminIncluded,
    );

    final changedUsers = <String>[];
    final newlyIncluded = <String>[];
    final removed = <String>[];

    // Find newly included users
    for (final userId in newSplits.keys) {
      if (!originalSplits.containsKey(userId)) {
        newlyIncluded.add(userId);
      }
    }

    // Find removed users
    for (final userId in originalSplits.keys) {
      if (!newSplits.containsKey(userId)) {
        removed.add(userId);
      }
    }

    // Find users with changed amounts
    for (final entry in newSplits.entries) {
      final userId = entry.key;
      final newAmount = entry.value;
      final originalAmount = originalSplits[userId];
      
      if (originalAmount != null && (originalAmount - newAmount).abs() > 0.01) {
        changedUsers.add(userId);
      }
    }

    return BillSplitImpact(
      originalSplits: originalSplits,
      newSplits: newSplits,
      changedUsers: changedUsers,
      newlyIncluded: newlyIncluded,
      removed: removed,
    );
  }

  bool _hasMatchingSubscription(User user, BillType billType) {
    final requiredSubscriptionType = _mapBillTypeToSubscription(billType);
    if (requiredSubscriptionType == null) {
      return true; // For custom bills, include all users
    }

    return user.subscriptions.any((subscription) =>
        subscription.type == requiredSubscriptionType && subscription.isActive);
  }

  SubscriptionType? _mapBillTypeToSubscription(BillType billType) {
    switch (billType) {
      case BillType.rent:
        return SubscriptionType.rent;
      case BillType.electricity:
      case BillType.internet:
        return SubscriptionType.utilities;
      case BillType.water:
        return SubscriptionType.drinkingWater;
      case BillType.communityCooking:
        return SubscriptionType.communityCooking;
      case BillType.custom:
        return null;
    }
  }

  double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}

class BillSplitImpact {
  final Map<String, double> originalSplits;
  final Map<String, double> newSplits;
  final List<String> changedUsers;
  final List<String> newlyIncluded;
  final List<String> removed;

  BillSplitImpact({
    required this.originalSplits,
    required this.newSplits,
    required this.changedUsers,
    required this.newlyIncluded,
    required this.removed,
  });

  bool get hasChanges => 
      changedUsers.isNotEmpty || 
      newlyIncluded.isNotEmpty || 
      removed.isNotEmpty;
}