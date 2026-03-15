import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ScoreRing extends StatefulWidget {
  final double score;
  final double size;

  const ScoreRing({super.key, required this.score, this.size = 160});

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnim;
  late final Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _countAnim = Tween<double>(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward().then((_) {
      HapticFeedback.lightImpact();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (widget.score < 4) return AppColors.scoreLow;
    if (widget.score < 7) return AppColors.scoreMid;
    return AppColors.scoreHigh;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final fontSize = size * 0.26;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Dark circular background
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: _scoreColor.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Animated progress arc
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _ScoreRingPainter(
                  progress: _progressAnim.value * (widget.score / 10),
                  color: _scoreColor,
                  strokeWidth: size * 0.065,
                ),
              ),
            ),

            // Score number
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _countAnim.value.toStringAsFixed(1),
                  style: AppTextStyles.scoreHero.copyWith(
                    color: AppColors.pureWhite,
                    fontSize: fontSize,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                Text(
                  '/ 10',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: size * 0.1,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    const startAngle = -math.pi / 2;

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = AppColors.border,
    );

    // Colored progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progress * math.pi * 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.color != color;
}
