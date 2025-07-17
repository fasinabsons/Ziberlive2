import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/user/register_user_usecase.dart';
import '../../../../core/utils/result.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUserUseCase _registerUserUseCase;

  AuthCubit(this._registerUserUseCase) : super(AuthInitial());

  Future<void> registerUser({
    required String name,
    required String email,
    required UserRole role,
    required String apartmentId,
    String? roomId,
    String? bedId,
    List<SubscriptionType>? subscriptionTypes,
  }) async {
    emit(AuthLoading());

    final result = await _registerUserUseCase(
      name: name,
      email: email,
      role: role,
      apartmentId: apartmentId,
      roomId: roomId,
      bedId: bedId,
      subscriptionTypes: subscriptionTypes,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void reset() {
    emit(AuthInitial());
  }
}