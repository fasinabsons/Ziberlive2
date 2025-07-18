import 'package:equatable/equatable.dart';

enum VoteType { singleChoice, multipleChoice, yesNo, rating }

class Vote extends Equatable {
  final String id;
  final String question;
  final String description;
  final VoteType type;
  final List<VoteOption> options;
  final String apartmentId;
  final String createdBy;
  final DateTime deadline;
  final bool isAnonymous;
  final bool allowComments;
  final Map<String, UserVote> votes;
  final VoteStatus status;
  final DateTime createdAt;
  final DateTime? closedAt;
  final Map<String, dynamic>? metadata;

  const Vote({
    required this.id,
    required this.question,
    required this.description,
    required this.type,
    required this.options,
    required this.apartmentId,
    required this.createdBy,
    required this.deadline,
    this.isAnonymous = false,
    this.allowComments = true,
    required this.votes,
    required this.status,
    required this.createdAt,
    this.closedAt,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        question,
        description,
        type,
        options,
        apartmentId,
        createdBy,
        deadline,
        isAnonymous,
        allowComments,
        votes,
        status,
        createdAt,
        closedAt,
        metadata,
      ];

  Vote copyWith({
    String? id,
    String? question,
    String? description,
    VoteType? type,
    List<VoteOption>? options,
    String? apartmentId,
    String? createdBy,
    DateTime? deadline,
    bool? isAnonymous,
    bool? allowComments,
    Map<String, UserVote>? votes,
    VoteStatus? status,
    DateTime? createdAt,
    DateTime? closedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Vote(
      id: id ?? this.id,
      question: question ?? this.question,
      description: description ?? this.description,
      type: type ?? this.type,
      options: options ?? this.options,
      apartmentId: apartmentId ?? this.apartmentId,
      createdBy: createdBy ?? this.createdBy,
      deadline: deadline ?? this.deadline,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      allowComments: allowComments ?? this.allowComments,
      votes: votes ?? this.votes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'description': description,
      'type': type.toString().split('.').last,
      'options_json': options.map((option) => option.toJson()).toList(),
      'apartment_id': apartmentId,
      'created_by': createdBy,
      'deadline': deadline.toIso8601String(),
      'is_anonymous': isAnonymous ? 1 : 0,
      'allow_comments': allowComments ? 1 : 0,
      'votes_json': votes.map((key, value) => MapEntry(key, value.toJson())),
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'metadata_json': metadata,
    };
  }

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'],
      question: json['question'],
      description: json['description'],
      type: VoteType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      options: (json['options_json'] as List)
          .map((option) => VoteOption.fromJson(option))
          .toList(),
      apartmentId: json['apartment_id'],
      createdBy: json['created_by'],
      deadline: DateTime.parse(json['deadline']),
      isAnonymous: json['is_anonymous'] == 1,
      allowComments: json['allow_comments'] == 1,
      votes: (json['votes_json'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, UserVote.fromJson(value)),
      ),
      status: VoteStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['created_at']),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
      metadata: json['metadata_json'],
    );
  }

  // Helper methods
  int get totalVotes => votes.length;
  
  int get totalEligibleVoters {
    // TODO: Get from apartment user count
    return metadata?['eligible_voters'] ?? 10;
  }
  
  double get participationRate => totalEligibleVoters > 0 
      ? totalVotes / totalEligibleVoters 
      : 0.0;
  
  bool get isActive => status == VoteStatus.active && DateTime.now().isBefore(deadline);
  
  bool get isExpired => DateTime.now().isAfter(deadline);
  
  Duration get timeRemaining => deadline.difference(DateTime.now());
  
  Map<String, int> get results {
    final results = <String, int>{};
    for (final option in options) {
      results[option.id] = 0;
    }
    
    for (final userVote in votes.values) {
      for (final selectedOptionId in userVote.selectedOptionIds) {
        results[selectedOptionId] = (results[selectedOptionId] ?? 0) + 1;
      }
    }
    
    return results;
  }
  
  VoteOption? get winningOption {
    final voteResults = results;
    if (voteResults.isEmpty) return null;
    
    final maxVotes = voteResults.values.reduce((a, b) => a > b ? a : b);
    final winningOptionId = voteResults.entries
        .firstWhere((entry) => entry.value == maxVotes)
        .key;
    
    return options.firstWhere((option) => option.id == winningOptionId);
  }
}

class VoteOption extends Equatable {
  final String id;
  final String text;
  final String? description;
  final String? imageUrl;
  final int order;

  const VoteOption({
    required this.id,
    required this.text,
    this.description,
    this.imageUrl,
    required this.order,
  });

  @override
  List<Object?> get props => [id, text, description, imageUrl, order];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'description': description,
      'image_url': imageUrl,
      'order': order,
    };
  }

  factory VoteOption.fromJson(Map<String, dynamic> json) {
    return VoteOption(
      id: json['id'],
      text: json['text'],
      description: json['description'],
      imageUrl: json['image_url'],
      order: json['order'],
    );
  }
}

class UserVote extends Equatable {
  final String userId;
  final List<String> selectedOptionIds;
  final String? comment;
  final DateTime votedAt;
  final int? rating; // For rating-type votes

  const UserVote({
    required this.userId,
    required this.selectedOptionIds,
    this.comment,
    required this.votedAt,
    this.rating,
  });

  @override
  List<Object?> get props => [userId, selectedOptionIds, comment, votedAt, rating];

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'selected_option_ids': selectedOptionIds,
      'comment': comment,
      'voted_at': votedAt.toIso8601String(),
      'rating': rating,
    };
  }

  factory UserVote.fromJson(Map<String, dynamic> json) {
    return UserVote(
      userId: json['user_id'],
      selectedOptionIds: List<String>.from(json['selected_option_ids']),
      comment: json['comment'],
      votedAt: DateTime.parse(json['voted_at']),
      rating: json['rating'],
    );
  }
}

enum VoteStatus { draft, active, closed, cancelled }

class VoteTemplate extends Equatable {
  final String id;
  final String name;
  final String question;
  final String description;
  final VoteType type;
  final List<VoteOption> defaultOptions;
  final Duration defaultDuration;
  final bool isAnonymous;
  final bool allowComments;
  final bool isSystemTemplate;
  final DateTime createdAt;

  const VoteTemplate({
    required this.id,
    required this.name,
    required this.question,
    required this.description,
    required this.type,
    required this.defaultOptions,
    required this.defaultDuration,
    this.isAnonymous = false,
    this.allowComments = true,
    this.isSystemTemplate = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        question,
        description,
        type,
        defaultOptions,
        defaultDuration,
        isAnonymous,
        allowComments,
        isSystemTemplate,
        createdAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'question': question,
      'description': description,
      'type': type.toString().split('.').last,
      'default_options_json': defaultOptions.map((option) => option.toJson()).toList(),
      'default_duration_hours': defaultDuration.inHours,
      'is_anonymous': isAnonymous ? 1 : 0,
      'allow_comments': allowComments ? 1 : 0,
      'is_system_template': isSystemTemplate ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VoteTemplate.fromJson(Map<String, dynamic> json) {
    return VoteTemplate(
      id: json['id'],
      name: json['name'],
      question: json['question'],
      description: json['description'],
      type: VoteType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      defaultOptions: (json['default_options_json'] as List)
          .map((option) => VoteOption.fromJson(option))
          .toList(),
      defaultDuration: Duration(hours: json['default_duration_hours']),
      isAnonymous: json['is_anonymous'] == 1,
      allowComments: json['allow_comments'] == 1,
      isSystemTemplate: json['is_system_template'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class VoteComment extends Equatable {
  final String id;
  final String voteId;
  final String userId;
  final String comment;
  final bool isAnonymous;
  final DateTime createdAt;

  const VoteComment({
    required this.id,
    required this.voteId,
    required this.userId,
    required this.comment,
    required this.isAnonymous,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, voteId, userId, comment, isAnonymous, createdAt];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vote_id': voteId,
      'user_id': userId,
      'comment': comment,
      'is_anonymous': isAnonymous ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VoteComment.fromJson(Map<String, dynamic> json) {
    return VoteComment(
      id: json['id'],
      voteId: json['vote_id'],
      userId: json['user_id'],
      comment: json['comment'],
      isAnonymous: json['is_anonymous'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}