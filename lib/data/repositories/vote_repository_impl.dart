import 'package:dartz/dartz.dart';
import '../../domain/entities/vote.dart';
import '../../domain/repositories/vote_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/local/database_helper.dart';

class VoteRepositoryImpl implements VoteRepository {
  final DatabaseHelper databaseHelper;

  VoteRepositoryImpl({required this.databaseHelper});

  @override
  Future<Either<Failure, Vote>> createVote(Vote vote) async {
    try {
      final voteMap = vote.toJson();
      await databaseHelper.insertVote(voteMap);
      return Right(vote);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vote>> updateVote(Vote vote) async {
    try {
      final voteMap = vote.toJson();
      await databaseHelper.updateVote(vote.id, voteMap);
      return Right(vote);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVote(String voteId) async {
    try {
      await databaseHelper.deleteVote(voteId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vote>> getVoteById(String voteId) async {
    try {
      final voteMap = await databaseHelper.getVoteById(voteId);
      if (voteMap == null) {
        return Left(NotFoundFailure('Vote not found'));
      }
      final vote = Vote.fromJson(voteMap);
      return Right(vote);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vote>>> getVotesByApartment(String apartmentId) async {
    try {
      final voteMaps = await databaseHelper.getVotesByApartment(apartmentId);
      final votes = voteMaps.map((map) => Vote.fromJson(map)).toList();
      return Right(votes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get votes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vote>>> getActiveVotes(String apartmentId) async {
    try {
      final now = DateTime.now();
      final voteMaps = await databaseHelper.getActiveVotes(apartmentId, now);
      final votes = voteMaps.map((map) => Vote.fromJson(map)).toList();
      return Right(votes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active votes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vote>>> getVotesByStatus(String apartmentId, VoteStatus status) async {
    try {
      final voteMaps = await databaseHelper.getVotesByStatus(
        apartmentId,
        status.toString().split('.').last,
      );
      final votes = voteMaps.map((map) => Vote.fromJson(map)).toList();
      return Right(votes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get votes by status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserVote>> castVote(
    String voteId,
    String userId,
    List<String> selectedOptionIds, {
    String? comment,
    int? rating,
  }) async {
    try {
      final userVote = UserVote(
        userId: userId,
        selectedOptionIds: selectedOptionIds,
        comment: comment,
        votedAt: DateTime.now(),
        rating: rating,
      );

      await databaseHelper.castVote(voteId, userVote.toJson());
      return Right(userVote);
    } catch (e) {
      return Left(DatabaseFailure('Failed to cast vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeVote(String voteId, String userId) async {
    try {
      await databaseHelper.removeUserVote(voteId, userId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to remove vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserVote?>> getUserVote(String voteId, String userId) async {
    try {
      final userVoteMap = await databaseHelper.getUserVote(voteId, userId);
      if (userVoteMap == null) {
        return const Right(null);
      }
      final userVote = UserVote.fromJson(userVoteMap);
      return Right(userVote);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get user vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getVoteResults(String voteId) async {
    try {
      final results = await databaseHelper.getVoteResults(voteId);
      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get vote results: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vote>> closeVote(String voteId) async {
    try {
      final voteResult = await getVoteById(voteId);
      return voteResult.fold(
        (failure) => Left(failure),
        (vote) async {
          final closedVote = vote.copyWith(
            status: VoteStatus.closed,
            closedAt: DateTime.now(),
          );
          return await updateVote(closedVote);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to close vote: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vote>> extendVoteDeadline(String voteId, DateTime newDeadline) async {
    try {
      final voteResult = await getVoteById(voteId);
      return voteResult.fold(
        (failure) => Left(failure),
        (vote) async {
          final extendedVote = vote.copyWith(deadline: newDeadline);
          return await updateVote(extendedVote);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to extend vote deadline: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vote>>> getExpiredVotes(String apartmentId) async {
    try {
      final now = DateTime.now();
      final voteMaps = await databaseHelper.getExpiredVotes(apartmentId, now);
      final votes = voteMaps.map((map) => Vote.fromJson(map)).toList();
      return Right(votes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get expired votes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VoteTemplate>>> getVoteTemplates() async {
    try {
      final templateMaps = await databaseHelper.getVoteTemplates();
      final templates = templateMaps.map((map) => VoteTemplate.fromJson(map)).toList();
      return Right(templates);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get vote templates: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VoteTemplate>> createVoteTemplate(VoteTemplate template) async {
    try {
      final templateMap = template.toJson();
      await databaseHelper.insertVoteTemplate(templateMap);
      return Right(template);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create vote template: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vote>> createVoteFromTemplate(
    String templateId,
    String apartmentId,
    String createdBy,
    DateTime deadline, {
    Map<String, dynamic>? customizations,
  }) async {
    try {
      final templateMap = await databaseHelper.getVoteTemplateById(templateId);
      if (templateMap == null) {
        return Left(NotFoundFailure('Vote template not found'));
      }

      final template = VoteTemplate.fromJson(templateMap);
      
      final vote = Vote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: customizations?['question'] ?? template.question,
        description: customizations?['description'] ?? template.description,
        type: template.type,
        options: template.defaultOptions,
        apartmentId: apartmentId,
        createdBy: createdBy,
        deadline: deadline,
        isAnonymous: customizations?['isAnonymous'] ?? template.isAnonymous,
        allowComments: customizations?['allowComments'] ?? template.allowComments,
        votes: {},
        status: VoteStatus.active,
        createdAt: DateTime.now(),
        metadata: {'template_id': templateId, ...?customizations},
      );

      return await createVote(vote);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create vote from template: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VoteComment>> addComment(VoteComment comment) async {
    try {
      final commentMap = comment.toJson();
      await databaseHelper.insertVoteComment(commentMap);
      return Right(comment);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add comment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VoteComment>>> getVoteComments(String voteId) async {
    try {
      final commentMaps = await databaseHelper.getVoteComments(voteId);
      final comments = commentMaps.map((map) => VoteComment.fromJson(map)).toList();
      return Right(comments);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get vote comments: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await databaseHelper.deleteVoteComment(commentId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete comment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVoteAnalytics(String voteId) async {
    try {
      final analytics = await databaseHelper.getVoteAnalytics(voteId);
      return Right(analytics);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get vote analytics: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vote>>> getVoteHistory(
    String apartmentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final voteMaps = await databaseHelper.getVoteHistory(apartmentId, startDate, endDate);
      final votes = voteMaps.map((map) => Vote.fromJson(map)).toList();
      return Right(votes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get vote history: ${e.toString()}'));
    }
  }
}