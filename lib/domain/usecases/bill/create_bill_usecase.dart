import '../../entities/bill.dart';
import '../../entities/user.dart';
import '../../repositories/bill_repository.dart';
import '../../repositories/user_repository.dart';
import '../../../core/utils/result.dart';
import '../../../core/error/failures.dart';

class CreateBillUseCase {
  final BillRepository billRepository;
  final UserRepository userRepository;

  CreateBillUseCase({
    required this.billRepository,
    required this.userRepository,
  });

  Future<Result<Bill>> execute(CreateBillParams params) async {
    try {
      // Get users for the apartment
      final usersResult = await userRepository.getUsersByApartmentId(params.apartmentId);
      if (usersResult.isError) {
        return Error(usersResult.failureOrNull!);
      }

      final users = usersResult.dataOrNull!;
      
      // Calculate bill splits based on subscriptions
      final billSplits = _calculateBillSplits(
        users: users,
        billType: params.type,
        totalAmount: params.amount,
        adminIncluded: params.includeAdmin,
      );

      if (billSplits.isEmpty) {
        return const Error(ValidationFailure(
          field: 'subscriptions',
          message: 'No users found with matching subscriptions for this bill type',
        ));
      }

      // Create payment statuses for each user
      final paymentStatuses = <String, PaymentStatus>{};
      for (final split in billSplits.entries) {
        paymentStatuses[split.key] = PaymentStatus(
          userId: split.key,
          amount: split.value,
          isPaid: false,
        );
      }

      // Create the bill
      final bill = Bill(
        id: params.id,
        name: params.name,
        amount: params.amount,
        type: params.type,
        apartmentId: params.apartmentId,
        createdBy: params.createdBy,
        splitUserIds: billSplits.keys.toList(),
        paymentStatuses: paymentStatuses,
        dueDate: params.dueDate,
        createdAt: DateTime.now(),
        isRecurring: params.isRecurring,
        recurrencePattern: params.recurrencePattern,
      );

      return await billRepository.createBill(bill);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to create bill: $e'));
    }
  }

  Map<String, double> _calculateBillSplits({
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
    final splitAmount = totalAmount / eligibleUsers.length;
    
    final splits = <String, double>{};
    for (final user in eligibleUsers) {
      splits[user.id] = splitAmount;
    }

    return splits;
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
        return null; // Custom bills can be split among all users
    }
  }
}

class CreateBillParams {
  final String id;
  final String name;
  final double amount;
  final BillType type;
  final String apartmentId;
  final String createdBy;
  final DateTime dueDate;
  final bool isRecurring;
  final RecurrencePattern? recurrencePattern;
  final bool includeAdmin;

  CreateBillParams({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.apartmentId,
    required this.createdBy,
    required this.dueDate,
    this.isRecurring = false,
    this.recurrencePattern,
    this.includeAdmin = true,
  });
}