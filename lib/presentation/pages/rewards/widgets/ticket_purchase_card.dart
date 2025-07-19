import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/lucky_draw_cubit.dart';
import '../cubit/lucky_draw_state.dart';

class TicketPurchaseCard extends StatefulWidget {
  const TicketPurchaseCard({super.key});

  @override
  State<TicketPurchaseCard> createState() => _TicketPurchaseCardState();
}

class _TicketPurchaseCardState extends State<TicketPurchaseCard> {
  int _numberOfTickets = 1;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LuckyDrawCubit, LuckyDrawState>(
      builder: (context, state) {
        if (state is! LuckyDrawLoaded) {
          return const SizedBox.shrink();
        }

        const ticketCost = 50;
        final totalCost = _numberOfTickets * ticketCost;
        final canAfford = state.coinBalance >= totalCost;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade50, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number,
                    color: Colors.purple.shade600,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lucky Draw Tickets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade800,
                          ),
                        ),
                        Text(
                          '50 coins per ticket',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.purple.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Ticket quantity selector
              Row(
                children: [
                  Text(
                    'Number of tickets:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _numberOfTickets > 1 
                            ? () => setState(() => _numberOfTickets--) 
                            : null,
                          icon: const Icon(Icons.remove),
                          color: Colors.purple.shade600,
                          iconSize: 20,
                        ),
                        Container(
                          width: 40,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '$_numberOfTickets',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _numberOfTickets < 10 
                            ? () => setState(() => _numberOfTickets++) 
                            : null,
                          icon: const Icon(Icons.add),
                          color: Colors.purple.shade600,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Cost display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Cost',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.purple.shade600,
                          ),
                        ),
                        Text(
                          '$totalCost coins',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade800,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Your Balance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.purple.shade600,
                          ),
                        ),
                        Text(
                          '${state.coinBalance} coins',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Purchase button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canAfford
                    ? () => context.read<LuckyDrawCubit>().purchaseTickets(_numberOfTickets)
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? Colors.purple.shade600 : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: canAfford ? 4 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        canAfford ? Icons.shopping_cart : Icons.error_outline,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        canAfford 
                          ? 'Purchase $_numberOfTickets Ticket${_numberOfTickets > 1 ? 's' : ''}'
                          : 'Insufficient Coins',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (!canAfford) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Earn more coins by completing tasks, voting, or watching ads!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
} 