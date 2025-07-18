import 'package:dartz/dartz.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/local/database_helper.dart';

class TaskRepositoryImpl implements TaskRepository {
  final DatabaseHelper databaseHelper;

  TaskRepositoryImpl({required this.databaseHelper});

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final taskMap = task.toJson();
      await databaseHelper.insertTask(taskMap);
      return Right(task);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final taskMap = task.toJson();
      await databaseHelper.updateTask(task.id, taskMap);
      return Right(task);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await databaseHelper.deleteTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String taskId) async {
    try {
      final taskMap = await databaseHelper.getTaskById(taskId);
      if (taskMap == null) {
        return Left(NotFoundFailure('Task not found'));
      }
      final task = Task.fromJson(taskMap);
      return Right(task);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasks(
    String apartmentId, {
    String? assignedTo,
    TaskStatus? status,
    TaskType? type,
  }) async {
    try {
      final taskMaps = await databaseHelper.getTasks(
        apartmentId,
        assignedTo: assignedTo,
        status: status?.toString().split('.').last,
        type: type?.toString().split('.').last,
      );
      
      final tasks = taskMaps.map((map) => Task.fromJson(map)).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get tasks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByUser(String userId) async {
    try {
      final taskMaps = await databaseHelper.getTasksByUser(userId);
      final tasks = taskMaps.map((map) => Task.fromJson(map)).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get user tasks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByDateRange(
    String apartmentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final taskMaps = await databaseHelper.getTasksByDateRange(
        apartmentId,
        startDate,
        endDate,
      );
      
      final tasks = taskMaps.map((map) => Task.fromJson(map)).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get tasks by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks(String apartmentId) async {
    try {
      final now = DateTime.now();
      final taskMaps = await databaseHelper.getOverdueTasks(apartmentId, now);
      final tasks = taskMaps.map((map) => Task.fromJson(map)).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get overdue tasks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getUpcomingTasks(
    String apartmentId,
    int daysAhead,
  ) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: daysAhead));
      final taskMaps = await databaseHelper.getUpcomingTasks(
        apartmentId,
        now,
        endDate,
      );
      
      final tasks = taskMaps.map((map) => Task.fromJson(map)).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get upcoming tasks: ${e.toString()}'));
    }
  }
}