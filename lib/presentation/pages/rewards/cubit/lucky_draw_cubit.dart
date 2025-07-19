import 'package:flutter_bloc/flutter_bloc.dart';
import 'lucky_draw_state.dart';

class LuckyDrawCubit extends Cubit<LuckyDrawState> {
  LuckyDrawCubit() : super(LuckyDrawInitial());

  void loadData() {
    emit(LuckyDrawLoading());
    
    try {
      // Mock data - in real app this would come from service
      final upcomingDraws = <MockLuckyDraw>[
        MockLuckyDraw(
          id: 'draw_1',
          title: 'Weekly T-Shirt Draw',
          reward: MockPhysicalReward(
            id: 'tshirt_1',
            name: 'ZiberLive T-Shirt',
            description: 'Official ZiberLive branded t-shirt',
            category: 'Apparel',
          ),
          scheduledDate: DateTime.now().add(const Duration(days: 3)),
          status: MockDrawStatus.scheduled,
          tickets: [],
          winnerId: null,
        ),
        MockLuckyDraw(
          id: 'draw_2',
          title: 'Monthly Hoodie Draw',
          reward: MockPhysicalReward(
            id: 'hoodie_1',
            name: 'ZiberLive Hoodie',
            description: 'Comfortable hoodie with ZiberLive branding',
            category: 'Apparel',
          ),
          scheduledDate: DateTime.now().add(const Duration(days: 7)),
          status: MockDrawStatus.scheduled,
          tickets: [],
          winnerId: null,
        ),
      ];

      final userTickets = <MockDrawTicket>[
        MockDrawTicket(
          id: 'ticket_123456789',
          userId: 'user_1',
          purchaseDate: DateTime.now().subtract(const Duration(days: 1)),
          drawId: 'draw_1',
        ),
        MockDrawTicket(
          id: 'ticket_987654321',
          userId: 'user_1',
          purchaseDate: DateTime.now().subtract(const Duration(hours: 6)),
          drawId: 'draw_2',
        ),
      ];

      final winHistory = <MockLuckyDraw>[];

      emit(LuckyDrawLoaded(
        coinBalance: 150, // Mock balance
        upcomingDraws: upcomingDraws,
        userTickets: userTickets,
        winHistory: winHistory,
        adFreeStatus: null,
      ));
    } catch (e) {
      emit(LuckyDrawError('Failed to load lucky draw data: $e'));
    }
  }

  void purchaseTickets(int numberOfTickets) {
    final currentState = state;
    if (currentState is! LuckyDrawLoaded) return;

    const ticketCost = 50;
    final totalCost = numberOfTickets * ticketCost;

    if (currentState.coinBalance < totalCost) {
      emit(LuckyDrawError('Insufficient coins. Need $totalCost coins but only have ${currentState.coinBalance}'));
      return;
    }

    try {
      // Create new tickets
      final newTickets = List.generate(numberOfTickets, (index) => 
        MockDrawTicket(
          id: 'ticket_${DateTime.now().millisecondsSinceEpoch}_$index',
          userId: 'user_1',
          purchaseDate: DateTime.now(),
          drawId: null,
        ),
      );

      // Update state
      emit(currentState.copyWith(
        coinBalance: currentState.coinBalance - totalCost,
        userTickets: [...currentState.userTickets, ...newTickets],
      ));

      emit(LuckyDrawTicketsPurchased(numberOfTickets));
      
      // Return to loaded state
      Future.delayed(const Duration(seconds: 2), () {
        if (state is LuckyDrawTicketsPurchased) {
          emit(currentState.copyWith(
            coinBalance: currentState.coinBalance - totalCost,
            userTickets: [...currentState.userTickets, ...newTickets],
          ));
        }
      });
    } catch (e) {
      emit(LuckyDrawError('Failed to purchase tickets: $e'));
    }
  }

  void purchaseAdFree() {
    final currentState = state;
    if (currentState is! LuckyDrawLoaded) return;

    const adFreeCost = 100;

    if (currentState.coinBalance < adFreeCost) {
      emit(LuckyDrawError('Insufficient coins. Need $adFreeCost coins but only have ${currentState.coinBalance}'));
      return;
    }

    try {
      final adFreeExperience = MockAdFreeExperience(
        userId: 'user_1',
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(hours: 24)),
        isActive: true,
      );

      emit(currentState.copyWith(
        coinBalance: currentState.coinBalance - adFreeCost,
        adFreeStatus: adFreeExperience,
      ));

      emit(LuckyDrawAdFreePurchased());
      
      // Return to loaded state
      Future.delayed(const Duration(seconds: 2), () {
        if (state is LuckyDrawAdFreePurchased) {
          emit(currentState.copyWith(
            coinBalance: currentState.coinBalance - adFreeCost,
            adFreeStatus: adFreeExperience,
          ));
        }
      });
    } catch (e) {
      emit(LuckyDrawError('Failed to purchase ad-free experience: $e'));
    }
  }
}

// Mock models for demonstration
class MockDrawTicket {
  final String id;
  final String userId;
  final DateTime purchaseDate;
  final String? drawId;

  const MockDrawTicket({
    required this.id,
    required this.userId,
    required this.purchaseDate,
    this.drawId,
  });
}

class MockLuckyDraw {
  final String id;
  final String title;
  final MockPhysicalReward reward;
  final DateTime scheduledDate;
  final MockDrawStatus status;
  final List<MockDrawTicket> tickets;
  final String? winnerId;
  final DateTime? completedDate;

  const MockLuckyDraw({
    required this.id,
    required this.title,
    required this.reward,
    required this.scheduledDate,
    required this.status,
    required this.tickets,
    this.winnerId,
    this.completedDate,
  });
}

class MockPhysicalReward {
  final String id;
  final String name;
  final String description;
  final String category;

  const MockPhysicalReward({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });
}

class MockAdFreeExperience {
  final String userId;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final bool isActive;

  const MockAdFreeExperience({
    required this.userId,
    required this.purchaseDate,
    required this.expiryDate,
    required this.isActive,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiryDate)) {
      return Duration.zero;
    }
    return expiryDate.difference(now);
  }
}

enum MockDrawStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
} 