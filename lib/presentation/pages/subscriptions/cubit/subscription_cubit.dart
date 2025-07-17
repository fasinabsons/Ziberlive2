import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/user/manage_subscription_usecase.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/result.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final ManageSubscriptionUseCase _manageSubscriptionUseCase;
  User? _currentUser;

  SubscriptionCubit(this._manageSubscriptionUseCase) : super(SubscriptionInitial());

  Future<void> loadUserSubscriptions(String userId) async {
    emit(SubscriptionLoading());

    try {
      // Get current user for permission checking
      final userRepository = getIt<UserRepository>();
      final currentUserResult = await userRepository.getCurrentUser();
      if (currentUserResult is Success) {
        _currentUser = (currentUserResult as Success<User?>).data;
      }

      // Get target user
      final userResult = await userRepository.getUserById(userId);
      userResult.fold(
        (failure) => emit(SubscriptionError(failure.message)),
        (user) {
          if (user != null) {
            emit(SubscriptionLoaded(user));
          } else {
            emit(const SubscriptionError('User not found'));
          }
        },
      );
    } catch (e) {
      emit(SubscriptionError('Failed to load subscriptions: $e'));
    }
  }

  Future<void> addSubscription(
    String userId,
    SubscriptionType subscriptionType,
    String customName,
  ) async {
    if (_currentUser == null) {
      emit(const SubscriptionError('Authentication required'));
      return;
    }

    emit(SubscriptionLoading());

    final result = await _manageSubscriptionUseCase.addSubscription(
      userId: userId,
      subscriptionType: subscriptionType,
      customName: customName,
      requestingUser: _currentUser!,
    );

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (user) {
        emit(SubscriptionLoaded(user));
        emit(const SubscriptionSuccess('Subscription added successfully'));
      },
    );
  }

  Future<void> removeSubscription(
    String userId,
    SubscriptionType subscriptionType, {
    bool requiresApproval = true,
  }) async {
    if (_currentUser == null) {
      emit(const SubscriptionError('Authentication required'));
      return;
    }

    emit(SubscriptionLoading());

    final result = await _manageSubscriptionUseCase.removeSubscription(
      userId: userId,
      subscriptionType: subscriptionType,
      requestingUser: _currentUser!,
      requiresApproval: requiresApproval,
    );

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (user) {
        emit(SubscriptionLoaded(user));
        if (requiresApproval && userId == _currentUser!.id) {
          emit(const SubscriptionSuccess('Deactivation request sent for admin approval'));
        } else {
          emit(const SubscriptionSuccess('Subscription deactivated successfully'));
        }
      },
    );
  }

  Future<void> updateSubscriptionName(
    String userId,
    SubscriptionType subscriptionType,
    String newCustomName,
  ) async {
    if (_currentUser == null) {
      emit(const SubscriptionError('Authentication required'));
      return;
    }

    emit(SubscriptionLoading());

    final result = await _manageSubscriptionUseCase.updateSubscriptionName(
      userId: userId,
      subscriptionType: subscriptionType,
      newCustomName: newCustomName,
      requestingUser: _currentUser!,
    );

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (user) {
        emit(SubscriptionLoaded(user));
        emit(const SubscriptionSuccess('Subscription name updated successfully'));
      },
    );
  }

  Future<void> refreshSubscriptions(String userId) async {
    await loadUserSubscriptions(userId);
  }
}