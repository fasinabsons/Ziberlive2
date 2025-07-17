part of 'bill_cubit.dart';

abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillLoaded extends BillState {
  final List<Bill> bills;

  const BillLoaded(this.bills);

  @override
  List<Object> get props => [bills];
}

class BillSuccess extends BillState {
  final String message;

  const BillSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class BillError extends BillState {
  final String message;

  const BillError(this.message);

  @override
  List<Object> get props => [message];
}