import 'package:dartz/dartz.dart';
import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';
import '../../../core/error/failures.dart';

class ManageScheduleUseCase {
  final ScheduleRepository repository;

  ManageScheduleUseCase(this.repository);

  Future<Either<Failure, Schedule>> updateSchedule(Schedule schedule) async {
    try {
      // Validate schedule data
      if (schedule.name.trim().isEmpty) {
        return Left(ValidationFailure('Schedule name cannot be empty'));
      }
      
      if (schedule.slots.isEmpty) {
        return Left(ValidationFailure('Schedule must have at least one slot'));
      }

      final result = await repository.updateSchedule(schedule);
      return result.fold(
        (failure) => Left(failure),
        (updatedSchedule) {
          _sendScheduleUpdateNotifications(updatedSchedule);
          return Right(updatedSchedule);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to update schedule: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> deleteSchedule(String scheduleId) async {
    try {
      // Get schedule first to notify users
      final scheduleResult = await repository.getScheduleById(scheduleId);
      
      final result = await repository.deleteSchedule(scheduleId);
      return result.fold(
        (failure) => Left(failure),
        (_) {
          scheduleResult.fold(
            (_) => null,
            (schedule) => _sendScheduleDeletionNotifications(schedule),
          );
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to delete schedule: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Schedule>> rotateAssignments(String scheduleId) async {
    try {
      final result = await repository.rotateScheduleAssignments(scheduleId);
      return result.fold(
        (failure) => Left(failure),
        (rotatedSchedule) {
          _sendRotationNotifications(rotatedSchedule);
          return Right(rotatedSchedule);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to rotate assignments: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> swapSlots(String slotId1, String slotId2) async {
    try {
      final result = await repository.swapScheduleSlots(slotId1, slotId2);
      return result.fold(
        (failure) => Left(failure),
        (_) {
          _sendSlotSwapNotifications(slotId1, slotId2);
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to swap slots: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> completeSlot(String slotId, String userId) async {
    try {
      final result = await repository.completeScheduleSlot(slotId, userId);
      return result.fold(
        (failure) => Left(failure),
        (_) {
          // TODO: Award credits for completion
          _awardCreditsForSlotCompletion(slotId, userId);
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to complete slot: ${e.toString()}'));
    }
  }

  Future<Either<Failure, ScheduleSlot>> updateSlot(ScheduleSlot slot) async {
    try {
      // Validate slot data
      if (slot.startTime.isAfter(slot.endTime)) {
        return Left(ValidationFailure('Start time must be before end time'));
      }
      
      if (slot.assignedUserId.isEmpty) {
        return Left(ValidationFailure('Slot must be assigned to a user'));
      }

      final result = await repository.updateScheduleSlot(slot);
      return result.fold(
        (failure) => Left(failure),
        (updatedSlot) {
          _sendSlotUpdateNotifications(updatedSlot);
          return Right(updatedSlot);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to update slot: ${e.toString()}'));
    }
  }

  void _sendScheduleUpdateNotifications(Schedule schedule) {
    // TODO: Implement notification service
    final assignedUsers = schedule.slots.map((slot) => slot.assignedUserId).toSet();
    for (final userId in assignedUsers) {
      print('Notification: Schedule "${schedule.name}" has been updated');
    }
  }

  void _sendScheduleDeletionNotifications(Schedule schedule) {
    // TODO: Implement notification service
    final assignedUsers = schedule.slots.map((slot) => slot.assignedUserId).toSet();
    for (final userId in assignedUsers) {
      print('Notification: Schedule "${schedule.name}" has been deleted');
    }
  }

  void _sendRotationNotifications(Schedule schedule) {
    // TODO: Implement notification service
    final assignedUsers = schedule.slots.map((slot) => slot.assignedUserId).toSet();
    for (final userId in assignedUsers) {
      print('Notification: Schedule "${schedule.name}" assignments have been rotated');
    }
  }

  void _sendSlotSwapNotifications(String slotId1, String slotId2) {
    // TODO: Implement notification service
    print('Notification: Schedule slots $slotId1 and $slotId2 have been swapped');
  }

  void _sendSlotUpdateNotifications(ScheduleSlot slot) {
    // TODO: Implement notification service
    print('Notification: Your schedule slot has been updated');
  }

  void _awardCreditsForSlotCompletion(String slotId, String userId) {
    // TODO: Implement gamification service to award credits
    print('Awarding credits to $userId for completing slot $slotId');
  }
}