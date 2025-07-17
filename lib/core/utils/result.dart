import '../error/failures.dart';

/// A generic result type that represents either success or failure
sealed class Result<T> {
  const Result();
}

/// Represents a successful result with data
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// Represents a failed result with error information
class Error<T> extends Result<T> {
  final Failure failure;
  
  const Error(this.failure);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Error(failure: $failure)';
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Returns true if this is a Success
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if this is an Error
  bool get isError => this is Error<T>;
  
  /// Returns the data if Success, null otherwise
  T? get dataOrNull => switch (this) {
    Success<T>(data: final data) => data,
    Error<T>() => null,
  };
  
  /// Returns the failure if Error, null otherwise
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(failure: final failure) => failure,
  };
  
  /// Transforms the data if Success, returns Error unchanged
  Result<R> map<R>(R Function(T) transform) => switch (this) {
    Success<T>(data: final data) => Success(transform(data)),
    Error<T>(failure: final failure) => Error(failure),
  };
  
  /// Flat maps the result
  Result<R> flatMap<R>(Result<R> Function(T) transform) => switch (this) {
    Success<T>(data: final data) => transform(data),
    Error<T>(failure: final failure) => Error(failure),
  };
  
  /// Executes the appropriate callback based on the result type
  R fold<R>(
    R Function(Failure) onError,
    R Function(T) onSuccess,
  ) => switch (this) {
    Success<T>(data: final data) => onSuccess(data),
    Error<T>(failure: final failure) => onError(failure),
  };
}