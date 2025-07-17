import 'package:uuid/uuid.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../core/utils/result.dart';
import '../../../core/error/failures.dart';

class RegisterUserUseCase {
  final UserRepository _userRepository;
  final Uuid _uuid = const Uuid();

  RegisterUserUseCase(this._userRepository);

  Future<Result<User>> call({
    required String name,
    required String email,
    required UserRole role,
    required String apartmentId,
    String? roomId,
    String? bedId,
    List<SubscriptionType>? subscriptionTypes,
  }) async {
    // Validate input
    if (name.trim().isEmpty) {
      return const Error(ValidationFailure(
        field: 'name',
        message: 'Name cannot be empty',
      ));
    }

    if (email.trim().isEmpty || !_isValidEmail(email)) {
      return const Error(ValidationFailure(
        field: 'email',
        message: 'Please enter a valid email address',
      ));
    }

    // Create default subscriptions
    final defaultSubscriptions = (subscriptionTypes ?? [SubscriptionType.rent])
        .map((type) => Subscription(
              id: _uuid.v4(),
              type: type,
              customName: _getDefaultSubscriptionName(type),
              isActive: true,
              startDate: DateTime.now(),
            ))
        .toList();

    // Create user entity
    final user = User(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: role,
      apartmentId: apartmentId,
      roomId: roomId,
      bedId: bedId,
      subscriptions: defaultSubscriptions,
      coLivingCredits: 0,
      createdAt: DateTime.now(),
      lastSyncAt: DateTime.now(),
    );

    // Save user to repository
    final result = await _userRepository.createUser(user);
    
    if (result is Success) {
      // Set as current user
      await _userRepository.setCurrentUser(user);
    }
    
    return result;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _getDefaultSubscriptionName(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.communityCooking:
        return 'Community Cooking';
      case SubscriptionType.drinkingWater:
        return 'Drinking Water';
      case SubscriptionType.rent:
        return 'Room Rent';
      case SubscriptionType.utilities:
        return 'Utilities';
    }
  }
}
