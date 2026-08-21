import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
    this.headerSpacing = 24,
    this.height,
    this.footer,
    this.footerExtent = 72,
    this.safeAreaBottom = true,
  });

  final Widget child;
  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;
  final double headerSpacing;
  final double? height;
  final Widget? footer;
  final double footerExtent;
  final bool safeAreaBottom;

  bool get _hasHeader => title != null || leading != null || actions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scrollableContent = SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: footer == null ? 0 : footerExtent),
      child: child,
    );

    final body = footer == null
        ? scrollableContent
        : Stack(
            fit: height == null ? StackFit.loose : StackFit.expand,
            children: [
              scrollableContent,
              Positioned(left: 0, right: 0, bottom: 0, child: footer!),
            ],
          );

    return SafeArea(
      bottom: safeAreaBottom,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: MediaQuery.viewInsetsOf(context),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasHeader) ...[
                  _BottomSheetHeader(
                    title: title,
                    leading: leading,
                    actions: actions,
                  ),
                  SizedBox(height: headerSpacing),
                ],
                if (height != null)
                  Expanded(child: body)
                else
                  Flexible(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  const _BottomSheetHeader({
    required this.title,
    required this.leading,
    required this.actions,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final sideWidth = math.max(
      leading == null ? 0.0 : 48.0,
      actions.length * 48.0,
    );

    return Row(
      children: [
        SizedBox(
          width: sideWidth,
          child: Align(alignment: Alignment.centerLeft, child: leading),
        ),
        Expanded(
          child: Center(
            child: DefaultTextStyle(
              style: context.t.titleLarge ?? const TextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: title ?? const SizedBox.shrink(),
            ),
          ),
        ),
        SizedBox(
          width: sideWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          ),
        ),
      ],
    );
  }
}
