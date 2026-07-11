import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderRadius,
    this.color,
    this.gradient,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Improved Dark Mode Contrast
    // We use a slightly lighter gray base color in dark mode for better visibility
    final baseColor = color ?? (isDark ? const Color(0xFF2C2C2E) : Colors.white);
    
    // Only use a gradient if explicitly provided. 
    // Auto-generating dark gradients often causes 8-bit color banding (pixelation) on mobile displays.
    final finalGradient = gradient;
        
    final finalDecorationColor = finalGradient != null 
        ? null 
        : baseColor.withValues(alpha: isDark ? (opacity * 1.3 > 1.0 ? 1.0 : opacity * 1.3) : opacity);

    final defaultBorderColor = isDark 
        ? Colors.white.withValues(alpha: 0.12) 
        : Colors.white.withValues(alpha: 0.5);

    final defaultBorder = border ?? Border.all(
      color: defaultBorderColor,
      width: 1.5,
    );

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: finalDecorationColor,
              gradient: finalGradient,
              borderRadius: defaultBorderRadius,
              border: defaultBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
