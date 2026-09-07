import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
with SingleTickerProviderStateMixin {
late final AnimationController _controller;

late final Animation<double> _fadeAnimation;
late final Animation<double> _scaleAnimation;
late final Animation<Offset> _slideAnimation;

@override
void initState() {
super.initState();

// ----------------------------------------------------------
// Animation Controller
// ----------------------------------------------------------

_controller = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 1100),
);

// Fade
_fadeAnimation = CurvedAnimation(
parent: _controller,
curve: Curves.easeOutCubic,
);

// Scale
_scaleAnimation = Tween<double>(
begin: 0.88,
end: 1.0,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutBack,
),
);

// Slide
_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.08),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutCubic,
),
);

_controller.forward();

// Move to login after splash
_goToLogin();
}

// ============================================================
// GO TO LOGIN
// ============================================================

Future<void> _goToLogin() async {
await Future<void>.delayed(
const Duration(milliseconds: 2500),
);

if (!mounted) return;

Navigator.pushReplacementNamed(
context,
AppRoutes.login,
);
}

// ============================================================
// DISPOSE
// ============================================================

@override
void dispose() {
_controller.dispose();
super.dispose();
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,

body: SafeArea(
child: Stack(
children: [

// ====================================================
// TOP BRAND LINE
// ====================================================

Positioned(
top: 0,
left: 0,
right: 0,
child: Container(
height: 7,
color: AppColors.banoQabilGreen,
),
),

// ====================================================
// MAIN CONTENT
// ====================================================

Center(
child: AnimatedBuilder(
animation: _controller,

builder: (context, child) {
return FadeTransition(
opacity: _fadeAnimation,

child: SlideTransition(
position: _slideAnimation,

child: ScaleTransition(
scale: _scaleAnimation,

child: child,
),
),
);
},

child: Column(
mainAxisSize: MainAxisSize.min,

children: [

// ==================================================
// BANO QABIL LOGO
// ==================================================

Container(
width: 220,
height: 220,

padding: const EdgeInsets.all(18),

decoration: BoxDecoration(
color: Colors.white,

borderRadius: BorderRadius.circular(
AppDimensions.radiusXLarge,
),

boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 30,
offset: Offset(0, 12),
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
size: 90,
color: AppColors.banoQabilGreen,
);
},
),
),

const SizedBox(height: 30),

// ==================================================
// APP NAME
// ==================================================

const Text(
'Bano Qabil',

textAlign: TextAlign.center,

style: TextStyle(
fontSize: 30,
fontWeight: FontWeight.w800,
color: AppColors.banoQabilGreen,
letterSpacing: 0.2,
),
),

const SizedBox(height: 8),

// ==================================================
// PROGRAM NAME
// ==================================================

const Text(
'IT Training Program',

textAlign: TextAlign.center,

style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.w600,
color: AppColors.banoQabilTeal,
letterSpacing: 0.5,
),
),

const SizedBox(height: 8),

// ==================================================
// TAGLINE
// ==================================================

const Padding(
padding: EdgeInsets.symmetric(
horizontal: 40,
),

child: Text(
'Learn. Grow. Become Job-Ready.',

textAlign: TextAlign.center,

style: TextStyle(
fontSize: 13,
color: AppColors.textSecondary,
height: 1.5,
),
),
),

const SizedBox(height: 38),

// ==================================================
// LOADING INDICATOR
// ==================================================

const SizedBox(
width: 28,
height: 28,

child: CircularProgressIndicator(
strokeWidth: 2.5,

valueColor:
AlwaysStoppedAnimation<Color>(
AppColors.banoQabilTeal,
),
),
),

const SizedBox(height: 14),

// ==================================================
// LOADING TEXT
// ==================================================

const Text(
'Preparing your learning space...',

style: TextStyle(
fontSize: 12,
color: AppColors.textLight,
),
),
],
),
),
),

// ====================================================
// BOTTOM BRANDING
// ====================================================

Positioned(
left: 0,
right: 0,
bottom: 24,

child: Column(
children: [

Container(
width: 45,
height: 3,

decoration: BoxDecoration(
color: AppColors.banoQabilLightGreen,

borderRadius:
BorderRadius.circular(10),
),
),

const SizedBox(height: 10),

const Text(
'Alkhidmat Foundation Pakistan Initiative',

textAlign: TextAlign.center,

style: TextStyle(
fontSize: 11,
color: AppColors.textLight,
fontWeight: FontWeight.w500,
),
),
],
),
),
],
),
),
);
}
}

