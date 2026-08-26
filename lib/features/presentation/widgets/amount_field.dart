import 'package:flutter/material.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/utils/amount_formatter.dart';
import 'package:woolet/core/utils/amount_utils.dart';

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

class _AmountFieldState extends State<AmountField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceScale;
  late String _displayText;

  @override
  void initState() {
    super.initState();
    final initialText = widget.initialValue == 0
        ? ''
        : widget.initialValue.toString().replaceFirst(RegExp(r'\.0$'), '');
    _controller = TextEditingController(text: initialText);
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 55,
      ),
    ]).animate(_bounceController);
    _displayText = initialText;
  }

  @override
  void dispose() {
    _bounceController.dispose();
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
                      inputFormatters: const [AmountFormatter()],
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
                        child: ScaleTransition(
                          scale: _bounceScale,
                          child: Text(
                            _displayText.isEmpty ? '0' : _displayText,
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
          const SizedBox(width: 4),
          Text(currencySymbol, style: context.t.displayMedium),
        ],
      ),
    );
  }

  void _handleChanged(String value) {
    final amount = AmountUtils.parse(value) ?? 0;

    setState(() => _displayText = value);
    _bounceController.forward(from: 0);
    widget.onChanged(amount);
  }
}
