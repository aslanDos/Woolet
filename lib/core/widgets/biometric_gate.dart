import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:local_auth/local_auth.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/settings/app_settings_controller.dart';

class BiometricGate extends StatefulWidget {
  const BiometricGate({super.key, required this.child});

  final Widget child;

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate>
    with WidgetsBindingObserver {
  final _auth = LocalAuthentication();
  bool _locked = false;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locked = sl<AppSettingsController>().value.biometricLock;
    if (_locked) WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        sl<AppSettingsController>().value.biometricLock) {
      setState(() => _locked = true);
      _unlock();
    }
  }

  Future<void> _unlock() async {
    if (_authenticating || !mounted) return;
    _authenticating = true;
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: context.l10n.biometricReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (authenticated && mounted) setState(() => _locked = false);
    } catch (_) {
      // Keep the lock screen visible so authentication can be retried.
    } finally {
      _authenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_locked || !sl<AppSettingsController>().value.biometricLock) {
      return widget.child;
    }
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: FilledButton.icon(
          onPressed: _unlock,
          icon: const Icon(LucideIcons.scan_face),
          label: Text(context.l10n.unlock),
        ),
      ),
    );
  }
}
