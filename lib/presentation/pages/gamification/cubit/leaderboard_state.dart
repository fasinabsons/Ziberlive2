import 'package:equatable/equatable.dart';
import '../leaderboard_page.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardsLoaded extends LeaderboardState {
  final List<LeaderboardEntry> overallLeaderboard;
  final List<LeaderboardEntry> taskLeaderboard;
  final List<LeaderboardEntry> communityLeaderboard;
  final List<LeaderboardEntry> streakLeaderboard;
  final LeaderboardEntry? currentUserRank;

  const LeaderboardsLoaded({
    required this.overallLeaderboard,
    required this.taskLeaderboard,
    required this.communityLeaderboard,
    required this.streakLeaderboard,
    this.currentUserRank,
  });

  @override
  List<Object?> get props => [
    overallLeaderboard,
    taskLeaderboard,
    communityLeaderboard,
    streakLeaderboard,
    currentUserRank,
  ];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class LeaderboardShared extends LeaderboardState {
  final String shareContent;

  const LeaderboardShared(this.shareContent);

  @override
  List<Object?> get props => [shareContent];
}

class AppreciationSent extends LeaderboardState {
  final String userId;
  final String message;

  const AppreciationSent(this.userId, this.message);

  @override
  List<Object?> get props => [userId, message];
}