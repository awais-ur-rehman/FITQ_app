import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/storage/prefs_service.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const _pages = [
    (
      icon: Icons.camera_alt_outlined,
      color: AppColors.neonMint,
      tag: '01 — RATE',
      title: 'Rate\nYour Fit',
      description:
          'Snap your outfit and get an instant AI-powered score from 0–10 with detailed feedback on colour, fit, and style.',
    ),
    (
      icon: Icons.show_chart_rounded,
      color: AppColors.info,
      tag: '02 — TRACK',
      title: 'Track\nYour Style',
      description:
          'Build a streak, watch your score trend upward, and browse your digital closet to see how your style evolves.',
    ),
    (
      icon: Icons.ios_share_rounded,
      color: AppColors.scoreHigh,
      tag: '03 — SHARE',
      title: 'Go\nViral',
      description:
          'Generate a sleek branded card for every look. Share to Stories, TikTok, or anywhere — flexing has never been easier.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish(BuildContext ctx) async {
    await ctx.read<PrefsService>().setOnboardingSeen();
    if (ctx.mounted) ctx.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip row ──────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24, top: 16),
                child: AnimatedOpacity(
                  opacity: isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: isLast ? null : () => _finish(context),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Pages ─────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingPage(
                    icon: page.icon,
                    iconColor: page.color,
                    tag: page.tag,
                    title: page.title,
                    description: page.description,
                  );
                },
              ),
            ),

            // ── Bottom area ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
              child: Column(
                children: [
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.neonMint
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: isLast
                        ? _PrimaryButton(
                            key: const ValueKey('get_started'),
                            label: 'Get Started',
                            onPressed: () => _finish(context),
                          )
                        : _PrimaryButton(
                            key: const ValueKey('next'),
                            label: 'Next',
                            onPressed: _next,
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

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
