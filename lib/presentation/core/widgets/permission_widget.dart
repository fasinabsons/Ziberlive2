import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';
import '../../../core/permissions/permission_service.dart';

class PermissionWidget extends StatelessWidget {
  final User? currentUser;
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionWidget({
    super.key,
    required this.currentUser,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return fallback ?? const SizedBox.shrink();
    }

    final hasPermission = _checkPermission(currentUser!, permission);
    
    if (hasPermission) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }

  bool _checkPermission(User user, String permission) {
    switch (permission) {
      case 'create_bills':
        return PermissionService.canCreateBills(user);
      case 'manage_users':
        return PermissionService.canManageUsers(user);
      case 'modify_settings':
        return PermissionService.canModifyApartmentSettings(user);
      case 'create_tasks':
        return PermissionService.canCreateTasks(user);
      case 'assign_tasks':
        return PermissionService.canAssignTasks(user);
      case 'mark_payments_others':
        return PermissionService.canMarkPaymentsForOthers(user);
      case 'create_rules':
        return PermissionService.canCreateRules(user);
      case 'moderate_community':
        return PermissionService.canModerateCommunityBoard(user);
      default:
        return false;
    }
  }
}

class AdminOnlyWidget extends StatelessWidget {
  final User? currentUser;
  final Widget child;
  final Widget? fallback;

  const AdminOnlyWidget({
    super.key,
    required this.currentUser,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      currentUser: currentUser,
      permission: 'manage_users',
      child: child,
      fallback: fallback,
    );
  }
}

class ConditionalActionButton extends StatelessWidget {
  final User? currentUser;
  final String permission;
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final String? tooltip;

  const ConditionalActionButton({
    super.key,
    required this.currentUser,
    required this.permission,
    required this.onPressed,
    required this.label,
    this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      currentUser: currentUser,
      permission: permission,
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            )
          : ElevatedButton(
              onPressed: onPressed,
              child: Text(label),
            ),
      fallback: tooltip != null
          ? Tooltip(
              message: tooltip!,
              child: ElevatedButton(
                onPressed: null,
                child: Text(label),
              ),
            )
          : null,
    );
  }
}

class RoleBasedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? currentUser;
  final String title;
  final List<Widget>? baseActions;

  const RoleBasedAppBar({
    super.key,
    required this.currentUser,
    required this.title,
    this.baseActions,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      ...?baseActions,
    ];

    // Add admin-only actions
    if (currentUser?.role == UserRole.roommateAdmin) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.people),
          onPressed: () => Navigator.pushNamed(context, '/admin/users'),
          tooltip: 'Manage Users',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/admin/settings'),
          tooltip: 'Apartment Settings',
        ),
      ]);
    }

    return AppBar(
      title: Text(title),
      actions: actions.isNotEmpty ? actions : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PaymentActionButton extends StatelessWidget {
  final User? currentUser;
  final String billCreatorId;
  final String targetUserId;
  final VoidCallback onPressed;
  final bool isPaid;

  const PaymentActionButton({
    super.key,
    required this.currentUser,
    required this.billCreatorId,
    required this.targetUserId,
    required this.onPressed,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    // User can mark their own payment or admin can mark anyone's payment
    final canMarkPayment = currentUser!.id == targetUserId || 
                          PermissionService.canMarkPaymentsForOthers(currentUser!);

    if (!canMarkPayment) {
      return const SizedBox.shrink();
    }

    return TextButton(
      onPressed: isPaid ? null : onPressed,
      child: Text(
        isPaid ? 'Paid' : 'Mark Paid',
        style: TextStyle(
          color: isPaid ? Colors.green : null,
        ),
      ),
    );
  }
}