import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LockScreen extends ConsumerWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;
    final horizontalPadding = isDesktop ? size.width * 0.2 : 24.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              AppColors.primary.withOpacity(0.08),
              Colors.white,
            ],
            stops: const [0.1, 0.8],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 40),
                        // Logo Section
                        _buildLogoSection(context, size),
                        
                        // Main Welcome Card
                        _buildMainCard(context, size),
                        
                        // Bottom Actions & Status
                        _buildFooterSection(context, size),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context, Size size) {
    return Column(
      children: [
        Container(
          height: 84,
          width: 84,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.water_drop_rounded,
              color: Color(0xFF006B8F), // Matching the dark teal from image
              size: 42,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Flow',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF006B8F),
            letterSpacing: -1,
          ),
        ),
        Text(
          'Your wealth, in motion.',
          style: AppTextStyles.bodyLarge(context).copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome Back',
            style: AppTextStyles.headlineMedium(context).copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Secure biometric verification\nrequired',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 48),
          
          // Unlock Button
          InkWell(
            onTap: () => context.go('/dashboard'),
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF006B8F),
                    Color(0xFF38BDF8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Unlock Flow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Biometric Icon
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: const Icon(
              Icons.face_retouching_natural_rounded,
              color: Color(0xFF006B8F),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'BIOMETRIC SECURE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context, Size size) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _buildSmallCard(
                context,
                icon: Icons.headset_mic_outlined,
                label: 'Emergency Help',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmallCard(
                context,
                icon: Icons.public_outlined,
                label: 'Global Access',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2F4), // Light gray background
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399), // Mint Green
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'SYSTEM ENCRYPTED & ACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCard(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5), // Subtle gray
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.lightTextSecondary, size: 24),
          const SizedBox(height: 24),
          Text(
            label,
            style: AppTextStyles.labelLarge(context).copyWith(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
