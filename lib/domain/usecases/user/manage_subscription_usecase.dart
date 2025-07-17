import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../core/utils/result.dart';
import '../../../core/error/failures.dart';
import '../../../core/permissions/permission_service.dart';
import 'package:uuid/uuid.dart';

class ManageSubscriptionUseCase {
  final UserRepository _userRepository;
  final Uuid _uuid = const Uuid();

  ManageSubscriptionUseCase(this._userRepository);

  /// Add a new subscription to a user
  Future<Result<User>> addSubscription({
    required String userId,
    required SubscriptionType subscriptionType,
    required String customName,
    required User requestingUser,
  }) async {
    // Check permissions - only admins can add subscriptions for others
    if (userId != requestingUser.id && 
        !PermissionService.canApproveSubscriptions(requestingUser)) {
      return const Error(PermissionFailure(
        message: 'Only admins can manage subscriptions for other users',
      ));
    }

    final userResult = await _userRepository.getUserById(userId);
    if (userResult is Error) {
      return Error(userResult.failure);
    }

    final user = (userResult as Success<User?>).data;
    if (user == null) {
      return const Error(UserNotFoundFailure(message: 'User not found'));
    }

    // Check if subscription already exists
    final existingSubscription = user.subscriptions.firstWhere(
      (sub) => sub.type == subscriptionType,
      orElse: () => const Subscription(
        id: '',
        type: SubscriptionType.rent,
        customName: '',
        isActive: false,
        startDate: null,
      ),
    );

    if (existingSubscription.id.isNotEmpty && existingSubscription.isActive) {
      return const Error(ValidationFailure(
        field: 'subscription',
        message: 'User already has an active subscription of this type',
      ));
    }

    // Create new subscription
    final newSubscription = Subscription(
      id: _uuid.v4(),
      type: subscriptionType,
      customName: customName,
      isActive: true,
      startDate: DateTime.now(),
    );

    // Update user subscriptions
    final updatedSubscriptions = List<Subscription>.from(user.subscriptions);
    if (existingSubscription.id.isNotEmpty) {
      // Replace existing inactive subscription
      final index = updatedSubscriptions.indexWhere((sub) => sub.id == existingSubscription.id);
      updatedSubscriptions[index] = newSubscription;
    } else {
      // Add new subscription
      updatedSubscriptions.add(newSubscription);
    }

    final updatedUser = user.copyWith(subscriptions: updatedSubscriptions);
    return await _userRepository.updateUser(updatedUser);
  }

  /// Remove/deactivate a subscription for a user
  Future<Result<User>> removeSubscription({
    required String userId,
    required SubscriptionType subscriptionType,
    required User requestingUser,
    bool requiresApproval = true,
  }) async {
    // Check permissions
    if (userId != requestingUser.id && 
        !PermissionService.canApproveSubscriptions(requestingUser)) {
      return const Error(PermissionFailure(
        message: 'Only admins can manage subscriptions for other users',
      ));
    }

    final userResult = await _userRepository.getUserById(userId);
    if (userResult is Error) {
      return Error(userResult.failure);
    }

    final user = (userResult as Success<User?>).data;
    if (user == null) {
      return const Error(UserNotFoundFailure(message: 'User not found'));
    }

    // Find the subscription to remove
    final subscriptionIndex = user.subscriptions.indexWhere(
      (sub) => sub.type == subscriptionType && sub.isActive,
    );

    if (subscriptionIndex == -1) {
      return const Error(ValidationFailure(
        field: 'subscription',
        message: 'User does not have an active subscription of this type',
      ));
    }

    // If requires approval and requesting user is not admin, create pending request
    if (requiresApproval && 
        userId == requestingUser.id && 
        !PermissionService.canApproveSubscriptions(requestingUser)) {
      // TODO: Create pending subscription change request
      return const Error(ValidationFailure(
        field: 'approval',
        message: 'Subscription change requires admin approval',
      ));
    }

    // Deactivate subscription
    final updatedSubscriptions = List<Subscription>.from(user.subscriptions);
    updatedSubscriptions[subscriptionIndex] = updatedSubscriptions[subscriptionIndex].copyWith(
      isActive: false,
      endDate: DateTime.now(),
    );

    final updatedUser = user.copyWith(subscriptions: updatedSubscriptions);
    return await _userRepository.updateUser(updatedUser);
  }

  /// Update subscription custom name
  Future<Result<User>> updateSubscriptionName({
    required String userId,
    required SubscriptionType subscriptionType,
    required String newCustomName,
    required User requestingUser,
  }) async {
    // Check permissions
    if (userId != requestingUser.id && 
        !PermissionService.canApproveSubscriptions(requestingUser)) {
      return const Error(PermissionFailure(
        message: 'Only admins can manage subscriptions for other users',
      ));
    }

    if (newCustomName.trim().isEmpty) {
      return const Error(ValidationFailure(
        field: 'customName',
        message: 'Subscription name cannot be empty',
      ));
    }

    final userResult = await _userRepository.getUserById(userId);
    if (userResult is Error) {
      return Error(userResult.failure);
    }

    final user = (userResult as Success<User?>).data;
    if (user == null) {
      return const Error(UserNotFoundFailure(message: 'User not found'));
    }

    // Find and update the subscription
    final subscriptionIndex = user.subscriptions.indexWhere(
      (sub) => sub.type == subscriptionType && sub.isActive,
    );

    if (subscriptionIndex == -1) {
      return const Error(ValidationFailure(
        field: 'subscription',
        message: 'User does not have an active subscription of this type',
      ));
    }

    final updatedSubscriptions = List<Subscription>.from(user.subscriptions);
    updatedSubscriptions[subscriptionIndex] = updatedSubscriptions[subscriptionIndex].copyWith(
      customName: newCustomName.trim(),
    );

    final updatedUser = user.copyWith(subscriptions: updatedSubscriptions);
    return await _userRepository.updateUser(updatedUser);
  }

  /// Get users by subscription type for bill splitting
  Future<Result<List<User>>> getUsersBySubscription({
    required String apartmentId,
    required SubscriptionType subscriptionType,
  }) async {
    return await _userRepository.getUsersBySubscriptionType(apartmentId, subscriptionType);
  }

  /// Get all available subscription types with their default names
  Map<SubscriptionType, String> getAvailableSubscriptions() {
    return {
      SubscriptionType.rent: 'Room Rent',
      SubscriptionType.utilities: 'Utilities',
      SubscriptionType.communityCooking: 'Community Cooking',
      SubscriptionType.drinkingWater: 'Drinking Water',
    };
  }
}