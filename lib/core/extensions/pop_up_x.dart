import 'package:flutter/material.dart';

extension PopUpExtension on BuildContext {
  Future<T?> openBottomSheet<T>({
    required Widget child,
    WidgetBuilder? builder,
    bool isScrollControlled = true,
    bool? showDragHandle = false,
  }) {
    return showModalBottomSheet(
      context: this,
      showDragHandle: showDragHandle,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      builder: builder ?? (context) => child,
    );
  }

  Future<T?> openBottomSheetNoBarrier<T>(
    Widget child, {
    double? height,
    Color backgroundColor = Colors.white,
  }) {
    return showModalBottomSheet(
      context: this,
      barrierColor: Colors.transparent,
      backgroundColor: backgroundColor,
      showDragHandle: true,
      builder: (context) => SizedBox(
        height: height ?? MediaQuery.of(context).size.height * 0.4,
        child: child,
      ),
    );
  }
}
