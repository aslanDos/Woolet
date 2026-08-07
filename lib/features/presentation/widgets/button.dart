import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      child: icon == null || isLoading
          ? FilledButton(
              onPressed: isLoading ? null : onPressed,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: child,
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: child,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
    );
  }
}
