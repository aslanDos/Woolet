import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class ErrorToastController {
  ErrorToastController({required TickerProvider vsync})
    : _animationController = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 240),
        reverseDuration: const Duration(milliseconds: 180),
      );

  final AnimationController _animationController;
  OverlayEntry? _entry;
  Timer? _timer;

  void show(BuildContext context, String message) {
    hide(immediately: true);
    final overlay = Overlay.of(context, rootOverlay: true);
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _entry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        top: MediaQuery.paddingOf(overlayContext).top + 16,
        left: 16,
        right: 16,
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.35),
              end: Offset.zero,
            ).animate(animation),
            child: Center(
              child: Material(
                color: overlayContext.c.errorContainer,
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: hide,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.circle_alert,
                          size: 20,
                          color: overlayContext.c.onErrorContainer,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            message,
                            style: overlayContext.t.titleMedium?.copyWith(
                              color: overlayContext.c.onErrorContainer,
                            ),
                          ),
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
    );
    overlay.insert(_entry!);
    _animationController.forward(from: 0);
    _timer = Timer(const Duration(seconds: 3), hide);
  }

  Future<void> hide({bool immediately = false}) async {
    _timer?.cancel();
    _timer = null;
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    if (!immediately && _animationController.value > 0) {
      await _animationController.reverse();
    }
    entry.remove();
    if (_entry == null) _animationController.reset();
  }

  void dispose() {
    hide(immediately: true);
    _animationController.dispose();
  }
}
