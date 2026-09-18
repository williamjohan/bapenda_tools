import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../utils/app_logger.dart';

class ResilientDnsResolver {
  ResilientDnsResolver._();

  static final List<String> _dohProviders = [
    'https://dns.google/resolve',
    'https://cloudflare-dns.com/dns-query',
  ];

  static const _cacheTtl = Duration(minutes: 5);
  static final Map<String, _CachedIp> _cache = {};

  /// Resolve hostname -> IP.
  /// Return null kalau semua resolver gagal, caller wajib fallback ke hostname asli.
  static Future<String?> resolveIp(String host) async {
    final cached = _cache[host];
    if (cached != null && !cached.isExpired) {
      return cached.ip;
    }

    // 1) System resolver — Jalur normal/cepat.
    // 🚀 FIX: turun dari 5s -> 3s. Pemanggil (register_module.dart) membungkus
    // seluruh resolveIp() dengan outer timeout; kalau system resolver sendiri
    // sudah pakai 5s, DoH fallback di bawah nyaris tidak pernah kebagian
    // kesempatan jalan sampai selesai sebelum outer timeout terpotong.
    try {
      final result = await InternetAddress.lookup(
        host,
      ).timeout(const Duration(seconds: 3));
      if (result.isNotEmpty) {
        final ip = result.first.address;
        _cache[host] = _CachedIp(ip);
        return ip;
      }
    } catch (e) {
      // Log hanya di mode debug agar console production bersih
      if (kDebugMode) {
        AppLogger.warning('>>> [DNS] System resolver gagal untuk $host: $e');
      }
    }

    // 2) Fallback DoH — Hanya ditempuh kalau system resolver gagal (Device lawas)
    for (final provider in _dohProviders) {
      try {
        final ip = await _resolveViaDoh(
          provider,
          host,
        ).timeout(const Duration(seconds: 3));
        if (ip != null) {
          if (kDebugMode) {
            AppLogger.warning(
              '>>> [DNS] Fallback sukses via DoH: $host -> $ip',
            );
          }
          _cache[host] = _CachedIp(ip);
          return ip;
        }
      } catch (_) {
        continue; // Coba provider berikutnya diam-diam
      }
    }

    AppLogger.error('>>> [DNS FATAL] Semua resolver gagal memetakan: $host');
    return null;
  }

  static Future<String?> _resolveViaDoh(String provider, String host) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final uri = Uri.parse('$provider?name=$host&type=A');
      final request = await client.getUrl(uri);
      request.headers.set('accept', 'application/dns-json');
      final response = await request.close();

      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final answers = json['Answer'] as List?;
      if (answers == null || answers.isEmpty) return null;

      for (final answer in answers) {
        final data = answer['data'] as String?;
        if (data != null && _isValidIpv4(data)) return data;
      }
      return null;
    } finally {
      client.close();
    }
  }

  static bool _isValidIpv4(String value) {
    final parts = value.split('.');
    if (parts.length != 4) return false;
    return parts.every((p) {
      final n = int.tryParse(p);
      return n != null && n >= 0 && n <= 255;
    });
  }
}

class _CachedIp {
  final String ip;
  final DateTime _cachedAt;

  _CachedIp(this.ip) : _cachedAt = DateTime.now();
  bool get isExpired =>
      DateTime.now().difference(_cachedAt) > ResilientDnsResolver._cacheTtl;
}
