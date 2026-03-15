import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum ButtonVariant { primary, outlined }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final double? width;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.width,
    this.icon,
  });

  const CustomButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  }) : variant = ButtonVariant.outlined;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    if (variant == ButtonVariant.outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        child: OutlinedButton(
          onPressed: effectiveOnPressed,
          child: _child(context),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        child: _child(context),
      ),
    );
  }

  Widget _child(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: variant == ButtonVariant.primary
              ? AppColors.deepCarbon
              : AppColors.neonMint,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
