import 'package:equatable/equatable.dart';

enum ChefStatus { active, inactive, pending, demoted }

enum ChefApplicationStatus { pending, approved, rejected, withdrawn }

class Chef extends Equatable {
  final String id;
  final String userId;
  final String apartmentId;
  final String name;
  final String? bio;
  final List<String> specialties;
  final List<String> dietaryAccommodations;
  final ChefStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final double rating;
  final int totalVotes;
  final int positiveVotes;
  final List<String> certifications;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  const Chef({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.name,
    this.bio,
    required this.specialties,
    required this.dietaryAccommodations,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.rating,
    required this.totalVotes,
    required this.positiveVotes,
    required this.certifications,
    this.profileImageUrl,
    required this.createdAt,
    this.lastActiveAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        apartmentId,
        name,
        bio,
        specialties,
        dietaryAccommodations,
        status,
        startDate,
        endDate,
        rating,
        totalVotes,
        positiveVotes,
        certifications,
        profileImageUrl,
        createdAt,
        lastActiveAt,
      ];

  Chef copyWith({
    String? id,
    String? userId,
    String? apartmentId,
    String? name,
    String? bio,
    List<String>? specialties,
    List<String>? dietaryAccommodations,
    ChefStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? rating,
    int? totalVotes,
    int? positiveVotes,
    List<String>? certifications,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return Chef(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      apartmentId: apartmentId ?? this.apartmentId,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      dietaryAccommodations: dietaryAccommodations ?? this.dietaryAccommodations,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rating: rating ?? this.rating,
      totalVotes: totalVotes ?? this.totalVotes,
      positiveVotes: positiveVotes ?? this.positiveVotes,
      certifications: certifications ?? this.certifications,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  double get approvalPercentage => totalVotes > 0 ? (positiveVotes / totalVotes) * 100 : 0;
  bool get isHighlyRated => rating >= 4.0;
  bool get hasRecentActivity => lastActiveAt != null && 
      DateTime.now().difference(lastActiveAt!).inDays <= 7;
}

class ChefApplication extends Equatable {
  final String id;
  final String userId;
  final String apartmentId;
  final String applicantName;
  final String motivation;
  final List<String> specialties;
  final List<String> dietaryAccommodations;
  final String? experience;
  final List<String> certifications;
  final ChefApplicationStatus status;
  final DateTime applicationDate;
  final DateTime? reviewDate;
  final String? reviewNotes;
  final String? reviewedBy;

  const ChefApplication({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.applicantName,
    required this.motivation,
    required this.specialties,
    required this.dietaryAccommodations,
    this.experience,
    required this.certifications,
    required this.status,
    required this.applicationDate,
    this.reviewDate,
    this.reviewNotes,
    this.reviewedBy,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        apartmentId,
        applicantName,
        motivation,
        specialties,
        dietaryAccommodations,
        experience,
        certifications,
        status,
        applicationDate,
        reviewDate,
        reviewNotes,
        reviewedBy,
      ];

  ChefApplication copyWith({
    String? id,
    String? userId,
    String? apartmentId,
    String? applicantName,
    String? motivation,
    List<String>? specialties,
    List<String>? dietaryAccommodations,
    String? experience,
    List<String>? certifications,
    ChefApplicationStatus? status,
    DateTime? applicationDate,
    DateTime? reviewDate,
    String? reviewNotes,
    String? reviewedBy,
  }) {
    return ChefApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      apartmentId: apartmentId ?? this.apartmentId,
      applicantName: applicantName ?? this.applicantName,
      motivation: motivation ?? this.motivation,
      specialties: specialties ?? this.specialties,
      dietaryAccommodations: dietaryAccommodations ?? this.dietaryAccommodations,
      experience: experience ?? this.experience,
      certifications: certifications ?? this.certifications,
      status: status ?? this.status,
      applicationDate: applicationDate ?? this.applicationDate,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}

class ChefVote extends Equatable {
  final String id;
  final String chefId;
  final String voterId;
  final bool isPositive;
  final String? comment;
  final DateTime voteDate;
  final ChefVoteType type;

  const ChefVote({
    required this.id,
    required this.chefId,
    required this.voterId,
    required this.isPositive,
    this.comment,
    required this.voteDate,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        chefId,
        voterId,
        isPositive,
        comment,
        voteDate,
        type,
      ];
}

enum ChefVoteType { recruitment, performance, demotion }

class ChefPerformanceReview extends Equatable {
  final String id;
  final String chefId;
  final String reviewerId;
  final double rating;
  final String? feedback;
  final List<String> strengths;
  final List<String> improvements;
  final DateTime reviewDate;
  final String reviewPeriod; // e.g., "Week 1-2 March 2024"

  const ChefPerformanceReview({
    required this.id,
    required this.chefId,
    required this.reviewerId,
    required this.rating,
    this.feedback,
    required this.strengths,
    required this.improvements,
    required this.reviewDate,
    required this.reviewPeriod,
  });

  @override
  List<Object?> get props => [
        id,
        chefId,
        reviewerId,
        rating,
        feedback,
        strengths,
        improvements,
        reviewDate,
        reviewPeriod,
      ];
}