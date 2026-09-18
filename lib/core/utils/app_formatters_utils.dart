import 'package:intl/intl.dart';

class AppFormatters {
  static String rupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  static String nop(String rawNop) {
    String cleanNop = rawNop.replaceAll(RegExp(r'\D'), '');
    if (cleanNop.length != 18) return rawNop;

    return "${cleanNop.substring(0, 2)}.${cleanNop.substring(2, 4)}.${cleanNop.substring(4, 7)}.${cleanNop.substring(7, 10)}.${cleanNop.substring(10, 13)}.${cleanNop.substring(13, 18)}";
  }
}
