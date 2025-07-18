import 'package:dartz/dartz.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/local/database_helper.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final DatabaseHelper databaseHelper;

  ScheduleRepositoryImpl({required this.databaseHelper});

  @override
  Future<Either<Failure, Schedule>> createSchedule(Schedule schedule) async {
    try {
      final scheduleMap = schedule.toJson();
      await databaseHelper.insertSchedule(scheduleMap);
      return Right(schedule);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create schedule: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Schedule>> updateSchedule(Schedule schedule) async {
    try {
      final scheduleMap = schedule.toJson();
      await databaseHelper.updateSchedule(schedule.id, scheduleMap);
      return Right(schedule);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update schedule: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSchedule(String scheduleId) async {
    try {
      await databaseHelper.deleteSchedule(scheduleId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete schedule: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Schedule>> getScheduleById(String scheduleId) async {
    try {
      final scheduleMap = await databaseHelper.getScheduleById(scheduleId);
      if (scheduleMap == null) {
        return Left(NotFoundFailure('Schedule not found'));
      }
      final schedule = Schedule.fromJson(scheduleMap);
      return Right(schedule);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get schedule: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Schedule>>> getSchedulesByApartment(String apartmentId) async {
    try {
      final scheduleMaps = await databaseHelper.getSchedulesByApartment(apartmentId);
      final schedules = scheduleMaps.map((map) => Schedule.fromJson(map)).toList();
      return Right(schedules);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get schedules: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Schedule>>> getActiveSchedules(String apartmentId) async {
    try {
      final scheduleMaps = await databaseHelper.getActiveSchedules(apartmentId);
      final schedules = scheduleMaps.map((map) => Schedule.fromJson(map)).toList();
      return Right(schedules);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active schedules: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ScheduleSlot>> updateScheduleSlot(ScheduleSlot slot) async {
    try {
      final slotMap = slot.toJson();
      await databaseHelper.updateScheduleSlot(slot.id, slotMap);
      return Right(slot);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update schedule slot: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> completeScheduleSlot(String slotId, String userId) async {
    try {
      await databaseHelper.completeScheduleSlot(slotId, userId, DateTime.now());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to complete schedule slot: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleSlot>>> getScheduleSlotsByDateRange(
    String apartmentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final slotMaps = await databaseHelper.getScheduleSlotsByDateRange(
        apartmentId,
        startDate,
        endDate,
      );
      final slots = slotMaps.map((map) => ScheduleSlot.fromJson(map)).toList();
      return Right(slots);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get schedule slots: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleSlot>>> getScheduleSlotsByUser(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final slotMaps = await databaseHelper.getScheduleSlotsByUser(
        userId,
        startDate,
        endDate,
      );
      final slots = slotMaps.map((map) => ScheduleSlot.fromJson(map)).toList();
      return Right(slots);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get user schedule slots: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleTemplate>>> getScheduleTemplates() async {
    try {
      final templateMaps = await databaseHelper.getScheduleTemplates();
      final templates = templateMaps.map((map) => ScheduleTemplate.fromJson(map)).toList();
      return Right(templates);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get schedule templates: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ScheduleTemplate>> createScheduleTemplate(ScheduleTemplate template) async {
    try {
      final templateMap = template.toJson();
      await databaseHelper.insertScheduleTemplate(templateMap);
      return Right(template);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create schedule template: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Schedule>> createScheduleFromTemplate(
    String templateId,
    String apartmentId,
    DateTime startDate,
    List<String> userIds,
  ) async {
    try {
      // Get the template
      final templateMap = await databaseHelper.getScheduleTemplateById(templateId);
      if (templateMap == null) {
        return Left(NotFoundFailure('Schedule template not found'));
      }
      
      final template = ScheduleTemplate.fromJson(templateMap);
      
      // Generate schedule slots from template
      final slots = _generateSlotsFromTemplate(template, startDate, userIds);
      
      // Create the schedule
      final schedule = Schedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: template.name,
        type: template.type,
        apartmentId: apartmentId,
        slots: slots,
        rotationPattern: template.defaultRotationPattern,
        startDate: startDate,
        createdBy: 'system', // TODO: Get from context
        createdAt: DateTime.now(),
      );
      
      final scheduleMap = schedule.toJson();
      await databaseHelper.insertSchedule(scheduleMap);
      
      return Right(schedule);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create schedule from template: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Schedule>> rotateScheduleAssignments(String scheduleId) async {
    try {
      final scheduleMap = await databaseHelper.getScheduleById(scheduleId);
      if (scheduleMap == null) {
        return Left(NotFoundFailure('Schedule not found'));
      }
      
      final schedule = Schedule.fromJson(scheduleMap);
      final rotatedSchedule = _rotateAssignments(schedule);
      
      final updatedMap = rotatedSchedule.toJson();
      await databaseHelper.updateSchedule(scheduleId, updatedMap);
      
      return Right(rotatedSchedule);
    } catch (e) {
      return Left(DatabaseFailure('Failed to rotate schedule assignments: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> swapScheduleSlots(String slotId1, String slotId2) async {
    try {
      await databaseHelper.swapScheduleSlots(slotId1, slotId2);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to swap schedule slots: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleSlot>>> getUpcomingSlots(
    String apartmentId,
    int daysAhead,
  ) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: daysAhead));
      
      final slotMaps = await databaseHelper.getUpcomingScheduleSlots(
        apartmentId,
        now,
        endDate,
      );
      
      final slots = slotMaps.map((map) => ScheduleSlot.fromJson(map)).toList();
      return Right(slots);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get upcoming slots: ${e.toString()}'));
    }
  }

  List<ScheduleSlot> _generateSlotsFromTemplate(
    ScheduleTemplate template,
    DateTime startDate,
    List<String> userIds,
  ) {
    final slots = <ScheduleSlot>[];
    var userIndex = 0;
    
    // Generate slots for the next 4 weeks based on template
    for (int week = 0; week < 4; week++) {
      for (final slotTemplate in template.slotTemplates) {
        final slotDate = _getDateForDayOfWeek(startDate, slotTemplate.dayOfWeek, week);
        final slotStartTime = DateTime(
          slotDate.year,
          slotDate.month,
          slotDate.day,
          slotTemplate.startTime.hour,
          slotTemplate.startTime.minute,
        );
        final slotEndTime = slotStartTime.add(slotTemplate.duration);
        
        final slot = ScheduleSlot(
          id: '${template.id}_${week}_${slotTemplate.id}',
          startTime: slotStartTime,
          endTime: slotEndTime,
          assignedUserId: userIds[userIndex % userIds.length],
          description: slotTemplate.description,
          creditsAwarded: slotTemplate.creditsReward,
        );
        
        slots.add(slot);
        userIndex++;
      }
    }
    
    return slots;
  }

  DateTime _getDateForDayOfWeek(DateTime startDate, int dayOfWeek, int weekOffset) {
    final startDayOfWeek = startDate.weekday;
    final daysToAdd = (dayOfWeek - startDayOfWeek + 7) % 7 + (weekOffset * 7);
    return startDate.add(Duration(days: daysToAdd));
  }

  Schedule _rotateAssignments(Schedule schedule) {
    final slots = List<ScheduleSlot>.from(schedule.slots);
    
    if (slots.length < 2) return schedule;
    
    // Get unique user IDs
    final userIds = slots.map((slot) => slot.assignedUserId).toSet().toList();
    
    if (userIds.length < 2) return schedule;
    
    // Rotate assignments
    final rotatedSlots = slots.map((slot) {
      final currentIndex = userIds.indexOf(slot.assignedUserId);
      final nextIndex = (currentIndex + 1) % userIds.length;
      return slot.copyWith(assignedUserId: userIds[nextIndex]);
    }).toList();
    
    return schedule.copyWith(slots: rotatedSlots);
  }
}