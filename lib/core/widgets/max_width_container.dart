import 'package:flutter/material.dart';

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  const MaxWidthContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final isVeryWide = screenWidth > 1200;

    double maxWidth;
    if (isVeryWide) {
      maxWidth = 800;
    } else if (isWide) {
      maxWidth = 600;
    } else {
      maxWidth = screenWidth;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              if (isWide)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
