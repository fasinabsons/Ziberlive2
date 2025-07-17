import 'dart:convert';
import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../core/utils/result.dart';
import '../../core/error/failures.dart';
import '../datasources/local/database_helper.dart';

class BillRepositoryImpl implements BillRepository {
  final DatabaseHelper databaseHelper;

  BillRepositoryImpl({required this.databaseHelper});

  @override
  Future<Result<Bill>> createBill(Bill bill) async {
    try {
      final db = await databaseHelper.database;
      
      await db.insert('bills', {
        'id': bill.id,
        'name': bill.name,
        'amount': bill.amount,
        'type': bill.type.name,
        'apartment_id': bill.apartmentId,
        'created_by': bill.createdBy,
        'split_user_ids_json': jsonEncode(bill.splitUserIds),
        'payment_statuses_json': jsonEncode(
          bill.paymentStatuses.map((key, value) => MapEntry(key, {
            'userId': value.userId,
            'amount': value.amount,
            'isPaid': value.isPaid,
            'paidAt': value.paidAt?.toIso8601String(),
            'paymentMethod': value.paymentMethod?.name,
          }))
        ),
        'due_date': bill.dueDate.toIso8601String(),
        'created_at': bill.createdAt.toIso8601String(),
        'is_recurring': bill.isRecurring ? 1 : 0,
        'recurrence_pattern_json': bill.recurrencePattern != null 
            ? jsonEncode({
                'type': bill.recurrencePattern!.type.name,
                'interval': bill.recurrencePattern!.interval,
                'endDate': bill.recurrencePattern!.endDate?.toIso8601String(),
              })
            : null,
      });

      return Success(bill);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to create bill: $e'));
    }
  }

  @override
  Future<Result<Bill?>> getBillById(String id) async {
    try {
      final db = await databaseHelper.database;
      
      final results = await db.query(
        'bills',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        return const Success(null);
      }

      final bill = _mapToBill(results.first);
      return Success(bill);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to get bill: $e'));
    }
  }

  @override
  Future<Result<List<Bill>>> getBillsByApartmentId(String apartmentId) async {
    try {
      final db = await databaseHelper.database;
      
      final results = await db.query(
        'bills',
        where: 'apartment_id = ?',
        whereArgs: [apartmentId],
        orderBy: 'due_date DESC',
      );

      final bills = results.map(_mapToBill).toList();
      return Success(bills);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to get bills: $e'));
    }
  }

  @override
  Future<Result<Bill>> updateBill(Bill bill) async {
    try {
      final db = await databaseHelper.database;
      
      await db.update(
        'bills',
        {
          'name': bill.name,
          'amount': bill.amount,
          'type': bill.type.name,
          'split_user_ids_json': jsonEncode(bill.splitUserIds),
          'payment_statuses_json': jsonEncode(
            bill.paymentStatuses.map((key, value) => MapEntry(key, {
              'userId': value.userId,
              'amount': value.amount,
              'isPaid': value.isPaid,
              'paidAt': value.paidAt?.toIso8601String(),
              'paymentMethod': value.paymentMethod?.name,
            }))
          ),
          'due_date': bill.dueDate.toIso8601String(),
          'is_recurring': bill.isRecurring ? 1 : 0,
          'recurrence_pattern_json': bill.recurrencePattern != null 
              ? jsonEncode({
                  'type': bill.recurrencePattern!.type.name,
                  'interval': bill.recurrencePattern!.interval,
                  'endDate': bill.recurrencePattern!.endDate?.toIso8601String(),
                })
              : null,
        },
        where: 'id = ?',
        whereArgs: [bill.id],
      );

      return Success(bill);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to update bill: $e'));
    }
  }

  @override
  Future<Result<void>> deleteBill(String id) async {
    try {
      final db = await databaseHelper.database;
      
      await db.delete(
        'bills',
        where: 'id = ?',
        whereArgs: [id],
      );

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to delete bill: $e'));
    }
  }

  @override
  Future<Result<List<Bill>>> getUnpaidBillsByUserId(String userId) async {
    try {
      final db = await databaseHelper.database;
      
      final results = await db.query(
        'bills',
        orderBy: 'due_date ASC',
      );

      final unpaidBills = <Bill>[];
      for (final result in results) {
        final bill = _mapToBill(result);
        final paymentStatus = bill.paymentStatuses[userId];
        if (paymentStatus != null && !paymentStatus.isPaid) {
          unpaidBills.add(bill);
        }
      }

      return Success(unpaidBills);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to get unpaid bills: $e'));
    }
  }

  @override
  Future<Result<List<Bill>>> getBillsByType(String apartmentId, BillType type) async {
    try {
      final db = await databaseHelper.database;
      
      final results = await db.query(
        'bills',
        where: 'apartment_id = ? AND type = ?',
        whereArgs: [apartmentId, type.name],
        orderBy: 'created_at DESC',
      );

      final bills = results.map(_mapToBill).toList();
      return Success(bills);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to get bills by type: $e'));
    }
  }

  @override
  Future<Result<void>> updatePaymentStatus(String billId, String userId, PaymentStatus status) async {
    try {
      final billResult = await getBillById(billId);
      if (billResult.isError) {
        return Error(billResult.failureOrNull!);
      }

      final bill = billResult.dataOrNull;
      if (bill == null) {
        return const Error(BillNotFoundFailure(message: 'Bill not found'));
      }

      final updatedPaymentStatuses = Map<String, PaymentStatus>.from(bill.paymentStatuses);
      updatedPaymentStatuses[userId] = status;

      final updatedBill = bill.copyWith(paymentStatuses: updatedPaymentStatuses);
      final updateResult = await updateBill(updatedBill);
      
      if (updateResult.isError) {
        return Error(updateResult.failureOrNull!);
      }

      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to update payment status: $e'));
    }
  }

  @override
  Future<Result<List<Bill>>> getRecurringBills(String apartmentId) async {
    try {
      final db = await databaseHelper.database;
      
      final results = await db.query(
        'bills',
        where: 'apartment_id = ? AND is_recurring = 1',
        whereArgs: [apartmentId],
        orderBy: 'created_at DESC',
      );

      final bills = results.map(_mapToBill).toList();
      return Success(bills);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Failed to get recurring bills: $e'));
    }
  }

  Bill _mapToBill(Map<String, dynamic> map) {
    final paymentStatusesJson = jsonDecode(map['payment_statuses_json'] as String) as Map<String, dynamic>;
    final paymentStatuses = <String, PaymentStatus>{};
    
    for (final entry in paymentStatusesJson.entries) {
      final statusMap = entry.value as Map<String, dynamic>;
      paymentStatuses[entry.key] = PaymentStatus(
        userId: statusMap['userId'] as String,
        amount: (statusMap['amount'] as num).toDouble(),
        isPaid: statusMap['isPaid'] as bool,
        paidAt: statusMap['paidAt'] != null 
            ? DateTime.parse(statusMap['paidAt'] as String)
            : null,
        paymentMethod: statusMap['paymentMethod'] != null
            ? PaymentMethod.values.firstWhere(
                (e) => e.name == statusMap['paymentMethod'],
                orElse: () => PaymentMethod.other,
              )
            : null,
      );
    }

    RecurrencePattern? recurrencePattern;
    if (map['recurrence_pattern_json'] != null) {
      final patternMap = jsonDecode(map['recurrence_pattern_json'] as String) as Map<String, dynamic>;
      recurrencePattern = RecurrencePattern(
        type: RecurrenceType.values.firstWhere(
          (e) => e.name == patternMap['type'],
        ),
        interval: patternMap['interval'] as int,
        endDate: patternMap['endDate'] != null
            ? DateTime.parse(patternMap['endDate'] as String)
            : null,
      );
    }

    return Bill(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: BillType.values.firstWhere((e) => e.name == map['type']),
      apartmentId: map['apartment_id'] as String,
      createdBy: map['created_by'] as String,
      splitUserIds: List<String>.from(jsonDecode(map['split_user_ids_json'] as String)),
      paymentStatuses: paymentStatuses,
      dueDate: DateTime.parse(map['due_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      isRecurring: (map['is_recurring'] as int) == 1,
      recurrencePattern: recurrencePattern,
    );
  }
}