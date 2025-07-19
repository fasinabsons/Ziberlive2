import 'dart:math';
import 'package:flutter/foundation.dart';
import '../utils/result.dart';
import '../error/failures.dart';

class LuckyDrawService {
  static const int ticketCost = 50; // 50 coins per ticket
  static const int minCoinsForAdFree = 100; // 100 coins for 24h ad-free
  
  final Random _random = Random();
  
  // Mock data - in real app this would come from database
  final List<DrawTicket> _tickets = [];
  final List<LuckyDraw> _draws = [];
  final List<PhysicalReward> _availableRewards = [
    PhysicalReward(
      id: 'tshirt_1',
      name: 'ZiberLive T-Shirt',
      description: 'Official ZiberLive branded t-shirt',
      imageUrl: 'assets/images/tshirt.png',
      category: 'Apparel',
    ),
    PhysicalReward(
      id: 'mug_1',
      name: 'ZiberLive Coffee Mug',
      description: 'Premium ceramic coffee mug with ZiberLive logo',
      imageUrl: 'assets/images/mug.png',
      category: 'Drinkware',
    ),
    PhysicalReward(
      id: 'hoodie_1',
      name: 'ZiberLive Hoodie',
      description: 'Comfortable hoodie with ZiberLive branding',
      imageUrl: 'assets/images/hoodie.png',
      category: 'Apparel',
    ),
  ];

  // Purchase tickets for lucky draw
  Future<Result<List<DrawTicket>>> purchaseTickets({
    required String userId,
    required int numberOfTickets,
    required int currentCoins,
  }) async {
    try {
      final totalCost = numberOfTickets * ticketCost;
      
      if (currentCoins < totalCost) {
        return Error<List<DrawTicket>>(
          Failure('Insufficient coins. Need $totalCost coins but only have $currentCoins'),
        );
      }

      final tickets = <DrawTicket>[];
      for (int i = 0; i < numberOfTickets; i++) {
        final ticket = DrawTicket(
          id: 'ticket_${DateTime.now().millisecondsSinceEpoch}_$i',
          userId: userId,
          purchaseDate: DateTime.now(),
          drawId: null, // Will be assigned when draw is created
        );
        tickets.add(ticket);
        _tickets.add(ticket);
      }

      return Success<List<DrawTicket>>(tickets);
    } catch (e) {
      return Error<List<DrawTicket>>(Failure('Failed to purchase tickets: $e'));
    }
  }

  // Create a new lucky draw
  Future<Result<LuckyDraw>> createLuckyDraw({
    required String title,
    required DateTime scheduledDate,
    required PhysicalReward reward,
  }) async {
    try {
      final draw = LuckyDraw(
        id: 'draw_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        reward: reward,
        scheduledDate: scheduledDate,
        status: DrawStatus.scheduled,
        tickets: [],
        winnerId: null,
      );

      _draws.add(draw);
      return Success<LuckyDraw>(draw);
    } catch (e) {
      return Error<LuckyDraw>(Failure('Failed to create lucky draw: $e'));
    }
  }

  // Conduct the lucky draw
  Future<Result<DrawResult>> conductDraw(String drawId) async {
    try {
      final drawIndex = _draws.indexWhere((d) => d.id == drawId);
      if (drawIndex == -1) {
        return Error<DrawResult>(Failure('Draw not found'));
      }

      final draw = _draws[drawIndex];
      if (draw.status != DrawStatus.scheduled) {
        return Error<DrawResult>(Failure('Draw is not in scheduled status'));
      }

      // Get all tickets for this draw
      final drawTickets = _tickets.where((t) => t.drawId == drawId).toList();
      
      if (drawTickets.isEmpty) {
        return Error<DrawResult>(Failure('No tickets available for this draw'));
      }

      // Select random winner
      final winningTicket = drawTickets[_random.nextInt(drawTickets.length)];
      
      // Update draw status
      final updatedDraw = draw.copyWith(
        status: DrawStatus.completed,
        winnerId: winningTicket.userId,
        completedDate: DateTime.now(),
      );
      _draws[drawIndex] = updatedDraw;

      final result = DrawResult(
        draw: updatedDraw,
        winningTicket: winningTicket,
        totalTickets: drawTickets.length,
        participants: drawTickets.map((t) => t.userId).toSet().length,
      );

      return Success<DrawResult>(result);
    } catch (e) {
      return Error<DrawResult>(Failure('Failed to conduct draw: $e'));
    }
  }

  // Get user's tickets for a specific draw
  List<DrawTicket> getUserTickets(String userId, [String? drawId]) {
    return _tickets.where((ticket) => 
      ticket.userId == userId && 
      (drawId == null || ticket.drawId == drawId)
    ).toList();
  }

  // Get all available rewards
  List<PhysicalReward> getAvailableRewards() {
    return List.unmodifiable(_availableRewards);
  }

  // Get all draws
  List<LuckyDraw> getAllDraws() {
    return List.unmodifiable(_draws);
  }

  // Get upcoming draws
  List<LuckyDraw> getUpcomingDraws() {
    final now = DateTime.now();
    return _draws.where((draw) => 
      draw.status == DrawStatus.scheduled && 
      draw.scheduledDate.isAfter(now)
    ).toList();
  }

  // Get user's win history
  List<LuckyDraw> getUserWinHistory(String userId) {
    return _draws.where((draw) => 
      draw.winnerId == userId && 
      draw.status == DrawStatus.completed
    ).toList();
  }

  // Check if user can purchase ad-free experience
  bool canPurchaseAdFree(int currentCoins) {
    return currentCoins >= minCoinsForAdFree;
  }

  // Purchase 24-hour ad-free experience
  Future<Result<AdFreeExperience>> purchaseAdFreeExperience({
    required String userId,
    required int currentCoins,
  }) async {
    try {
      if (currentCoins < minCoinsForAdFree) {
        return Error<AdFreeExperience>(
          Failure('Insufficient coins. Need $minCoinsForAdFree coins but only have $currentCoins'),
        );
      }

      final adFreeExperience = AdFreeExperience(
        userId: userId,
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(hours: 24)),
        isActive: true,
      );

      return Success<AdFreeExperience>(adFreeExperience);
    } catch (e) {
      return Error<AdFreeExperience>(Failure('Failed to purchase ad-free experience: $e'));
    }
  }
}

// Models for lucky draw system
class DrawTicket {
  final String id;
  final String userId;
  final DateTime purchaseDate;
  final String? drawId;

  const DrawTicket({
    required this.id,
    required this.userId,
    required this.purchaseDate,
    this.drawId,
  });

  DrawTicket copyWith({
    String? id,
    String? userId,
    DateTime? purchaseDate,
    String? drawId,
  }) {
    return DrawTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      drawId: drawId ?? this.drawId,
    );
  }
}

class LuckyDraw {
  final String id;
  final String title;
  final PhysicalReward reward;
  final DateTime scheduledDate;
  final DrawStatus status;
  final List<DrawTicket> tickets;
  final String? winnerId;
  final DateTime? completedDate;

  const LuckyDraw({
    required this.id,
    required this.title,
    required this.reward,
    required this.scheduledDate,
    required this.status,
    required this.tickets,
    this.winnerId,
    this.completedDate,
  });

  LuckyDraw copyWith({
    String? id,
    String? title,
    PhysicalReward? reward,
    DateTime? scheduledDate,
    DrawStatus? status,
    List<DrawTicket>? tickets,
    String? winnerId,
    DateTime? completedDate,
  }) {
    return LuckyDraw(
      id: id ?? this.id,
      title: title ?? this.title,
      reward: reward ?? this.reward,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      winnerId: winnerId ?? this.winnerId,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

class PhysicalReward {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;

  const PhysicalReward({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
  });
}

class DrawResult {
  final LuckyDraw draw;
  final DrawTicket winningTicket;
  final int totalTickets;
  final int participants;

  const DrawResult({
    required this.draw,
    required this.winningTicket,
    required this.totalTickets,
    required this.participants,
  });
}

class AdFreeExperience {
  final String userId;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final bool isActive;

  const AdFreeExperience({
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

enum DrawStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
} 