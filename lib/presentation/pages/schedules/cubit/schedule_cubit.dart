import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/schedule.dart';
import '../../../../domain/entities/gamification.dart';
import '../../../../domain/usecases/schedule/get_schedules_usecase.dart';
import '../../../../domain/usecases/schedule/manage_schedule_usecase.dart';
import '../../../../core/services/gamification_service.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final GetSchedulesUseCase _getSchedulesUseCase;
  final ManageScheduleUseCase _manageScheduleUseCase;
  final GamificationService _gamificationService;
  
  String? _currentApartmentId;

  ScheduleCubit(
    this._getSchedulesUseCase,
    this._manageScheduleUseCase,
    this._gamificationService,
  ) : super(ScheduleInitial());

  void setApartmentId(String apartmentId) {
    _currentApartmentId = apartmentId;
  }

  Future<void> loadSchedules({bool activeOnly = false}) async {
    try {
      if (_currentApartmentId == null) {
        emit(const ScheduleError('Apartment ID not set'));
        return;
      }
      
      emit(ScheduleLoading());
      final result = await _getSchedulesUseCase.call(_currentApartmentId!, activeOnly: activeOnly);
      result.fold(
        (failure) => emit(ScheduleError(failure.message)),
        (schedules) => emit(SchedulesLoaded(schedules)),
      );
    } catch (e) {
      emit(ScheduleError('Failed to load schedules: $e'));
    }
  }

  Future<void> createSchedule(Schedule schedule) async {
    try {
      emit(ScheduleLoading());
      // For now, we'll use updateSchedule as a create operation
      // TODO: Implement proper createSchedule in ManageScheduleUseCase
      final result = await _manageScheduleUseCase.updateSchedule(schedule);
      result.fold(
        (failure) => emit(ScheduleError(failure.message)),
        (createdSchedule) {
          emit(ScheduleCreated(createdSchedule));
          loadSchedules(); // Refresh the list
        },
      );
    } catch (e) {
      emit(ScheduleError('Failed to create schedule: $e'));
    }
  }

  Future<void> updateSchedule(Schedule schedule) async {
    try {
      emit(ScheduleLoading());
      final result = await _manageScheduleUseCase.updateSchedule(schedule);
      result.fold(
        (failure) => emit(ScheduleError(failure.message)),
        (updatedSchedule) {
          emit(ScheduleUpdated(updatedSchedule));
          loadSchedules(); // Refresh the list
        },
      );
    } catch (e) {
      emit(ScheduleError('Failed to update schedule: $e'));
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      emit(ScheduleLoading());
      final result = await _manageScheduleUseCase.deleteSchedule(scheduleId);
      result.fold(
        (failure) => emit(ScheduleError(failure.message)),
        (_) {
          emit(ScheduleDeleted(scheduleId));
          loadSchedules(); // Refresh the list
        },
      );
    } catch (e) {
      emit(ScheduleError('Failed to delete schedule: $e'));
    }
  }

  Future<void> completeSlot(String slotId, String userId) async {
    try {
      final result = await _manageScheduleUseCase.completeSlot(slotId, userId);
      result.fold(
        (failure) => emit(ScheduleError(failure.message)),
        (_) async {
          // Award credits for completing the slot (default 5 credits)
          const creditsAwarded = 5;
          await _gamificationService.awardCredits(
            userId, 
            creditsAwarded, 
            CreditReason.scheduleCompletion,
            description: 'Schedule slot completed',
            relatedEntityId: slotId,
          );
          
          emit(SlotCompleted(slotId, creditsAwarded));
          loadSchedules(); // Refresh to show updated completion status
        },
      );
    } catch (e) {
      emit(ScheduleError('Failed to complete slot: $e'));
    }
  }

  Future<void> rotateAssignments(String scheduleId) async {
    try {
      final result = await _manageScheduleUseCase.rotateAssignments(scheduleId);
      result.fold(
        (failure) => emit(ScheduleError(failure.message)),
        (_) {
          emit(AssignmentsRotated(scheduleId));
          loadSchedules(); // Refresh to show new assignments
        },
      );
    } catch (e) {
      emit(ScheduleError('Failed to rotate assignments: $e'));
    }
  }

  Future<void> swapSlots(String slotId1, String slotId2) async {
    try {
      final result = await _manageScheduleUseCase.swapSlots(slotId1, slotId2);
      result.fold(
        (failure) => emit(ScheduleError(failure.message)),
        (_) {
          loadSchedules(); // Refresh to show updated assignments
        },
      );
    } catch (e) {
      emit(ScheduleError('Failed to swap slots: $e'));
    }
  }

  Future<void> updateSlot(ScheduleSlot slot) async {
    try {
      final result = await _manageScheduleUseCase.updateSlot(slot);
      result.fold(
        (failure) => emit(ScheduleError(failure.message)),
        (updatedSlot) {
          loadSchedules(); // Refresh to show updated slot
        },
      );
    } catch (e) {
      emit(ScheduleError('Failed to update slot: $e'));
    }
  }
}