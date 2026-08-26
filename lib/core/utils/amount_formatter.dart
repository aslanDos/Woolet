import 'package:flutter/services.dart';

/// Restricts monetary input to a positive number with up to two decimals.
///
/// Both `.` and `,` are accepted as decimal separators.
class AmountFormatter extends TextInputFormatter {
  const AmountFormatter();

  static final _pattern = RegExp(r'^\d*(?:[.,]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
