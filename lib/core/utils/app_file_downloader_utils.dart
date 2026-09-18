import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
// Sesuaikan path import AppLogger Anda jika berbeda
import '../../../../core/utils/app_logger.dart';

class AppFileDownloaderUtils {
  // 1. Mencegah Instansiasi (OOP Best Practice)
  AppFileDownloaderUtils._();

  /// Mengunduh file dari URL dan menyimpannya ke local storage.
  /// Me-return [String] path fisik file jika sukses, atau [null] jika gagal.
  static Future<String?> downloadFromUrl({
    required String url,
    required String fileName,
    String folderName = 'downloads',
    Dio? dioOverride,
  }) async {
    // Edge Case 1: URL kosong atau tidak valid
    if (url.isEmpty || !Uri.parse(url).isAbsolute) {
      AppLogger.error(
        'AppFileDownloaderUtils: URL kosong atau format tidak valid -> $url',
      );
      return null;
    }

    try {
      AppLogger.info(
        'AppFileDownloaderUtils: Memulai persiapan unduhan dari -> $url',
      );

      // 2. Tentukan Direktori Penyimpanan Aman
      Directory targetDir;

      if (Platform.isAndroid) {
        // PERBAIKAN FATAL: Buang penggunaan '$folderName' di ruang publik!
        // Tulis langsung ke root folder Download agar lolos dari blokir Scoped Storage Android 11+
        targetDir = Directory('/storage/emulated/0/Download');
      } else {
        // iOS tetap menggunakan folderDocuments/reklame_templates yang terisolasi
        final Directory baseDir = await getApplicationDocumentsDirectory();
        targetDir = Directory('${baseDir.path}/$folderName');
      }

      // Edge Case 2: Pastikan folder target eksis
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
        AppLogger.info(
          'AppFileDownloaderUtils: Membuat direktori -> ${targetDir.path}',
        );
      }

      // Edge Case 2: Folder belum ada
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
        AppLogger.info(
          'AppFileDownloaderUtils: Membuat direktori baru -> ${targetDir.path}',
        );
      }
      // Edge Case 2: Folder belum ada
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
        AppLogger.info(
          'AppFileDownloaderUtils: Membuat direktori baru -> ${targetDir.path}',
        );
      }

      // 3. Sanitasi Nama Dasar File (Tanpa Ekstensi)
      final String sanitizedBaseName = fileName.replaceAll(
        RegExp(r'[<>:"/\\|?*]'),
        '_',
      );

      // Variabel penampung untuk path yang sudah digabung dengan ekstensi dari server
      String? finalResolvedPath;

      final Dio dio = dioOverride ?? Dio();

      // 4. Eksekusi Unduhan dengan "Smart Header Interceptor"
      await dio.download(
        url,
        (Headers headers) {
          String extension = '';

          AppLogger.info('AppFileDownloaderUtils RAW HEADERS:\n${headers.map}');

          // A. Coba deteksi dari header Content-Disposition (Regex Super Tangguh)
          // A. Coba deteksi dari header Content-Disposition (Regex Super Tangguh)
          final contentDisposition = headers.value('content-disposition');
          if (contentDisposition != null) {
            final match = RegExp(
              r'''filename[^;=\n]*=((["']).*?\2|[^;\n]*)''',
            ).firstMatch(contentDisposition);

            if (match != null) {
              String serverFileName = match.group(1) ?? '';
              serverFileName = serverFileName
                  .replaceAll('"', '')
                  .replaceAll("'", "");

              if (serverFileName.contains('.')) {
                extension = '.${serverFileName.split('.').last.toLowerCase()}';
              }
            }
          }

          // B. Coba deteksi dari header Content-Type (Kata kunci lebih longgar)
          if (extension.isEmpty) {
            final contentType =
                headers.value('content-type')?.toLowerCase() ?? '';
            if (contentType.contains('pdf')) {
              extension = '.pdf';
            } else if (contentType.contains('msword') ||
                contentType.contains('wordprocessingml')) {
              extension = '.docx';
            } else if (contentType.contains('excel') ||
                contentType.contains('spreadsheetml')) {
              extension = '.xlsx';
            } else if (contentType.contains('jpeg') ||
                contentType.contains('jpg')) {
              extension = '.jpg';
            } else if (contentType.contains('png')) {
              extension = '.png';
            }
          }

          // C. Fallback Mutlak
          if (extension.isEmpty || extension == '.') {
            AppLogger.warning(
              'AppFileDownloaderUtils: Server tidak merespons ekstensi! Fallback paksa ke .docx',
            );
            extension = '.docx';
          }

          String testPath = '${targetDir.path}/$sanitizedBaseName$extension';
          int counter = 1;

          while (File(testPath).existsSync()) {
            testPath =
                '${targetDir.path}/$sanitizedBaseName ($counter)$extension';
            counter++;
          }

          finalResolvedPath = testPath;

          AppLogger.info(
            'AppFileDownloaderUtils: Ekstensi $extension terdeteksi. Menyimpan ke -> $finalResolvedPath',
          );
          return finalResolvedPath!;
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 1),
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            if (int.parse(progress) % 25 == 0) {
              AppLogger.info(
                'AppFileDownloaderUtils: Progress unduh -> $progress%',
              );
            }
          }
        },
      );

      // Edge Case 4: Validasi Integritas File
      if (finalResolvedPath != null) {
        final downloadedFile = File(finalResolvedPath!);
        if (await downloadedFile.exists()) {
          if (await downloadedFile.length() == 0) {
            AppLogger.warning(
              'AppFileDownloaderUtils: File berukuran 0 bytes (Corrupt).',
            );
            await downloadedFile.delete();
            return null;
          }
          AppLogger.info(
            '✅ AppFileDownloaderUtils: Unduhan sukses -> $finalResolvedPath',
          );
          return finalResolvedPath;
        }
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error(
        '🚨 AppFileDownloaderUtils [DioError]: Gagal mengunduh file.\n'
        'URL: $url\n'
        'Status: ${e.response?.statusCode}\n'
        'Message: ${e.message}',
      );
      return null;
    } on FileSystemException catch (e) {
      AppLogger.error(
        '🚨 AppFileDownloaderUtils [IOError]: Gagal menulis ke lokal -> ${e.message}',
      );
      return null;
    } catch (e) {
      AppLogger.error('🚨 AppFileDownloaderUtils [UnknownError]: $e');
      return null;
    }
  }
}
