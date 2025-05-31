import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassmorphicInkwell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final Function()? onTap;

  const GlassmorphicInkwell({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          AppTheme.glassmorphismDecoration.borderRadius as BorderRadius,
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withAlpha(8), Colors.white.withAlpha(4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
              AppTheme.glassmorphismDecoration.borderRadius as BorderRadius,
          border: AppTheme.glassmorphismDecoration.border,
        ),
        child: child,
      ),
    );
  }
}
