abstract final class AmountUtils {
  static double? parse(String value) {
    return double.tryParse(value.replaceFirst(',', '.'));
  }

  static double fromMinor(int minor) => minor / 100;

  static int toMinor(num amount) => (amount * 100).round();

  static String formatMinor(int minor, {bool emptyWhenZero = false}) {
    if (emptyWhenZero && minor == 0) return '';
    final amount = fromMinor(minor);
    return amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }
}
