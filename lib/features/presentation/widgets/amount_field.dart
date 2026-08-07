import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class AmountField extends StatefulWidget {
  const AmountField({
    super.key,
    required this.onChanged,
    this.initialValue = 0,
    this.currencySymbol = '₸',
  });

  final double initialValue;
  final String currencySymbol;
  final ValueChanged<double> onChanged;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late final TextEditingController _controller;
  late bool _isEmpty;

  @override
  void initState() {
    super.initState();
    final initialText = widget.initialValue == 0
        ? ''
        : widget.initialValue.toString().replaceFirst(RegExp(r'\.0$'), '');
    _controller = TextEditingController(text: initialText);
    _isEmpty = initialText.isEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Amount',
      textField: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48),
                child: TextField(
                  showCursor: false,
                  controller: _controller,
                  autofocus: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  inputFormatters: [_AmountInputFormatter()],
                  style: context.t.displayLarge,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: context.t.displayLarge?.copyWith(
                      color: context.c.outline,
                    ),
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
                  onChanged: (value) {
                    setState(() => _isEmpty = value.isEmpty);
                    final normalizedValue = value.replaceFirst(',', '.');
                    widget.onChanged(double.tryParse(normalizedValue) ?? 0);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(widget.currencySymbol, style: context.t.displayMedium),
        ],
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
