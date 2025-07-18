import 'package:dartz/dartz.dart';
import '../entities/task.dart';
import '../../core/error/failures.dart';

abstract class TaskRepository {
  Future<Either<Failure, Task>> createTask(Task task);
  Future<Either<Failure, Task>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, Task>> getTaskById(String taskId);
  Future<Either<Failure, List<Task>>> getTasks(
    String apartmentId, {
    String? assignedTo,
    TaskStatus? status,
    TaskType? type,
  });
  Future<Either<Failure, List<Task>>> getTasksByUser(String userId);
  Future<Either<Failure, List<Task>>> getTasksByDateRange(
    String apartmentId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, List<Task>>> getOverdueTasks(String apartmentId);
  Future<Either<Failure, List<Task>>> getUpcomingTasks(
    String apartmentId,
    int daysAhead,
  );
}