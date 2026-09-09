import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
const RegisterScreen({super.key});

@override
State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
with SingleTickerProviderStateMixin {
final _formKey = GlobalKey<FormState>();

final _nameController = TextEditingController();
final _phoneController = TextEditingController();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();
final _cityController = TextEditingController();

bool _obscurePassword = true;
bool _obscureConfirmPassword = true;
bool _acceptedTerms = false;
bool _isLoading = false;

late final AnimationController _animationController;
late final Animation<double> _fadeAnimation;
late final Animation<Offset> _slideAnimation;

@override
void initState() {
super.initState();

_animationController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 800),
);

_fadeAnimation = CurvedAnimation(
parent: _animationController,
curve: Curves.easeOutCubic,
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.07),
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
_animationController.dispose();

_nameController.dispose();
_phoneController.dispose();
_emailController.dispose();
_passwordController.dispose();
_confirmPasswordController.dispose();
_cityController.dispose();

super.dispose();
}

// ============================================================
// VALIDATION
// ============================================================

String? _validateName(String? value) {
final name = value?.trim() ?? '';

if (name.isEmpty) {
return 'Please enter your full name';
}

if (name.length < 3) {
return 'Name must be at least 3 characters';
}

return null;
}

String? _validatePhone(String? value) {
final phone = value?.trim() ?? '';

if (phone.isEmpty) {
return 'Please enter your phone number';
}

final cleanedPhone = phone.replaceAll(
RegExp(r'[\s-]'),
'',
);

final phoneRegex = RegExp(
r'^(03\d{9}|\+923\d{9})$',
);

if (!phoneRegex.hasMatch(cleanedPhone)) {
return 'Enter a valid Pakistani phone number';
}

return null;
}

String? _validateEmail(String? value) {
final email = value?.trim() ?? '';

if (email.isEmpty) {
return 'Please enter your email';
}

final emailRegex = RegExp(
r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
);

if (!emailRegex.hasMatch(email)) {
return 'Please enter a valid email';
}

return null;
}

String? _validatePassword(String? value) {
final password = value ?? '';

if (password.isEmpty) {
return 'Please create a password';
}

if (password.length < 6) {
return 'Password must be at least 6 characters';
}

return null;
}

String? _validateConfirmPassword(String? value) {
final password = value ?? '';

if (password.isEmpty) {
return 'Please confirm your password';
}

if (password != _passwordController.text) {
return 'Passwords do not match';
}

return null;
}

String? _validateCity(String? value) {
final city = value?.trim() ?? '';

if (city.isEmpty) {
return 'Please enter your city';
}

if (city.length < 2) {
return 'Please enter a valid city';
}

return null;
}

// ============================================================
// REGISTER
// ============================================================

Future<void> _register() async {
FocusScope.of(context).unfocus();

if (!_formKey.currentState!.validate()) {
return;
}

if (!_acceptedTerms) {
_showMessage(
'Please accept the terms and conditions.',
);
return;
}

setState(() {
_isLoading = true;
});

try {
await AuthService.instance.registerStudent(
name: _nameController.text.trim(),
phone: _phoneController.text.trim(),
email: _emailController.text.trim(),
password: _passwordController.text,
city: _cityController.text.trim(),
);

if (!mounted) return;

_showMessage(
'Account created successfully!',
isError: false,
);

await Future<void>.delayed(
const Duration(milliseconds: 700),
);

if (!mounted) return;

Navigator.pop(context);
} on FirebaseAuthException catch (e) {
if (!mounted) return;

_showMessage(
_firebaseAuthErrorMessage(e),
);
} on FirebaseException catch (e) {
if (!mounted) return;

_showMessage(
'Firebase error: ${e.message ?? e.code}',
);
} catch (e) {
if (!mounted) return;

_showMessage(
'Registration error: $e',
);
} finally {
if (mounted) {
setState(() {
_isLoading = false;
});
}
}
}

// ============================================================
// FIREBASE AUTH ERROR
// ============================================================

String _firebaseAuthErrorMessage(
FirebaseAuthException e,
) {
switch (e.code) {
case 'email-already-in-use':
return 'An account already exists with this email.';

case 'invalid-email':
return 'Please enter a valid email address.';

case 'weak-password':
return 'Password is too weak. Use at least 6 characters.';

case 'operation-not-allowed':
return 'Email/Password authentication is disabled in Firebase.';

case 'network-request-failed':
return 'Network error. Please check your internet connection.';

case 'too-many-requests':
return 'Too many requests. Please try again later.';

case 'app-not-authorized':
return 'This app is not authorized for the Firebase project.';

case 'invalid-api-key':
return 'Firebase API key is invalid.';

default:
return 'Firebase Auth error: ${e.message ?? e.code}';
}
}

// ============================================================
// MESSAGE
// ============================================================

void _showMessage(
String message, {
bool isError = true,
}) {
if (!mounted) return;

ScaffoldMessenger.of(context).hideCurrentSnackBar();

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
duration: const Duration(seconds: 4),
),
);
}

// ============================================================
// LOGIN
// ============================================================

void _goToLogin() {
if (_isLoading) return;

Navigator.pop(context);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
title: const Text('Create Account'),
leading: IconButton(
onPressed: _isLoading ? null : _goToLogin,
icon: const Icon(
Icons.arrow_back_rounded,
),
),
),
body: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(
horizontal: AppDimensions.paddingLarge,
vertical: AppDimensions.paddingMedium,
),
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 460,
),
child: FadeTransition(
opacity: _fadeAnimation,
child: SlideTransition(
position: _slideAnimation,
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,
children: [
_buildHeader(),
const SizedBox(height: 28),
_buildFormCard(),
const SizedBox(height: 24),
_buildLoginLink(),
const SizedBox(height: 20),
],
),
),
),
),
),
),
),
),
);
}

// ============================================================
// HEADER
// ============================================================

Widget _buildHeader() {
return Column(
children: [
Container(
width: 82,
height: 82,
padding: const EdgeInsets.all(9),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(
AppDimensions.radiusLarge,
),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 18,
offset: Offset(0, 7),
),
],
),
child: Image.asset(
'assets/images/bano_qabil_logo.png',
fit: BoxFit.contain,
errorBuilder: (
context,
error,
stackTrace,
) {
return const Icon(
Icons.school_outlined,
size: 45,
color: AppColors.banoQabilGreen,
);
},
),
),
const SizedBox(height: 16),
const Text(
'Join Bano Qabil',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 26,
fontWeight: FontWeight.w800,
color: AppColors.textPrimary,
),
),
const SizedBox(height: 7),
const Text(
'Create your account and start your learning journey.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 13,
height: 1.5,
color: AppColors.textSecondary,
),
),
],
);
}

// ============================================================
// FORM CARD
// ============================================================

Widget _buildFormCard() {
return Container(
padding: const EdgeInsets.all(
AppDimensions.paddingLarge,
),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(
AppDimensions.radiusLarge,
),
border: Border.all(
color: AppColors.border,
),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 22,
offset: Offset(0, 8),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,
children: [
const Text(
'Personal Information',
style: TextStyle(
fontSize: 19,
fontWeight: FontWeight.w700,
color: AppColors.textPrimary,
),
),
const SizedBox(height: 6),
const Text(
'Enter your basic information to create your student account.',
style: TextStyle(
fontSize: 13,
height: 1.4,
color: AppColors.textSecondary,
),
),
const SizedBox(height: 22),

TextFormField(
controller: _nameController,
textCapitalization: TextCapitalization.words,
textInputAction: TextInputAction.next,
autofillHints: const [
AutofillHints.name,
],
validator: _validateName,
decoration: const InputDecoration(
labelText: 'Full Name',
hintText: 'Enter your full name',
prefixIcon: Icon(
Icons.person_outline,
),
),
),

const SizedBox(height: 16),

TextFormField(
controller: _phoneController,
keyboardType: TextInputType.phone,
textInputAction: TextInputAction.next,
autofillHints: const [
AutofillHints.telephoneNumber,
],
validator: _validatePhone,
decoration: const InputDecoration(
labelText: 'Phone Number',
hintText: '03XXXXXXXXX',
prefixIcon: Icon(
Icons.phone_outlined,
),
),
),

const SizedBox(height: 16),

TextFormField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
textInputAction: TextInputAction.next,
autofillHints: const [
AutofillHints.email,
],
validator: _validateEmail,
decoration: const InputDecoration(
labelText: 'Email Address',
hintText: 'Enter your email',
prefixIcon: Icon(
Icons.email_outlined,
),
),
),

const SizedBox(height: 16),

TextFormField(
controller: _cityController,
textCapitalization: TextCapitalization.words,
textInputAction: TextInputAction.next,
validator: _validateCity,
decoration: const InputDecoration(
labelText: 'City',
hintText: 'e.g. Lahore',
prefixIcon: Icon(
Icons.location_city_outlined,
),
),
),

const SizedBox(height: 22),

const Text(
'Security',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.w700,
color: AppColors.textPrimary,
),
),

const SizedBox(height: 14),

TextFormField(
controller: _passwordController,
obscureText: _obscurePassword,
textInputAction: TextInputAction.next,
autofillHints: const [
AutofillHints.newPassword,
],
validator: _validatePassword,
decoration: InputDecoration(
labelText: 'Password',
hintText: 'Create a password',
prefixIcon: const Icon(
Icons.lock_outline,
),
suffixIcon: IconButton(
tooltip: _obscurePassword
? 'Show password'
    : 'Hide password',
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
),

const SizedBox(height: 16),

TextFormField(
controller: _confirmPasswordController,
obscureText: _obscureConfirmPassword,
textInputAction: TextInputAction.done,
autofillHints: const [
AutofillHints.newPassword,
],
validator: _validateConfirmPassword,
onFieldSubmitted: (_) => _register(),
decoration: InputDecoration(
labelText: 'Confirm Password',
hintText: 'Re-enter your password',
prefixIcon: const Icon(
Icons.lock_reset_outlined,
),
suffixIcon: IconButton(
tooltip: _obscureConfirmPassword
? 'Show password'
    : 'Hide password',
onPressed: () {
setState(() {
_obscureConfirmPassword =
!_obscureConfirmPassword;
});
},
icon: Icon(
_obscureConfirmPassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
),
),
),

const SizedBox(height: 18),

CheckboxListTile(
value: _acceptedTerms,
onChanged: _isLoading
? null
    : (value) {
setState(() {
_acceptedTerms =
value ?? false;
});
},
contentPadding: EdgeInsets.zero,
controlAffinity:
ListTileControlAffinity.leading,
title: const Text(
'I agree to the Bano Qabil terms and conditions.',
style: TextStyle(
fontSize: 13,
color: AppColors.textSecondary,
),
),
),

const SizedBox(height: 14),

SizedBox(
height: AppDimensions.buttonHeight,
child: ElevatedButton(
onPressed:
_isLoading ? null : _register,
child: _isLoading
? const SizedBox(
width: 22,
height: 22,
child:
CircularProgressIndicator(
strokeWidth: 2.5,
valueColor:
AlwaysStoppedAnimation<
Color>(
Colors.white,
),
),
)
    : const Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons
    .person_add_alt_1_outlined,
size: 20,
),
SizedBox(width: 9),
Text('Create Account'),
],
),
),
),
],
),
);
}

// ============================================================
// LOGIN LINK
// ============================================================

Widget _buildLoginLink() {
return Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
const Text(
'Already have an account?',
style: TextStyle(
fontSize: 13,
color: AppColors.textSecondary,
),
),
TextButton(
onPressed:
_isLoading ? null : _goToLogin,
child: const Text('Login'),
),
],
);
}
}

