import 'package:equatable/equatable.dart';
import 'lucky_draw_cubit.dart';

abstract class LuckyDrawState extends Equatable {
  const LuckyDrawState();

  @override
  List<Object?> get props => [];
}

class LuckyDrawInitial extends LuckyDrawState {}

class LuckyDrawLoading extends LuckyDrawState {}

class LuckyDrawLoaded extends LuckyDrawState {
  final int coinBalance;
  final List<MockLuckyDraw> upcomingDraws;
  final List<MockDrawTicket> userTickets;
  final List<MockLuckyDraw> winHistory;
  final MockAdFreeExperience? adFreeStatus;

  const LuckyDrawLoaded({
    required this.coinBalance,
    required this.upcomingDraws,
    required this.userTickets,
    required this.winHistory,
    this.adFreeStatus,
  });

  @override
  List<Object?> get props => [
    coinBalance,
    upcomingDraws,
    userTickets,
    winHistory,
    adFreeStatus,
  ];

  LuckyDrawLoaded copyWith({
    int? coinBalance,
    List<MockLuckyDraw>? upcomingDraws,
    List<MockDrawTicket>? userTickets,
    List<MockLuckyDraw>? winHistory,
    MockAdFreeExperience? adFreeStatus,
  }) {
    return LuckyDrawLoaded(
      coinBalance: coinBalance ?? this.coinBalance,
      upcomingDraws: upcomingDraws ?? this.upcomingDraws,
      userTickets: userTickets ?? this.userTickets,
      winHistory: winHistory ?? this.winHistory,
      adFreeStatus: adFreeStatus ?? this.adFreeStatus,
    );
  }
}

class LuckyDrawError extends LuckyDrawState {
  final String message;

  const LuckyDrawError(this.message);

  @override
  List<Object> get props => [message];
}

class LuckyDrawTicketsPurchased extends LuckyDrawState {
  final int numberOfTickets;

  const LuckyDrawTicketsPurchased(this.numberOfTickets);

  @override
  List<Object> get props => [numberOfTickets];
}

class LuckyDrawAdFreePurchased extends LuckyDrawState {
  const LuckyDrawAdFreePurchased();
} 