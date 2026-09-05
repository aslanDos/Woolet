import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/router/routes.dart';
import 'package:woolet/core/widgets/error_toast.dart';
import 'package:woolet/features/presentation/blocs/auth/auth_bloc.dart';
import 'package:woolet/features/presentation/widgets/auth_components.dart';
import 'package:woolet/features/presentation/widgets/button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<AuthBloc>(),
    child: const _AuthScreen(isRegister: false),
  );
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<AuthBloc>(),
    child: const _AuthScreen(isRegister: true),
  );
}

class _AuthScreen extends StatefulWidget {
  const _AuthScreen({required this.isRegister});

  final bool isRegister;

  @override
  State<_AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<_AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final ErrorToastController _errorToast;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _errorToast = ErrorToastController(vsync: this);
  }

  @override
  void dispose() {
    _errorToast.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty) {
      _errorToast.show(context, 'Enter your email');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _errorToast.show(context, 'Enter a valid email');
      return;
    }
    if (password.isEmpty) {
      _errorToast.show(context, 'Enter your password');
      return;
    }
    if (widget.isRegister && password.length < 8) {
      _errorToast.show(context, 'Use at least 8 characters');
      return;
    }
    if (widget.isRegister && _confirmPasswordController.text.isEmpty) {
      _errorToast.show(context, 'Confirm your password');
      return;
    }
    if (widget.isRegister && _confirmPasswordController.text != password) {
      _errorToast.show(context, 'Passwords do not match');
      return;
    }
    final bloc = context.read<AuthBloc>();
    if (widget.isRegister) {
      bloc.add(AuthRegisterRequested(email: email, password: password));
    } else {
      bloc.add(AuthSignInRequested(email: email, password: password));
    }
  }

  void _resetPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _errorToast.show(context, 'Enter your email first');
      return;
    }
    context.read<AuthBloc>().add(AuthPasswordResetRequested(email));
  }

  void _socialSignIn() {
    _errorToast.show(context, 'Social sign-in is not configured yet');
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = widget.isRegister;
    final isLoading = context.select(
      (AuthBloc bloc) => bloc.state.isProcessing,
    );
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            context.go(AppRoutes.main);
          case AuthStatus.passwordResetSent:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.passwordResetSent)),
            );
          case AuthStatus.failure:
            _errorToast.show(
              context,
              state.errorMessage ?? 'Authentication failed',
            );
          case AuthStatus.initial || AuthStatus.processing:
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 30),
                          AuthMark(isRegister: isRegister),
                          SizedBox(height: 30),
                          AuthField(
                            controller: _emailController,
                            label: context.l10n.email,
                            hint: 'you@example.com',
                            icon: LucideIcons.mail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                          ),
                          const SizedBox(height: 14),
                          AuthField(
                            controller: _passwordController,
                            label: context.l10n.password,
                            hint: isRegister
                                ? 'At least 8 characters'
                                : 'Your password',
                            icon: LucideIcons.lock_keyhole,
                            obscureText: _obscurePassword,
                            textInputAction: isRegister
                                ? TextInputAction.next
                                : TextInputAction.done,
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
                          ),
                          if (isRegister) ...[
                            const SizedBox(height: 14),
                            AuthField(
                              controller: _confirmPasswordController,
                              label: context.l10n.confirmPassword,
                              hint: 'Repeat your password',
                              icon: LucideIcons.lock_keyhole,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              onSubmitted: (_) => _submit(),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Visibility(
                            visible: !isRegister,
                            maintainAnimation: true,
                            maintainState: true,
                            maintainSize: true,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isLoading ? null : _resetPassword,
                                child: Text(context.l10n.forgotPassword),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Button(
                            label: isRegister
                                ? context.l10n.createAccountAuth
                                : context.l10n.signIn,
                            icon: isRegister
                                ? LucideIcons.user_round_plus
                                : LucideIcons.arrow_right,
                            onPressed: _submit,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 22),
                          const AuthDivider(),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialAuthButton(
                                tooltip: 'Continue with Apple',
                                icon: const Icon(Icons.apple, size: 26),
                                onPressed: _socialSignIn,
                              ),
                              const SizedBox(width: 16),
                              SocialAuthButton.google(
                                tooltip: 'Continue with Google',
                                onPressed: _socialSignIn,
                              ),
                            ],
                          ),
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
                                  isRegister
                                      ? AppRoutes.login
                                      : AppRoutes.register,
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
        ),
      ),
    );
  }
}
