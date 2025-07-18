import 'package:dartz/dartz.dart';
import '../entities/schedule.dart';
import '../../core/error/failures.dart';

abstract class ScheduleRepository {
  // Schedule CRUD operations
  Future<Either<Failure, Schedule>> createSchedule(Schedule schedule);
  Future<Either<Failure, Schedule>> updateSchedule(Schedule schedule);
  Future<Either<Failure, void>> deleteSchedule(String scheduleId);
  Future<Either<Failure, Schedule>> getScheduleById(String scheduleId);
  Future<Either<Failure, List<Schedule>>> getSchedulesByApartment(String apartmentId);
  Future<Either<Failure, List<Schedule>>> getActiveSchedules(String apartmentId);

  // Schedule slot operations
  Future<Either<Failure, ScheduleSlot>> updateScheduleSlot(ScheduleSlot slot);
  Future<Either<Failure, void>> completeScheduleSlot(String slotId, String userId);
  Future<Either<Failure, List<ScheduleSlot>>> getScheduleSlotsByDateRange(
    String apartmentId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, List<ScheduleSlot>>> getScheduleSlotsByUser(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  // Schedule template operations
  Future<Either<Failure, List<ScheduleTemplate>>> getScheduleTemplates();
  Future<Either<Failure, ScheduleTemplate>> createScheduleTemplate(ScheduleTemplate template);
  Future<Either<Failure, Schedule>> createScheduleFromTemplate(
    String templateId,
    String apartmentId,
    DateTime startDate,
    List<String> userIds,
  );

  // Rotation and assignment operations
  Future<Either<Failure, Schedule>> rotateScheduleAssignments(String scheduleId);
  Future<Either<Failure, void>> swapScheduleSlots(String slotId1, String slotId2);
  Future<Either<Failure, List<ScheduleSlot>>> getUpcomingSlots(
    String apartmentId,
    int daysAhead,
  );
}