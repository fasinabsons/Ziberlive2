import 'package:dartz/dartz.dart';
import '../entities/vote.dart';
import '../../core/error/failures.dart';

abstract class VoteRepository {
  // Vote CRUD operations
  Future<Either<Failure, Vote>> createVote(Vote vote);
  Future<Either<Failure, Vote>> updateVote(Vote vote);
  Future<Either<Failure, void>> deleteVote(String voteId);
  Future<Either<Failure, Vote>> getVoteById(String voteId);
  Future<Either<Failure, List<Vote>>> getVotesByApartment(String apartmentId);
  Future<Either<Failure, List<Vote>>> getActiveVotes(String apartmentId);
  Future<Either<Failure, List<Vote>>> getVotesByStatus(String apartmentId, VoteStatus status);

  // Voting operations
  Future<Either<Failure, UserVote>> castVote(
    String voteId,
    String userId,
    List<String> selectedOptionIds, {
    String? comment,
    int? rating,
  });
  Future<Either<Failure, void>> removeVote(String voteId, String userId);
  Future<Either<Failure, UserVote?>> getUserVote(String voteId, String userId);
  Future<Either<Failure, Map<String, int>>> getVoteResults(String voteId);

  // Vote management
  Future<Either<Failure, Vote>> closeVote(String voteId);
  Future<Either<Failure, Vote>> extendVoteDeadline(String voteId, DateTime newDeadline);
  Future<Either<Failure, List<Vote>>> getExpiredVotes(String apartmentId);

  // Vote templates
  Future<Either<Failure, List<VoteTemplate>>> getVoteTemplates();
  Future<Either<Failure, VoteTemplate>> createVoteTemplate(VoteTemplate template);
  Future<Either<Failure, Vote>> createVoteFromTemplate(
    String templateId,
    String apartmentId,
    String createdBy,
    DateTime deadline, {
    Map<String, dynamic>? customizations,
  });

  // Comments
  Future<Either<Failure, VoteComment>> addComment(VoteComment comment);
  Future<Either<Failure, List<VoteComment>>> getVoteComments(String voteId);
  Future<Either<Failure, void>> deleteComment(String commentId);

  // Analytics and reporting
  Future<Either<Failure, Map<String, dynamic>>> getVoteAnalytics(String voteId);
  Future<Either<Failure, List<Vote>>> getVoteHistory(
    String apartmentId,
    DateTime startDate,
    DateTime endDate,
  });
}