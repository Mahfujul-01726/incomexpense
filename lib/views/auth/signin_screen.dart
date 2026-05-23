import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/onboarding_controller.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final onboardingController = Get.find<OnboardingController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF6F6),
      body: Stack(
        children: [
          // Background decorative blobs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2F7E79).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: -90,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2F7E79).withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2F7E79).withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: const Color(0xFF2F7E79),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.03),

                        // App icon
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF63B5AF), Color(0xFF2F7E79)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2F7E79).withValues(alpha: 0.3),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),

                        SizedBox(height: size.height * 0.035),

                        // Headline
                        Text(
                          'Welcome!',
                          style: GoogleFonts.outfit(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Sign in to manage your finances\nsmarter and faster',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.grey[500],
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: size.height * 0.05),

                        // Feature highlights card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: const [
                              _FeatureRow(
                                icon: Icons.bar_chart_rounded,
                                title: 'Smart Analytics',
                                subtitle: 'Visualize your spending patterns',
                              ),
                              SizedBox(height: 16),
                              _FeatureRow(
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'Multi-Wallet Support',
                                subtitle: 'Manage all accounts in one place',
                              ),
                              SizedBox(height: 16),
                              _FeatureRow(
                                icon: Icons.cloud_done_outlined,
                                title: 'Cloud Sync',
                                subtitle: 'Your data, always backed up',
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.05),

                        // Google Sign-In Button
                        Obx(() => _GoogleSignInButton(
                              isLoading: authController.isLoading.value,
                              onTap: authController.signInWithGoogle,
                            )),

                        const SizedBox(height: 16),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.grey[300], thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('or',
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 13)),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.grey[300], thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Continue as Guest
                        GestureDetector(
                          onTap: () => onboardingController.finishOnboarding(),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color:
                                    const Color(0xFF2F7E79).withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Continue as Guest',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF2F7E79),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Terms
                        Text(
                          'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.grey[400],
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Feature highlight row widget
// ────────────────────────────────────────────────
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2F7E79).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2F7E79), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                    fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle_rounded,
            color: Color(0xFF2F7E79), size: 18),
      ],
    );
  }
}

// ────────────────────────────────────────────────
// Google Sign-In branded button
// ────────────────────────────────────────────────
class _GoogleSignInButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleSignInButton({required this.isLoading, required this.onTap});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03,
    )..addListener(() => setState(() => _scale = 1 - _scaleController.value));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _scaleController.forward(),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              _scaleController.reverse();
              widget.onTap();
            },
      onTapCancel: () => _scaleController.reverse(),
      child: Transform.scale(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2F7E79)),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GoogleGLogo(),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Google',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Google "G" logo painter
// ────────────────────────────────────────────────
class _GoogleGLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.84),
        _r(-230), _r(130), false, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.84),
        _r(-100), _r(-130), false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.84),
        _r(120), _r(65), false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.84),
        _r(55), _r(65), false, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 0.5, cy - size.height * 0.1, r + 0.5, size.height * 0.2),
        const Radius.circular(2),
      ),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.fill,
    );
  }

  double _r(double deg) => deg * 3.14159265 / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
