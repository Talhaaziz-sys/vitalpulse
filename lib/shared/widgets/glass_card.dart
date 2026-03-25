import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/core/theme/app_colors.dart';

/// A glassmorphism-styled card widget.
///
/// Uses [BackdropFilter] to blur the background and overlays a semi-transparent
/// frosted glass appearance over any gradient background.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.blur = AppConstants.blurSigma,
    this.width,
    this.height,
    this.onTap,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final Color? borderColor;
  final double blur;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppConstants.cardBorderRadius;
    final effectiveBorderRadius = BorderRadius.circular(radius);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            padding: padding ??
                const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null
                  ? (color ?? AppColors.glassFill)
                  : null,
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A larger glass card with an accent-colored top border strip.
class GlassCardAccent extends StatelessWidget {
  const GlassCardAccent({
    super.key,
    required this.child,
    required this.accentColor,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.cardBorderRadius),
                topRight: Radius.circular(AppConstants.cardBorderRadius),
              ),
            ),
          ),
          Padding(
            padding: padding ??
                const EdgeInsets.all(AppConstants.defaultPadding),
            child: child,
          ),
        ],
      ),
    );
  }
}
