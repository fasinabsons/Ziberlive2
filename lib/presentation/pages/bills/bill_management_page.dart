import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import 'cubit/bill_cubit.dart';
import '../../../domain/entities/bill.dart';
import '../../../domain/entities/user.dart';

class BillManagementPage extends StatefulWidget {
  const BillManagementPage({super.key});

  @override
  State<BillManagementPage> createState() => _BillManagementPageState();
}

class _BillManagementPageState extends State<BillManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<BillCubit>().loadBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<BillCubit>().loadBills(),
          ),
        ],
      ),
      body: BlocBuilder<BillCubit, BillState>(
        builder: (context, state) {
          if (state is BillLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is BillError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bills',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<BillCubit>().loadBills(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is BillLoaded) {
            if (state.bills.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No bills yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your first bill to get started',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async => context.read<BillCubit>().loadBills(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bills.length,
                itemBuilder: (context, index) {
                  final bill = state.bills[index];
                  return BillCard(
                    bill: bill,
                    onTap: () => _showBillDetails(context, bill),
                    onPaymentUpdate: (userId, status) {
                      context.read<BillCubit>().updatePaymentStatus(
                        bill.id,
                        userId,
                        status,
                      );
                    },
                  );
                },
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBillDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBillDetails(BuildContext context, Bill bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BillDetailsSheet(bill: bill),
    );
  }

  void _showCreateBillDialog(BuildContext context) {
    Navigator.pushNamed(context, '/bills/create');
  }
}

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback onTap;
  final Function(String userId, PaymentStatus status) onPaymentUpdate;

  const BillCard({
    super.key,
    required this.bill,
    required this.onTap,
    required this.onPaymentUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final totalPaid = bill.paymentStatuses.values
        .where((status) => status.isPaid)
        .length;
    final totalUsers = bill.paymentStatuses.length;
    final isOverdue = bill.dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${bill.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? AppTheme.unpaidRed.withOpacity(0.1)
                              : totalPaid == totalUsers
                                  ? AppTheme.paidGreen.withOpacity(0.1)
                                  : AppTheme.warningOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOverdue
                              ? 'OVERDUE'
                              : totalPaid == totalUsers
                                  ? 'PAID'
                                  : 'PENDING',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOverdue
                                ? AppTheme.unpaidRed
                                : totalPaid == totalUsers
                                    ? AppTheme.paidGreen
                                    : AppTheme.warningOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${_formatDate(bill.dueDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: totalUsers > 0 ? totalPaid / totalUsers : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalPaid == totalUsers
                            ? AppTheme.paidGreen
                            : AppTheme.warningOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$totalPaid/$totalUsers paid',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: bill.paymentStatuses.entries.map((entry) {
                  final status = entry.value;
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: status.isPaid
                          ? AppTheme.paidGreen
                          : AppTheme.unpaidRed,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class BillDetailsSheet extends StatelessWidget {
  final Bill bill;

  const BillDetailsSheet({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      bill.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: \$${bill.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...bill.paymentStatuses.entries.map((entry) {
                      final status = entry.value;
                      return PaymentStatusTile(
                        userId: entry.key,
                        status: status,
                        onStatusChanged: (newStatus) {
                          // Handle payment status update
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PaymentStatusTile extends StatelessWidget {
  final String userId;
  final PaymentStatus status;
  final Function(PaymentStatus) onStatusChanged;

  const PaymentStatusTile({
    super.key,
    required this.userId,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: status.isPaid
              ? AppTheme.paidGreen
              : AppTheme.unpaidRed,
          child: Icon(
            status.isPaid ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text('User $userId'), // TODO: Replace with actual user name
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${status.amount.toStringAsFixed(2)}'),
            if (status.isPaid && status.paidAt != null)
              Text(
                'Paid on ${_formatDate(status.paidAt!)}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: status.isPaid
            ? const Icon(Icons.check_circle, color: AppTheme.paidGreen)
            : TextButton(
                onPressed: () => _markAsPaid(context),
                child: const Text('Mark Paid'),
              ),
      ),
    );
  }

  void _markAsPaid(BuildContext context) {
    final newStatus = status.copyWith(
      isPaid: true,
      paidAt: DateTime.now(),
    );
    onStatusChanged(newStatus);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}