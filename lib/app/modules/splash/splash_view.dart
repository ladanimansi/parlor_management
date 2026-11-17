import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered safely
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController());
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFBF7F8), Color(0xFFF3E8EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo with smooth entrance animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutBack,
                builder: (context, value, _) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 36,
                              spreadRadius: 8,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 196,
                                height: 196,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // Tagline & decorative ornament
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        Text(
                          "MANAGE  •  BOOK  •  GROW",
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4.5,
                            color: AppColors.textPrimaryLight.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 48,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.accent,
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(flex: 3),

              // Subtle luxury loader
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Version / brand footer
              Text(
                "MannS Luxury Salon Suite",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
