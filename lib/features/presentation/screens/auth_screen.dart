import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/router/routes.dart';
import 'package:woolet/features/presentation/widgets/button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => const _AuthScreen(isRegister: false);
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) => const _AuthScreen(isRegister: true);
}

class _AuthScreen extends StatefulWidget {
  const _AuthScreen({required this.isRegister});

  final bool isRegister;

  @override
  State<_AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<_AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.go(AppRoutes.main);
  }

  void _socialSignIn() => context.go(AppRoutes.main);

  @override
  Widget build(BuildContext context) {
    final isRegister = widget.isRegister;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final safePadding = MediaQuery.paddingOf(context).vertical;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.onboarding),
          icon: const Icon(LucideIcons.arrow_left),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - safePadding - kToolbarHeight - 48,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isRegister ? 8 : 30),
                      _AuthMark(isRegister: isRegister),
                      SizedBox(height: isRegister ? 28 : 38),
                      if (isRegister) ...[
                        _AuthField(
                          controller: _nameController,
                          label: 'Name',
                          hint: 'Your name',
                          icon: LucideIcons.user,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 14),
                      ],
                      _AuthField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Enter your email';
                          if (!email.contains('@') || !email.contains('.')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _AuthField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: isRegister
                            ? 'At least 8 characters'
                            : 'Your password',
                        icon: LucideIcons.lock_keyhole,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: [
                          isRegister
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        onSubmitted: (_) => _submit(),
                        suffix: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? LucideIcons.eye
                                : LucideIcons.eye_off,
                            size: 18,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your password';
                          }
                          if (isRegister && value.length < 8) {
                            return 'Use at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      if (!isRegister) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Forgot password?'),
                          ),
                        ),
                      ] else
                        const SizedBox(height: 20),
                      Button(
                        label: isRegister ? 'Create account' : 'Sign in',
                        icon: isRegister
                            ? LucideIcons.user_round_plus
                            : LucideIcons.arrow_right,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 22),
                      const _OrDivider(),
                      const SizedBox(height: 22),
                      _SocialButton(
                        label: 'Continue with Apple',
                        icon: const Icon(Icons.apple, size: 25),
                        onPressed: _socialSignIn,
                      ),
                      const SizedBox(height: 12),
                      _SocialButton(
                        label: 'Continue with Google',
                        icon: const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                        onPressed: _socialSignIn,
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isRegister
                                ? 'Already have an account?'
                                : 'New to Woolet?',
                            style: context.t.bodyMedium?.copyWith(
                              color: context.c.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(
                              isRegister ? AppRoutes.login : AppRoutes.register,
                            ),
                            child: Text(
                              isRegister ? 'Sign in' : 'Create account',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthMark extends StatelessWidget {
  const _AuthMark({required this.isRegister});

  final bool isRegister;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: context.c.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isRegister ? LucideIcons.sparkles : LucideIcons.wallet_cards,
          color: context.c.onPrimary,
          size: 29,
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

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.autofillHints,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Iterable<String> autofillHints;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 7),
        child: Text(label, style: context.t.titleMedium),
      ),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        autofillHints: autofillHints,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 19),
          suffixIcon: suffix,
        ),
        validator: validator,
        onFieldSubmitted: onSubmitted,
      ),
    ],
  );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

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

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: SizedBox(width: 26, child: Center(child: icon)),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.c.onSurface,
        side: BorderSide(color: context.c.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
