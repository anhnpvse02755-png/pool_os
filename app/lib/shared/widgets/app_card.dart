import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, this.padding, this.margin, this.child});

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
