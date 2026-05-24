import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/onboarding_controller.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top section containing illustration and its original background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.62,
            child: Container(
              color: const Color(0xFFEDF6F6),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: const bool.fromEnvironment('FLUTTER_TEST')
                        ? Container(
                            width: 250,
                            height: 250,
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 80,
                              color: AppTheme.primaryColor,
                            ),
                          )
                        : Image.asset(
                            'assets/cropped/onboarding_guy.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 250,
                              height: 250,
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 80,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom section with white card and diagonal wave curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.42,
            child: ClipPath(
              clipper: OnboardingClipper(),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(28, 50, 28, 16),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Spend Smarter\nSave More',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF2F7E79),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Get Started Button
                      AnimatedScaleButton(
                        text: 'Get Started',
                        onTap: () {
                          controller.completeOnboarding();
                        },
                      ),

                      const SizedBox(height: 16),

                      // Already have an account? Log In
                      GestureDetector(
                        onTap: () => Get.toNamed('/signin'),
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: const Color(0xFF444444),
                            ),
                            children: const [
                              TextSpan(text: 'Already Have Account? '),
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
                                  color: Color(0xFF2F7E79),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Custom Clipper for onboarding wave
// ─────────────────────────────────────────────
class OnboardingClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 50);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, 40);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────
// Animated scale button (shared)
// ─────────────────────────────────────────────
class AnimatedScaleButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;

  const AnimatedScaleButton(
      {super.key, required this.onTap, required this.text});

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF63B5AF),
                Color(0xFF3F9A96),
                Color(0xFF2F7E79),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2F7E79).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
