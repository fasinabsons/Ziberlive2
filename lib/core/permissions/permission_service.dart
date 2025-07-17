import '../../domain/entities/user.dart';
import '../../domain/entities/apartment.dart';

class PermissionService {
  /// Check if user can create bills
  static bool canCreateBills(User user) {
    return user.role == UserRole.roommateAdmin;
  }

  /// Check if user can edit bills
  static bool canEditBills(User user, String billCreatorId) {
    return user.role == UserRole.roommateAdmin || user.id == billCreatorId;
  }

  /// Check if user can delete bills
  static bool canDeleteBills(User user, String billCreatorId) {
    return user.role == UserRole.roommateAdmin || user.id == billCreatorId;
  }

  /// Check if user can manage other users
  static bool canManageUsers(User user) {
    return user.role == UserRole.roommateAdmin;
  }

  /// Check if user can modify apartment settings
  static bool canModifyApartmentSettings(User user) {
    return user.role == UserRole.roommateAdmin;
  }

  /// Check if user can view all bills in apartment
  static bool canViewAllBills(User user) {
    return true; // All users can view bills
  }

  /// Check if user can mark payments as paid for others
  static bool canMarkPaymentsForOthers(User user) {
    return user.role == UserRole.roommateAdmin;
  }

  /// Check if user should be included in bill splits based on apartment settings
  static bool shouldIncludeInBillSplits(User user, ApartmentSettings settings) {
    if (user.role == UserRole.user) {
      return true; // Regular users are always included
    }
    
    // For admins, check apartment settings
    return settings.adminIncludedInBills;
  }

  /// Check if user can create tasks
  static bool canCreateTasks(User user) {
    return user.role == UserRole.roommateAdmin;
  }

  /// Check if user can assign tasks to others
  static bool canAssignTasks(User user) {
    return user.role == UserRole.roommateAdmin;
  }

  /// Check if user can create polls/votes
  static bool canCreatePolls(User user) {
    return true; // All users can create polls
  }

  /// Check if user can manage investment groups
  static bool canManageInvestmentGroups(User user) {
    return true; // All users can participate in investment management
  }

  /// Check if user can create apartment rules
  static bool canCreateRules(User user) {
    return user.role == UserRole.roommateAdmin;
  }

  /// Check if user can moderate community board
  static bool canModerateCommunityBoard(User user) {
    return user.role == UserRole.roommateAdmin;
  }

  /// Get user's permission level for display
  static String getUserPermissionLevel(User user) {
    switch (user.role) {
      case UserRole.roommateAdmin:
        return 'Administrator';
      case UserRole.user:
        return 'Member';
    }
  }

  /// Get list of permissions for a user role
  static List<String> getPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.roommateAdmin:
        return [
          'Create and manage bills',
          'Add and remove users',
          'Modify apartment settings',
          'Create and assign tasks',
          'Mark payments for all users',
          'Moderate community board',
          'Create apartment rules',
          'All user permissions',
        ];
      case UserRole.user:
        return [
          'View bills and payment status',
          'Mark own payments as paid',
          'Create polls and vote',
          'Participate in investment groups',
          'Complete assigned tasks',
          'Post on community board',
          'View apartment rules',
        ];
    }
  }

  /// Check if action requires admin confirmation
  static bool requiresAdminConfirmation(String action, User user) {
    if (user.role == UserRole.roommateAdmin) {
      return false; // Admins don't need confirmation
    }

    final actionsRequiringConfirmation = [
      'opt_out_subscription',
      'change_subscription',
      'leave_apartment',
      'delete_own_content',
    ];

    return actionsRequiringConfirmation.contains(action);
  }
}