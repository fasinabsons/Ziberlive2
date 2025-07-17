import '../entities/bill.dart';
import '../../core/utils/result.dart';
import '../../core/error/failures.dart';

abstract class BillRepository {
  Future<Result<Bill>> createBill(Bill bill);
  Future<Result<Bill?>> getBillById(String id);
  Future<Result<List<Bill>>> getBillsByApartmentId(String apartmentId);
  Future<Result<Bill>> updateBill(Bill bill);
  Future<Result<void>> deleteBill(String id);
  Future<Result<List<Bill>>> getUnpaidBillsByUserId(String userId);
  Future<Result<List<Bill>>> getBillsByType(String apartmentId, BillType type);
  Future<Result<void>> updatePaymentStatus(String billId, String userId, PaymentStatus status);
  Future<Result<List<Bill>>> getRecurringBills(String apartmentId);
}