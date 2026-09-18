// lib/core/utils/currency_formatter.dart

import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Mencegah class ini di-instansiasi (Clean OOP Practice untuk Utility Class)
  CurrencyFormatter._();

  /// Mengubah angka (int, double, atau String) menjadi format Rupiah.
  ///
  /// Output: "Rp. 10.000"
  static String toIdr(dynamic number, {int decimalDigits = 0}) {
    if (number == null) return 'Rp0';

    num value = 0;

    // Proteksi Type-Safety dari respon API yang dinamis
    if (number is num) {
      value = number;
    } else if (number is String) {
      // Hilangkan karakter non-numerik jika ada (misal dari input textfield)
      final cleanString = number.replaceAll(RegExp(r'[^0-9.]'), '');
      value = num.tryParse(cleanString) ?? 0;
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp', // Menggunakan "Rp. " sesuai permintaan Anda
      decimalDigits: decimalDigits,
    );

    return formatCurrency.format(value);
  }

  /// Mengubah angka menjadi format Rupiah tanpa simbol Rp.
  ///
  /// Output: "10.000"
  static String toIdrWithoutSymbol(dynamic number, {int decimalDigits = 0}) {
    if (number == null) return '0';

    num value = 0;

    if (number is num) {
      value = number;
    } else if (number is String) {
      final cleanString = number.replaceAll(RegExp(r'[^0-9]'), '');

      value = num.tryParse(cleanString) ?? 0;
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: decimalDigits,
    );

    return formatCurrency.format(value).trim();
  }
}
