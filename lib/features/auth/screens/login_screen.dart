import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final firebaseUser =
          FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Unable to identify logged-in user.',
        );
      }

      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDocument.exists ||
          userDocument.data() == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'profile-not-found',
          message:
          'Your account profile was not found in Firestore.',
        );
      }

      final userData = userDocument.data()!;

      final role = (userData['role'] ?? 'student')
          .toString()
          .toLowerCase()
          .trim();

      if (!mounted) return;

      switch (role) {
        case 'student':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.studentHome,
                (route) => false,
          );
          break;

        case 'instructor':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.instructorHome,
                (route) => false,
          );
          break;

        case 'coordinator':
        case 'admin':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.coordinatorDashboard,
                (route) => false,
          );
          break;

        default:
          await AuthService.instance.logout();

          _showError(
            'Invalid account role. Please contact the coordinator.',
          );
      }
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseAuthMessage(e));
    } on FirebaseException catch (e) {
      _showError(
        e.message ??
            'Something went wrong while loading your profile.',
      );
    } catch (e) {
      _showError(
        'Unable to login right now. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _firebaseAuthMessage(
      FirebaseAuthException exception,
      ) {
    switch (exception.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account exists with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return exception.message ??
            'Login failed. Please try again.';
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError(
        'Enter your email address first.',
      );
      return;
    }

    try {
      await AuthService.instance
          .sendPasswordResetEmail(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Check your inbox.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseAuthMessage(e));
    } catch (_) {
      _showError(
        'Unable to send reset email.',
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  void _fillDemoAccount(
      String email,
      String password,
      ) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.paddingLarge,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    _buildLogo(),

                    const SizedBox(height: 24),

                    Text(
                      'Welcome Back',
                      style: AppTextStyles.heading1,
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Sign in to continue your Bano Qabil journey',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),

                    const SizedBox(height: 28),

                    _buildLoginCard(),

                    const SizedBox(height: 20),

                    _buildDemoAccounts(),

                    const SizedBox(height: 24),

                    const Text(
                      'Bano Qabil • Learn. Grow. Become Job-Ready.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/bano_qabil_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.school_rounded,
            color: AppColors.primary,
            size: 48,
          );
        },
      ),
    );
  }

  Widget _buildLoginCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign In',
              style: AppTextStyles.heading2,
            ),

            const SizedBox(height: 22),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'example@email.com',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';

                if (email.isEmpty) {
                  return 'Email is required';
                }

                final emailRegex =
                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                if (!emailRegex.hasMatch(email)) {
                  return 'Enter a valid email';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                      !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }

                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }

                return null;
              },
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                _isLoading ? null : _forgotPassword,
                child: const Text(
                  'Forgot Password?',
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Login',
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: OutlinedButton(
                onPressed:
                _isLoading ? null : _openRegister,
                child: const Text(
                  'Create New Account',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoAccounts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.paddingMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Demo Accounts',
                  style: AppTextStyles.heading3,
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'Tap an account to fill the login fields.',
              style: AppTextStyles.bodySmall,
            ),

            const SizedBox(height: 14),

            _demoTile(
              role: 'Student',
              email: 'student@banoqabil.org',
              password: 'Student@123',
              icon: Icons.person_rounded,
            ),

            _demoTile(
              role: 'Instructor',
              email: 'instructor@banoqabil.org',
              password: 'Instructor@123',
              icon: Icons.school_rounded,
            ),

            _demoTile(
              role: 'Coordinator',
              email: 'admin@banoqabil.org',
              password: 'Admin@123',
              icon: Icons.admin_panel_settings_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoTile({
    required String role,
    required String email,
    required String password,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        _fillDemoAccount(
          email,
          password,
        );
      },
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMedium,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.accentLight,
              child: Icon(
                icon,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    email,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.touch_app_rounded,
              size: 20,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}