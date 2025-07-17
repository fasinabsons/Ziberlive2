import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../domain/entities/user.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/usecases/user/register_user_usecase.dart';
import '../../core/routes/app_router.dart';
import 'cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _apartmentIdController = TextEditingController(text: 'apt_001'); // Default apartment
  bool _isRoommateAdmin = false;
  final Set<SubscriptionType> _selectedSubscriptions = {SubscriptionType.rent};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _apartmentIdController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().registerUser(
        name: _nameController.text,
        email: _emailController.text,
        role: _isRoommateAdmin ? UserRole.roommateAdmin : UserRole.user,
        apartmentId: _apartmentIdController.text,
        subscriptionTypes: _selectedSubscriptions.toList(),
      );
    }
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apartment Invite QR Code'),
        content: SizedBox(
          width: 200,
          height: 200,
          child: QrImageView(
            data: 'ziberlive://join?apartment=${_apartmentIdController.text}',
            version: QrVersions.auto,
            size: 200.0,
          ),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(getIt<RegisterUserUseCase>()),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                Navigator.pushReplacementNamed(context, AppRouter.home);
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(
                        Icons.home_work,
                        size: 64,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome to ZiberLive',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join your roommate community',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
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
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('I am a Roommate-Admin'),
                        subtitle: const Text('Admins can manage bills and users'),
                        value: _isRoommateAdmin,
                        onChanged: (value) {
                          setState(() {
                            _isRoommateAdmin = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select your subscriptions:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...SubscriptionType.values.map((type) => CheckboxListTile(
                        title: Text(_getSubscriptionDisplayName(type)),
                        value: _selectedSubscriptions.contains(type),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedSubscriptions.add(type);
                            } else {
                              _selectedSubscriptions.remove(type);
                            }
                          });
                        },
                      )),
                      const SizedBox(height: 24),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Join Community',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_isRoommateAdmin) ...[
                        ElevatedButton.icon(
                          onPressed: _showQRCode,
                          icon: const Icon(Icons.qr_code),
                          label: const Text('Generate QR Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('QR Code scanning coming soon!'),
                            ),
                          );
                        },
                        child: const Text('Scan QR Code to Join'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getSubscriptionDisplayName(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.communityCooking:
        return 'Community Cooking';
      case SubscriptionType.drinkingWater:
        return 'Drinking Water';
      case SubscriptionType.rent:
        return 'Room Rent';
      case SubscriptionType.utilities:
        return 'Utilities';
    }
  }
}