import 'package:flutter/material.dart';

class CommonContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final VoidCallback? onTap; // Agar container ko as a button use karna ho
  final BoxBorder? border;
  final bool showShadow;

  const CommonContainer({
    super.key,
    this.width,
    this.height,
    this.color,
    this.borderRadius = 12.0, // Default rounded corners
    this.padding,
    this.margin,
    this.child,
    this.onTap,
    this.border,
    this.showShadow = false, // Default shadow off
  });

  @override
  Widget build(BuildContext context) {
    // Basic Container structure
    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );

    // Agar onTap provide kiya gaya hai, toh isay clickable bana dein
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}