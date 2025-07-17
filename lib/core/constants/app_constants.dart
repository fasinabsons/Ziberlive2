class AppConstants {
  // App Info
  static const String appName = 'ZiberLive';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'ziberlive.db';
  static const int databaseVersion = 1;
  
  // Credits System
  static const int defaultTaskCredits = 5;
  static const int billPaymentCredits = 10;
  static const int votingCredits = 2;
  static const int communityParticipationCredits = 3;
  
  // Monetization
  static const int coinsPerDollar = 100;
  static const int adRemovalCost = 100; // coins
  static const int cloudStorageCost = 400; // coins
  static const int adsPerSync = 2;
  
  // Community Cooking
  static const double defaultCommunityCookingRate = 100.0; // $100 per user
  
  // Sync Settings
  static const int syncRetryAttempts = 3;
  static const Duration syncTimeout = Duration(seconds: 30);
  static const Duration conflictResolutionTimeout = Duration(minutes: 5);
  
  // UI Constants
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  
  // Notification Settings
  static const String billReminderChannelId = 'bill_reminders';
  static const String taskReminderChannelId = 'task_reminders';
  static const String voteReminderChannelId = 'vote_reminders';
  static const String syncNotificationChannelId = 'sync_notifications';
}