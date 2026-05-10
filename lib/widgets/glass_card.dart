import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool showGradient;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 20.0,
    this.opacity = 0.75,
    this.padding = const EdgeInsets.all(20.0),
    this.width,
    this.height,
    this.showGradient = false,
    this.onTap,
    this.borderColor,
    this.borderWidth = 1.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              gradient: showGradient
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(opacity + 0.1),
                        Colors.white.withOpacity(opacity - 0.05),
                      ],
                    )
                  : null,
              color: !showGradient ? Colors.white.withOpacity(opacity) : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.5),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
