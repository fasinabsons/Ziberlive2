import 'package:dartz/dartz.dart';
import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';
import '../../../core/error/failures.dart';

class GetSchedulesUseCase {
  final ScheduleRepository repository;

  GetSchedulesUseCase(this.repository);

  Future<Either<Failure, List<Schedule>>> call(String apartmentId, {bool activeOnly = false}) async {
    try {
      final result = activeOnly 
          ? await repository.getActiveSchedules(apartmentId)
          : await repository.getSchedulesByApartment(apartmentId);
      
      return result.fold(
        (failure) => Left(failure),
        (schedules) {
          // Sort schedules by start date (most recent first)
          final sortedSchedules = List<Schedule>.from(schedules);
          sortedSchedules.sort((a, b) => b.startDate.compareTo(a.startDate));
          return Right(sortedSchedules);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get schedules: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Schedule>> getScheduleById(String scheduleId) async {
    try {
      final result = await repository.getScheduleById(scheduleId);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to get schedule: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<ScheduleSlot>>> getScheduleSlotsByDateRange(
    String apartmentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await repository.getScheduleSlotsByDateRange(
        apartmentId,
        startDate,
        endDate,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (slots) {
          // Sort slots by start time
          final sortedSlots = List<ScheduleSlot>.from(slots);
          sortedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
          return Right(sortedSlots);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get schedule slots: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<ScheduleSlot>>> getMyScheduleSlots(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await repository.getScheduleSlotsByUser(
        userId,
        startDate,
        endDate,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (slots) {
          // Sort by start time and prioritize upcoming slots
          final sortedSlots = List<ScheduleSlot>.from(slots);
          final now = DateTime.now();
          
          sortedSlots.sort((a, b) {
            // Prioritize upcoming slots over past ones
            final aUpcoming = a.startTime.isAfter(now);
            final bUpcoming = b.startTime.isAfter(now);
            
            if (aUpcoming && !bUpcoming) return -1;
            if (!aUpcoming && bUpcoming) return 1;
            
            return a.startTime.compareTo(b.startTime);
          });
          
          return Right(sortedSlots);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get user schedule slots: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<ScheduleSlot>>> getUpcomingSlots(
    String apartmentId,
    int daysAhead,
  ) async {
    try {
      final result = await repository.getUpcomingSlots(apartmentId, daysAhead);
      
      return result.fold(
        (failure) => Left(failure),
        (slots) {
          // Sort by start time
          final sortedSlots = List<ScheduleSlot>.from(slots);
          sortedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
          return Right(sortedSlots);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get upcoming slots: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<ScheduleTemplate>>> getScheduleTemplates() async {
    try {
      final result = await repository.getScheduleTemplates();
      
      return result.fold(
        (failure) => Left(failure),
        (templates) {
          // Sort templates by name
          final sortedTemplates = List<ScheduleTemplate>.from(templates);
          sortedTemplates.sort((a, b) => a.name.compareTo(b.name));
          return Right(sortedTemplates);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get schedule templates: ${e.toString()}'));
    }
  }
}