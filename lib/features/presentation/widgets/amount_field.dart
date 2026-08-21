import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';

class AmountField extends StatefulWidget {
  const AmountField({
    super.key,
    required this.onChanged,
    this.initialValue = 0,
    this.currencySymbol,
  });

  final double initialValue;
  final String? currencySymbol;
  final ValueChanged<double> onChanged;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late final TextEditingController _controller;
  late String _displayText;
  late double _amount;
  int _changeDirection = 0;

  @override
  void initState() {
    super.initState();
    final initialText = widget.initialValue == 0
        ? ''
        : widget.initialValue.toString().replaceFirst(RegExp(r'\.0$'), '');
    _controller = TextEditingController(text: initialText);
    _displayText = initialText;
    _amount = widget.initialValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        widget.currencySymbol ?? sl<CurrencyController>().value.symbol;

    return Semantics(
      label: 'Amount',
      textField: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
              child: IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 64),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      TextField(
                        showCursor: false,
                        controller: _controller,
                        autofocus: false,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        inputFormatters: [_AmountInputFormatter()],
                        style: context.t.displayLarge?.copyWith(
                          color: Colors.transparent,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTapOutside: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        onSubmitted: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        onChanged: _handleChanged,
                      ),
                      IgnorePointer(
                        child: ExcludeSemantics(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            reverseDuration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: _buildAmountTransition,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.bottomCenter,
                                children: [...previousChildren, ?currentChild],
                              );
                            },
                            child: Text(
                              _displayText.isEmpty ? '0' : _displayText,
                              key: ValueKey(_displayText),
                              maxLines: 1,
                              style: context.t.displayLarge?.copyWith(
                                color: _displayText.isEmpty
                                    ? context.c.outline
                                    : context.c.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(currencySymbol, style: context.t.displayMedium),
        ],
      ),
    );
  }

  void _handleChanged(String value) {
    final normalizedValue = value.replaceFirst(',', '.');
    final amount = double.tryParse(normalizedValue) ?? 0;

    setState(() {
      _changeDirection = amount.compareTo(_amount);
      _amount = amount;
      _displayText = value;
    });
    widget.onChanged(amount);
  }

  Widget _buildAmountTransition(Widget child, Animation<double> animation) {
    final direction = _changeDirection == 0 ? 1 : _changeDirection;
    final offset = Tween<Offset>(
      begin: Offset(0, 0.22 * direction),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: offset,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
          child: child,
        ),
      ),
    );
  }
}

class _AmountInputFormatter extends TextInputFormatter {
  static final _amountPattern = RegExp(r'^\d*(?:[.,]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _amountPattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
