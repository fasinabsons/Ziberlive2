import 'package:dartz/dartz.dart';
import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';
import '../../../core/error/failures.dart';

class CreateScheduleUseCase {
  final ScheduleRepository repository;

  CreateScheduleUseCase(this.repository);

  Future<Either<Failure, Schedule>> call(Schedule schedule) async {
    try {
      // Validate schedule data
      if (schedule.name.trim().isEmpty) {
        return Left(ValidationFailure('Schedule name cannot be empty'));
      }
      
      if (schedule.slots.isEmpty) {
        return Left(ValidationFailure('Schedule must have at least one slot'));
      }
      
      if (schedule.startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        return Left(ValidationFailure('Start date cannot be in the past'));
      }
      
      // Validate slots
      for (final slot in schedule.slots) {
        if (slot.startTime.isAfter(slot.endTime)) {
          return Left(ValidationFailure('Slot start time must be before end time'));
        }
        
        if (slot.assignedUserId.isEmpty) {
          return Left(ValidationFailure('All slots must be assigned to a user'));
        }
      }
      
      // Check for overlapping slots for the same user
      final userSlots = <String, List<ScheduleSlot>>{};
      for (final slot in schedule.slots) {
        userSlots.putIfAbsent(slot.assignedUserId, () => []).add(slot);
      }
      
      for (final entry in userSlots.entries) {
        final slots = entry.value;
        for (int i = 0; i < slots.length; i++) {
          for (int j = i + 1; j < slots.length; j++) {
            if (_slotsOverlap(slots[i], slots[j])) {
              return Left(ValidationFailure(
                'User ${entry.key} has overlapping schedule slots'
              ));
            }
          }
        }
      }

      // Create the schedule
      final result = await repository.createSchedule(schedule);
      return result.fold(
        (failure) => Left(failure),
        (createdSchedule) {
          // TODO: Send notifications to assigned users
          _sendScheduleCreationNotifications(createdSchedule);
          return Right(createdSchedule);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create schedule: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Schedule>> createFromTemplate(
    String templateId,
    String apartmentId,
    DateTime startDate,
    List<String> userIds,
  ) async {
    try {
      if (userIds.isEmpty) {
        return Left(ValidationFailure('At least one user must be assigned'));
      }
      
      if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        return Left(ValidationFailure('Start date cannot be in the past'));
      }

      final result = await repository.createScheduleFromTemplate(
        templateId,
        apartmentId,
        startDate,
        userIds,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (schedule) {
          _sendScheduleCreationNotifications(schedule);
          return Right(schedule);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create schedule from template: ${e.toString()}'));
    }
  }

  bool _slotsOverlap(ScheduleSlot slot1, ScheduleSlot slot2) {
    return slot1.startTime.isBefore(slot2.endTime) && 
           slot2.startTime.isBefore(slot1.endTime);
  }

  void _sendScheduleCreationNotifications(Schedule schedule) {
    // TODO: Implement notification service
    final assignedUsers = schedule.slots.map((slot) => slot.assignedUserId).toSet();
    for (final userId in assignedUsers) {
      print('Notification: New schedule "${schedule.name}" created with assignments for $userId');
    }
  }
}