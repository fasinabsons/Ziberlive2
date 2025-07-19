import 'package:flutter/material.dart';
import '../../pages/splash/splash_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/demo/demo_page.dart';
import '../../pages/rewards/lucky_draw_page.dart';
// Temporarily commented out problematic imports
// import '../../pages/rules/rule_violation_reporting_page.dart';
// import '../../pages/rules/rule_compliance_page.dart';
// import '../../pages/rules/rule_dispute_page.dart';
// import '../../pages/messaging/bluetooth_chat_page.dart';
// import '../../pages/rewards/reward_coins_page.dart';
// import '../../pages/gamification/credits_page.dart';
// import '../../pages/gamification/community_tree_page.dart';
// import '../../pages/gamification/achievements_page.dart';
// import '../../pages/gamification/leaderboard_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String bills = '/bills';
  static const String tasks = '/tasks';
  static const String voting = '/voting';
  static const String investments = '/investments';
  static const String community = '/community';
  static const String profile = '/profile';
  
  // New routes for implemented features
  static const String ruleViolations = '/rule-violations';
  static const String ruleCompliance = '/rule-compliance';
  static const String ruleDisputes = '/rule-disputes';
  static const String bluetoothChat = '/bluetooth-chat';
  static const String rewardCoins = '/reward-coins';
  static const String luckyDraw = '/lucky-draw';
  static const String credits = '/credits';
  static const String communityTree = '/community-tree';
  static const String achievements = '/achievements';
  static const String leaderboard = '/leaderboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case ruleViolations:
      case ruleCompliance:
      case ruleDisputes:
      case bluetoothChat:
      case rewardCoins:
        return MaterialPageRoute(builder: (_) => const DemoPage());
      case luckyDraw:
        return MaterialPageRoute(builder: (_) => const LuckyDrawPage());
      case credits:
      case communityTree:
      case achievements:
      case leaderboard:
        return MaterialPageRoute(builder: (_) => const DemoPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}