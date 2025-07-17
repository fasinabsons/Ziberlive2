import 'package:equatable/equatable.dart';

enum BillType { 
  rent, 
  electricity, 
  internet, 
  water, 
  communityCooking, 
  custom 
}

enum PaymentMethod { 
  cash, 
  bankTransfer, 
  digitalWallet, 
  other 
}

class Bill extends Equatable {
  final String id;
  final String name;
  final double amount;
  final BillType type;
  final String apartmentId;
  final String createdBy;
  final List<String> splitUserIds;
  final Map<String, PaymentStatus> paymentStatuses;
  final DateTime dueDate;
  final DateTime createdAt;
  final bool isRecurring;
  final RecurrencePattern? recurrencePattern;

  const Bill({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.apartmentId,
    required this.createdBy,
    required this.splitUserIds,
    required this.paymentStatuses,
    required this.dueDate,
    required this.createdAt,
    required this.isRecurring,
    this.recurrencePattern,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        type,
        apartmentId,
        createdBy,
        splitUserIds,
        paymentStatuses,
        dueDate,
        createdAt,
        isRecurring,
        recurrencePattern,
      ];

  Bill copyWith({
    String? id,
    String? name,
    double? amount,
    BillType? type,
    String? apartmentId,
    String? createdBy,
    List<String>? splitUserIds,
    Map<String, PaymentStatus>? paymentStatuses,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isRecurring,
    RecurrencePattern? recurrencePattern,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      apartmentId: apartmentId ?? this.apartmentId,
      createdBy: createdBy ?? this.createdBy,
      splitUserIds: splitUserIds ?? this.splitUserIds,
      paymentStatuses: paymentStatuses ?? this.paymentStatuses,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
    );
  }
}

class PaymentStatus extends Equatable {
  final String userId;
  final double amount;
  final bool isPaid;
  final DateTime? paidAt;
  final PaymentMethod? paymentMethod;

  const PaymentStatus({
    required this.userId,
    required this.amount,
    required this.isPaid,
    this.paidAt,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [
        userId,
        amount,
        isPaid,
        paidAt,
        paymentMethod,
      ];

  PaymentStatus copyWith({
    String? userId,
    double? amount,
    bool? isPaid,
    DateTime? paidAt,
    PaymentMethod? paymentMethod,
  }) {
    return PaymentStatus(
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class RecurrencePattern extends Equatable {
  final RecurrenceType type;
  final int interval;
  final DateTime? endDate;

  const RecurrencePattern({
    required this.type,
    required this.interval,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, interval, endDate];
}

enum RecurrenceType { 
  daily, 
  weekly, 
  monthly, 
  yearly 
}