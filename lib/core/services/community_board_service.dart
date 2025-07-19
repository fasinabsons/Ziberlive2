import 'dart:math';
import 'package:flutter/foundation.dart';
import '../utils/result.dart';
import '../error/failures.dart';

class CommunityBoardService {
  final List<CommunityTip> _tips = [];
  final List<CommunityEvent> _events = [];
  final List<LocalDeal> _deals = [];
  final Random _random = Random();

  // Create a new community tip
  Future<Result<CommunityTip>> createTip({
    required String userId,
    required String title,
    required String description,
    required TipCategory category,
    String? imageUrl,
  }) async {
    try {
      final tip = CommunityTip(
        id: 'tip_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: title,
        description: description,
        category: category,
        imageUrl: imageUrl,
        upvotes: 0,
        downvotes: 0,
        createdAt: DateTime.now(),
        isModerated: false,
        reportCount: 0,
      );

      _tips.add(tip);
      return Success(tip);
    } catch (e) {
      return Error(Failure('Failed to create tip: $e'));
    }
  }

  // Get all tips with optional filtering
  List<CommunityTip> getTips({
    TipCategory? category,
    String? searchQuery,
    TipSortOrder sortOrder = TipSortOrder.newest,
  }) {
    var filteredTips = _tips.where((tip) => !tip.isModerated);

    if (category != null) {
      filteredTips = filteredTips.where((tip) => tip.category == category);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredTips = filteredTips.where((tip) =>
          tip.title.toLowerCase().contains(query) ||
          tip.description.toLowerCase().contains(query));
    }

    final tipsList = filteredTips.toList();

    switch (sortOrder) {
      case TipSortOrder.newest:
        tipsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TipSortOrder.popular:
        tipsList.sort((a, b) => (b.upvotes - b.downvotes).compareTo(a.upvotes - a.downvotes));
        break;
      case TipSortOrder.trending:
        // Simple trending algorithm: recent + popular
        tipsList.sort((a, b) {
          final aScore = (a.upvotes - a.downvotes) * _getTrendingMultiplier(a.createdAt);
          final bScore = (b.upvotes - b.downvotes) * _getTrendingMultiplier(b.createdAt);
          return bScore.compareTo(aScore);
        });
        break;
    }

    return tipsList;
  }

  // Vote on a tip
  Future<Result<CommunityTip>> voteTip({
    required String tipId,
    required String userId,
    required bool isUpvote,
  }) async {
    try {
      final tipIndex = _tips.indexWhere((tip) => tip.id == tipId);
      if (tipIndex == -1) {
        return Error(Failure('Tip not found'));
      }

      final tip = _tips[tipIndex];
      CommunityTip updatedTip;

      if (isUpvote) {
        updatedTip = tip.copyWith(upvotes: tip.upvotes + 1);
      } else {
        updatedTip = tip.copyWith(downvotes: tip.downvotes + 1);
      }

      _tips[tipIndex] = updatedTip;
      return Success(updatedTip);
    } catch (e) {
      return Error(Failure('Failed to vote on tip: $e'));
    }
  }

  // Report a tip for moderation
  Future<Result<bool>> reportTip({
    required String tipId,
    required String userId,
    required String reason,
  }) async {
    try {
      final tipIndex = _tips.indexWhere((tip) => tip.id == tipId);
      if (tipIndex == -1) {
        return Error(Failure('Tip not found'));
      }

      final tip = _tips[tipIndex];
      final updatedTip = tip.copyWith(reportCount: tip.reportCount + 1);
      
      // Auto-moderate if too many reports
      if (updatedTip.reportCount >= 3) {
        _tips[tipIndex] = updatedTip.copyWith(isModerated: true);
      } else {
        _tips[tipIndex] = updatedTip;
      }

      return Success(true);
    } catch (e) {
      return Error(Failure('Failed to report tip: $e'));
    }
  }

  // Create a community event
  Future<Result<CommunityEvent>> createEvent({
    required String userId,
    required String title,
    required String description,
    required DateTime eventDate,
    required String location,
    int? maxAttendees,
  }) async {
    try {
      final event = CommunityEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: title,
        description: description,
        eventDate: eventDate,
        location: location,
        maxAttendees: maxAttendees,
        attendees: [],
        createdAt: DateTime.now(),
      );

      _events.add(event);
      return Success(event);
    } catch (e) {
      return Error(Failure('Failed to create event: $e'));
    }
  }

  // RSVP to an event
  Future<Result<CommunityEvent>> rsvpToEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final eventIndex = _events.indexWhere((event) => event.id == eventId);
      if (eventIndex == -1) {
        return Error(Failure('Event not found'));
      }

      final event = _events[eventIndex];
      
      // Check if already attending
      if (event.attendees.contains(userId)) {
        return Error(Failure('Already registered for this event'));
      }

      // Check capacity
      if (event.maxAttendees != null && event.attendees.length >= event.maxAttendees!) {
        return Error(Failure('Event is full'));
      }

      final updatedEvent = event.copyWith(
        attendees: [...event.attendees, userId],
      );

      _events[eventIndex] = updatedEvent;
      return Success(updatedEvent);
    } catch (e) {
      return Error(Failure('Failed to RSVP to event: $e'));
    }
  }

  // Get upcoming events
  List<CommunityEvent> getUpcomingEvents() {
    final now = DateTime.now();
    return _events
        .where((event) => event.eventDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  // Add a local deal
  Future<Result<LocalDeal>> addDeal({
    required String userId,
    required String title,
    required String description,
    required String storeName,
    required String discount,
    required DateTime expiryDate,
    String? imageUrl,
  }) async {
    try {
      final deal = LocalDeal(
        id: 'deal_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: title,
        description: description,
        storeName: storeName,
        discount: discount,
        expiryDate: expiryDate,
        imageUrl: imageUrl,
        upvotes: 0,
        createdAt: DateTime.now(),
      );

      _deals.add(deal);
      return Success(deal);
    } catch (e) {
      return Error(Failure('Failed to add deal: $e'));
    }
  }

  // Get active deals
  List<LocalDeal> getActiveDeals() {
    final now = DateTime.now();
    return _deals
        .where((deal) => deal.expiryDate.isAfter(now))
        .toList()
      ..sort((a, b) => b.upvotes.compareTo(a.upvotes));
  }

  double _getTrendingMultiplier(DateTime createdAt) {
    final hoursAgo = DateTime.now().difference(createdAt).inHours;
    if (hoursAgo < 24) return 1.0;
    if (hoursAgo < 72) return 0.7;
    if (hoursAgo < 168) return 0.4; // 1 week
    return 0.1;
  }

  // Initialize with some mock data
  void initializeMockData() {
    _tips.addAll([
      CommunityTip(
        id: 'tip_1',
        userId: 'user_1',
        title: 'Store X: 20% off rice this week',
        description: 'Great deal on premium basmati rice at Store X. Limited time offer!',
        category: TipCategory.deals,
        upvotes: 15,
        downvotes: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isModerated: false,
        reportCount: 0,
      ),
      CommunityTip(
        id: 'tip_2',
        userId: 'user_2',
        title: 'Best laundromat in the area',
        description: 'Clean City Laundromat has the best prices and fastest machines. Open 24/7!',
        category: TipCategory.services,
        upvotes: 8,
        downvotes: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isModerated: false,
        reportCount: 0,
      ),
      CommunityTip(
        id: 'tip_3',
        userId: 'user_3',
        title: 'Free yoga classes in the park',
        description: 'Every Sunday at 9 AM in Central Park. Bring your own mat!',
        category: TipCategory.activities,
        upvotes: 12,
        downvotes: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isModerated: false,
        reportCount: 0,
      ),
    ]);

    _events.addAll([
      CommunityEvent(
        id: 'event_1',
        userId: 'user_1',
        title: 'Movie Night: The Avengers',
        description: 'Join us for a fun movie night in the community room!',
        eventDate: DateTime.now().add(const Duration(days: 3)),
        location: 'Community Room A',
        maxAttendees: 20,
        attendees: ['user_2', 'user_3'],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);

    _deals.addAll([
      LocalDeal(
        id: 'deal_1',
        userId: 'user_1',
        title: 'Pizza Palace: Buy 1 Get 1 Free',
        description: 'Every Tuesday - buy any large pizza and get a medium pizza free!',
        storeName: 'Pizza Palace',
        discount: 'BOGO',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        upvotes: 25,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
  }
}

// Data models
class CommunityTip {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TipCategory category;
  final String? imageUrl;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;
  final bool isModerated;
  final int reportCount;

  const CommunityTip({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
    required this.isModerated,
    required this.reportCount,
  });

  CommunityTip copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TipCategory? category,
    String? imageUrl,
    int? upvotes,
    int? downvotes,
    DateTime? createdAt,
    bool? isModerated,
    int? reportCount,
  }) {
    return CommunityTip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      createdAt: createdAt ?? this.createdAt,
      isModerated: isModerated ?? this.isModerated,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}

class CommunityEvent {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final int? maxAttendees;
  final List<String> attendees;
  final DateTime createdAt;

  const CommunityEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    this.maxAttendees,
    required this.attendees,
    required this.createdAt,
  });

  CommunityEvent copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    int? maxAttendees,
    List<String>? attendees,
    DateTime? createdAt,
  }) {
    return CommunityEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      attendees: attendees ?? this.attendees,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LocalDeal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String storeName;
  final String discount;
  final DateTime expiryDate;
  final String? imageUrl;
  final int upvotes;
  final DateTime createdAt;

  const LocalDeal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.storeName,
    required this.discount,
    required this.expiryDate,
    this.imageUrl,
    required this.upvotes,
    required this.createdAt,
  });
}

enum TipCategory {
  deals,
  services,
  activities,
  general,
  safety,
  food,
}

enum TipSortOrder {
  newest,
  popular,
  trending,
}

extension TipCategoryExtension on TipCategory {
  String get displayName {
    switch (this) {
      case TipCategory.deals:
        return 'Deals & Discounts';
      case TipCategory.services:
        return 'Services';
      case TipCategory.activities:
        return 'Activities';
      case TipCategory.general:
        return 'General';
      case TipCategory.safety:
        return 'Safety';
      case TipCategory.food:
        return 'Food & Dining';
    }
  }
} 