import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/apartment.dart';
import '../../core/theme/app_theme.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  bool _adminIncludedInBills = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showAdminSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin Payment Role Configuration Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Admin Payment Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Include Admin in Bill Splits'),
                    subtitle: const Text(
                      'When enabled, Roommate-Admins will be included in automatic bill splitting',
                    ),
                    value: _adminIncludedInBills,
                    onChanged: (value) {
                      setState(() {
                        _adminIncludedInBills = value;
                      });
                      _updateAdminPaymentRole(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _adminIncludedInBills 
                          ? AppTheme.paidGreen.withOpacity(0.1)
                          : AppTheme.warningOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _adminIncludedInBills 
                            ? AppTheme.paidGreen.withOpacity(0.3)
                            : AppTheme.warningOrange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _adminIncludedInBills 
                              ? Icons.info_outline 
                              : Icons.warning_outlined,
                          color: _adminIncludedInBills 
                              ? AppTheme.paidGreen 
                              : AppTheme.warningOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _adminIncludedInBills
                                ? 'Admins will pay their share of bills like other residents'
                                : 'Admins are excluded from bill payments (management-only role)',
                            style: TextStyle(
                              fontSize: 12,
                              color: _adminIncludedInBills 
                                  ? AppTheme.paidGreen 
                                  : AppTheme.warningOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Users List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Text(
                  'Apartment Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // TODO: Replace with actual user data from BLoC
                _buildUserTile(
                  name: 'John Doe',
                  role: UserRole.roommateAdmin,
                  email: 'john@example.com',
                  isIncludedInBills: _adminIncludedInBills,
                ),
                _buildUserTile(
                  name: 'Jane Smith',
                  role: UserRole.user,
                  email: 'jane@example.com',
                  isIncludedInBills: true,
                ),
                _buildUserTile(
                  name: 'Bob Wilson',
                  role: UserRole.user,
                  email: 'bob@example.com',
                  isIncludedInBills: true,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildUserTile({
    required String name,
    required UserRole role,
    required String email,
    required bool isIncludedInBills,
  }) {
    final isAdmin = role == UserRole.roommateAdmin;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAdmin 
              ? AppTheme.primaryGreen 
              : AppTheme.lightGreen,
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isAdmin 
                        ? AppTheme.primaryGreen.withOpacity(0.1)
                        : AppTheme.lightGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAdmin ? 'ADMIN' : 'USER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAdmin 
                          ? AppTheme.primaryGreen 
                          : AppTheme.lightGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isIncludedInBills 
                          ? AppTheme.paidGreen.withOpacity(0.1)
                          : AppTheme.warningOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isIncludedInBills ? 'PAYS BILLS' : 'BILL EXEMPT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isIncludedInBills 
                            ? AppTheme.paidGreen 
                            : AppTheme.warningOrange,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, name),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (isAdmin)
              const PopupMenuItem(
                value: 'toggle_payment',
                child: ListTile(
                  leading: Icon(Icons.payment),
                  title: Text('Toggle Payment Role'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.remove_circle, color: Colors.red),
                title: Text('Remove User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAdminPaymentRole(bool includeAdmin) {
    // TODO: Update apartment settings through BLoC
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          includeAdmin
              ? 'Admins will now be included in bill splits'
              : 'Admins are now excluded from bill splits',
        ),
        backgroundColor: AppTheme.paidGreen,
      ),
    );
  }

  void _handleUserAction(String action, String userName) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, userName);
        break;
      case 'toggle_payment':
        _toggleAdminPaymentRole(userName);
        break;
      case 'remove':
        _showRemoveUserDialog(context, userName);
        break;
    }
  }

  void _toggleAdminPaymentRole(String userName) {
    setState(() {
      _adminIncludedInBills = !_adminIncludedInBills;
    });
    _updateAdminPaymentRole(_adminIncludedInBills);
  }

  void _showAdminSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Include Admin in Bills'),
              subtitle: const Text('Admin pays share of bills'),
              value: _adminIncludedInBills,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() {
                  _adminIncludedInBills = value;
                });
                _updateAdminPaymentRole(value);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Bill Management'),
              subtitle: const Text('Admins can always create and manage bills'),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('User Management'),
              subtitle: const Text('Admins can add/remove users and manage roles'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showEditUserDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(userName: userName),
    );
  }

  void _showRemoveUserDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: Text('Are you sure you want to remove $userName from the apartment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement user removal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$userName has been removed'),
                  backgroundColor: AppTheme.unpaidRed,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserRole _selectedRole = UserRole.user;
  bool _includeInBills = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role == UserRole.roommateAdmin ? 'Roommate-Admin' : 'User'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            if (_selectedRole == UserRole.roommateAdmin) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Include in Bill Splits'),
                subtitle: const Text('Admin will pay share of bills'),
                value: _includeInBills,
                onChanged: (value) {
                  setState(() {
                    _includeInBills = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addUser,
          child: const Text('Add User'),
        ),
      ],
    );
  }

  void _addUser() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement user creation through BLoC
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} has been added'),
          backgroundColor: AppTheme.paidGreen,
        ),
      );
    }
  }
}

class EditUserDialog extends StatefulWidget {
  final String userName;

  const EditUserDialog({super.key, required this.userName});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserRole _selectedRole = UserRole.user;
  bool _includeInBills = true;

  @override
  void initState() {
    super.initState();
    // TODO: Load user data
    _nameController.text = widget.userName;
    _emailController.text = 'user@example.com';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.userName}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role == UserRole.roommateAdmin ? 'Roommate-Admin' : 'User'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            if (_selectedRole == UserRole.roommateAdmin) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Include in Bill Splits'),
                subtitle: const Text('Admin will pay share of bills'),
                value: _includeInBills,
                onChanged: (value) {
                  setState(() {
                    _includeInBills = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateUser,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _updateUser() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement user update through BLoC
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} has been updated'),
          backgroundColor: AppTheme.paidGreen,
        ),
      );
    }
  }
}