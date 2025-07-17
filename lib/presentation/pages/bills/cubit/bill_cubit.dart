import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/bill.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/bill/create_bill_usecase.dart';
import '../../../../domain/repositories/bill_repository.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/result.dart';

part 'bill_state.dart';

class BillCubit extends Cubit<BillState> {
  final BillRepository _billRepository;
  final UserRepository _userRepository;
  final CreateBillUseCase _createBillUseCase;

  BillCubit()
      : _billRepository = getIt<BillRepository>(),
        _userRepository = getIt<UserRepository>(),
        _createBillUseCase = getIt<CreateBillUseCase>(),
        super(BillInitial());

  Future<void> loadBills() async {
    emit(BillLoading());

    try {
      // Get current user to determine apartment
      final currentUserResult = await _userRepository.getCurrentUser();
      if (currentUserResult is Error) {
        emit(BillError('Failed to get current user'));
        return;
      }

      final currentUser = (currentUserResult as Success<User?>).data;
      if (currentUser == null) {
        emit(BillError('No user logged in'));
        return;
      }

      // Get bills for the apartment
      final billsResult = await _billRepository.getBillsByApartmentId(currentUser.apartmentId);
      billsResult.fold(
        (failure) => emit(BillError(failure.message)),
        (bills) => emit(BillLoaded(bills)),
      );
    } catch (e) {
      emit(BillError('Failed to load bills: $e'));
    }
  }

  Future<void> createBill({
    required String name,
    required double amount,
    required BillType type,
    required DateTime dueDate,
    List<String>? specificUserIds,
    SubscriptionType? subscriptionType,
    bool isRecurring = false,
    RecurrencePattern? recurrencePattern,
  }) async {
    emit(BillLoading());

    try {
      // Get current user
      final currentUserResult = await _userRepository.getCurrentUser();
      if (currentUserResult is Error) {
        emit(BillError('Failed to get current user'));
        return;
      }

      final currentUser = (currentUserResult as Success<User?>).data;
      if (currentUser == null) {
        emit(BillError('No user logged in'));
        return;
      }

      // Create the bill
      final result = await _createBillUseCase(
        name: name,
        amount: amount,
        type: type,
        apartmentId: currentUser.apartmentId,
        createdBy: currentUser,
        dueDate: dueDate,
        specificUserIds: specificUserIds,
        subscriptionType: subscriptionType,
        isRecurring: isRecurring,
        recurrencePattern: recurrencePattern,
      );

      result.fold(
        (failure) => emit(BillError(failure.message)),
        (bill) {
          emit(const BillSuccess('Bill created successfully'));
          loadBills(); // Reload bills list
        },
      );
    } catch (e) {
      emit(BillError('Failed to create bill: $e'));
    }
  }

  Future<void> updateBill(Bill bill) async {
    emit(BillLoading());

    try {
      final result = await _billRepository.updateBill(bill);
      result.fold(
        (failure) => emit(BillError(failure.message)),
        (updatedBill) {
          emit(const BillSuccess('Bill updated successfully'));
          loadBills();
        },
      );
    } catch (e) {
      emit(BillError('Failed to update bill: $e'));
    }
  }

  Future<void> deleteBill(String billId) async {
    emit(BillLoading());

    try {
      final result = await _billRepository.deleteBill(billId);
      result.fold(
        (failure) => emit(BillError(failure.message)),
        (_) {
          emit(const BillSuccess('Bill deleted successfully'));
          loadBills();
        },
      );
    } catch (e) {
      emit(BillError('Failed to delete bill: $e'));
    }
  }

  Future<void> updatePaymentStatus(String billId, String userId, bool isPaid) async {
    try {
      // Get the bill first
      final billResult = await _billRepository.getBillById(billId);
      if (billResult is Error) {
        emit(BillError('Failed to get bill'));
        return;
      }

      final bill = (billResult as Success<Bill?>).data;
      if (bill == null) {
        emit(BillError('Bill not found'));
        return;
      }

      // Update payment status
      final currentStatus = bill.paymentStatuses[userId];
      if (currentStatus == null) {
        emit(BillError('User not found in bill'));
        return;
      }

      final updatedStatus = currentStatus.copyWith(
        isPaid: isPaid,
        paidAt: isPaid ? DateTime.now() : null,
      );

      final result = await _billRepository.updatePaymentStatus(billId, userId, updatedStatus);
      result.fold(
        (failure) => emit(BillError(failure.message)),
        (_) {
          emit(BillSuccess(isPaid ? 'Payment recorded' : 'Payment status updated'));
          loadBills();
        },
      );
    } catch (e) {
      emit(BillError('Failed to update payment status: $e'));
    }
  }

  Future<void> getBillsByType(BillType type) async {
    emit(BillLoading());

    try {
      final currentUserResult = await _userRepository.getCurrentUser();
      if (currentUserResult is Error) {
        emit(BillError('Failed to get current user'));
        return;
      }

      final currentUser = (currentUserResult as Success<User?>).data;
      if (currentUser == null) {
        emit(BillError('No user logged in'));
        return;
      }

      final result = await _billRepository.getBillsByType(currentUser.apartmentId, type);
      result.fold(
        (failure) => emit(BillError(failure.message)),
        (bills) => emit(BillLoaded(bills)),
      );
    } catch (e) {
      emit(BillError('Failed to load bills by type: $e'));
    }
  }

  Future<void> getUnpaidBills() async {
    emit(BillLoading());

    try {
      final currentUserResult = await _userRepository.getCurrentUser();
      if (currentUserResult is Error) {
        emit(BillError('Failed to get current user'));
        return;
      }

      final currentUser = (currentUserResult as Success<User?>).data;
      if (currentUser == null) {
        emit(BillError('No user logged in'));
        return;
      }

      final result = await _billRepository.getUnpaidBillsByUserId(currentUser.id);
      result.fold(
        (failure) => emit(BillError(failure.message)),
        (bills) => emit(BillLoaded(bills)),
      );
    } catch (e) {
      emit(BillError('Failed to load unpaid bills: $e'));
    }
  }
}