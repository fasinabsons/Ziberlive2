import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Database Failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
  });
}

// Network/Sync Failures
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code,
  });
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({
    required super.message,
    super.code,
  });
}

class DeviceNotFoundFailure extends Failure {
  const DeviceNotFoundFailure({
    required super.message,
    super.code,
  });
}

// Validation Failures
class ValidationFailure extends Failure {
  final String field;

  const ValidationFailure({
    required this.field,
    required super.message,
    super.code,
  });

  @override
  List<Object?> get props => [field, message, code];
}

// Permission Failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });
}

// Business Logic Failures
class InsufficientCreditsFailure extends Failure {
  final int required;
  final int available;

  const InsufficientCreditsFailure({
    required this.required,
    required this.available,
    required super.message,
    super.code,
  });

  @override
  List<Object?> get props => [required, available, message, code];
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure({
    required super.message,
    super.code,
  });
}

class BillNotFoundFailure extends Failure {
  const BillNotFoundFailure({
    required super.message,
    super.code,
  });
}

class TaskNotFoundFailure extends Failure {
  const TaskNotFoundFailure({
    required super.message,
    super.code,
  });
}

// Ad Integration Failures
class AdLoadFailure extends Failure {
  const AdLoadFailure({
    required super.message,
    super.code,
  });
}

// Encryption Failures
class EncryptionFailure extends Failure {
  const EncryptionFailure({
    required super.message,
    super.code,
  });
}