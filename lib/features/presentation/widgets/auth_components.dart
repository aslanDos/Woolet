import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class AuthMark extends StatelessWidget {
  const AuthMark({super.key, required this.isRegister});

  final bool isRegister;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 22),
      Text(
        isRegister ? 'Create your account' : 'Welcome back',
        textAlign: TextAlign.center,
        style: context.t.headlineLarge,
      ),
      const SizedBox(height: 8),
      Text(
        isRegister
            ? 'Start building better money habits'
            : 'Sign in to continue managing your money',
        textAlign: TextAlign.center,
        style: context.t.bodyLarge?.copyWith(color: context.c.onSurfaceVariant),
      ),
    ],
  );
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.autofillHints,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Iterable<String> autofillHints;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.t.titleMedium),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        autofillHints: autofillHints,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 19),
          suffixIcon: suffix,
          border: _border(context),
          enabledBorder: _border(context),
          focusedBorder: _border(context, width: 1.5),
        ),
        onSubmitted: onSubmitted,
      ),
    ],
  );

  OutlineInputBorder _border(BuildContext context, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: context.c.outlineVariant, width: width),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          'or continue with',
          style: context.t.bodySmall?.copyWith(color: context.c.outline),
        ),
      ),
      const Expanded(child: Divider()),
    ],
  );
}

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  SocialAuthButton.google({
    super.key,
    required this.tooltip,
    required this.onPressed,
  }) : icon = SvgPicture.asset(
         'assets/images/google_logo.svg',
         width: 24,
         height: 24,
       );

  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: SizedBox.square(
      dimension: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: context.c.onSurface,
          side: BorderSide(color: context.c.outlineVariant),
          shape: const CircleBorder(),
        ),
        child: icon,
      ),
    ),
  );
}
