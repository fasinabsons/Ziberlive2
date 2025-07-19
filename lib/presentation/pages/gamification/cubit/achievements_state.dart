import 'package:equatable/equatable.dart';
import '../../../../domain/entities/gamification.dart';
import '../achievements_page.dart';

abstract class AchievementsState extends Equatable {
  const AchievementsState();

  @override
  List<Object?> get props => [];
}

class AchievementsInitial extends AchievementsState {}

class AchievementsLoading extends AchievementsState {}

class AchievementsLoaded extends AchievementsState {
  final List<Achievement> achievements;
  final List<UserAchievement> userAchievements;

  const AchievementsLoaded(this.achievements, this.userAchievements);

  @override
  List<Object?> get props => [achievements, userAchievements];
}

class AchievementsError extends AchievementsState {
  final String message;

  const AchievementsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AchievementUnlocked extends AchievementsState {
  final Achievement achievement;

  const AchievementUnlocked(this.achievement);

  @override
  List<Object?> get props => [achievement];
}

class MilestoneReached extends AchievementsState {
  final Milestone milestone;

  const MilestoneReached(this.milestone);

  @override
  List<Object?> get props => [milestone];
}

class AchievementProgressUpdated extends AchievementsState {
  final String achievementId;
  final int newProgress;

  const AchievementProgressUpdated(this.achievementId, this.newProgress);

  @override
  List<Object?> get props => [achievementId, newProgress];
}