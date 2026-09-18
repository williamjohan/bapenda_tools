// lib/core/errors/exception.dart

/// Class parent for all exceptions in the app
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

// ======================
// Network / Server Exceptions
// ======================

class ServerException extends AppException {
  final int statusCode;
  const ServerException(this.statusCode, [String? message])
    : super(message ?? "Terjadi kesalahan pada server.");
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String? message])
    : super(message ?? "Sesi Anda telah berakhir. Silakan login kembali.");
}

class TimeoutException extends AppException {
  const TimeoutException([String? message])
    : super(
        message ??
            "Permintaan ke server melebihi batas waktu. Silakan coba lagi.",
      );
}

class NoInternetException extends AppException {
  const NoInternetException([String? message])
    : super(message ?? "Tidak ada koneksi internet. Periksa jaringan Anda.");
}

// ======================
// Upload Image / File Exceptions
// ======================

class FileException extends AppException {
  const FileException([String? message])
    : super(message ?? "Terjadi kesalahan pada file.");
}

class FileTooLargeException extends FileException {
  const FileTooLargeException([String? message])
    : super(message ?? "Ukuran file terlalu besar.");
}

class UnsupportedFileTypeException extends FileException {
  const UnsupportedFileTypeException([String? message])
    : super(message ?? "Jenis file tidak didukung.");
}

class FileUploadFailedException extends FileException {
  const FileUploadFailedException([String? message])
    : super(message ?? "Gagal mengunggah file.");
}

// ======================
// Pdf Export / File System Exceptions
// ======================

class PdfException extends AppException {
  const PdfException([String? message])
    : super(message ?? "Terjadi kesalahan pada dokumen PDF.");
}

class PdfGenerationException extends PdfException {
  const PdfGenerationException([String? message])
    : super(message ?? "Gagal membuat file PDF.");
}

// ======================
// Local Storage / Cache Exceptions
// ======================

class CacheException extends AppException {
  const CacheException([String? message])
    : super(
        message ??
            "Terjadi kesalahan saat memproses data di penyimpanan lokal.",
      );
}

class StoragePermissionException extends AppException {
  const StoragePermissionException([String? message])
    : super(message ?? "Izin penyimpanan diperlukan untuk melanjutkan.");
}

class FileWriteException extends AppException {
  const FileWriteException([String? message])
    : super(message ?? "Gagal menyimpan file ke perangkat.");
}

// ======================
// Parsing and Data Exceptions
// ======================

class ParsingException extends AppException {
  const ParsingException([String? message])
    : super(message ?? "Gagal memproses data dari server.");
}

class InvalidDataException extends AppException {
  const InvalidDataException([String? message])
    : super(message ?? "Data yang diterima tidak valid.");
}

// ======================
// Permission and Feature Exceptions
// ======================

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([String? message])
    : super(message ?? "Akses ditolak. Izin tidak diberikan.");
}

class FeatureNotAvailableException extends AppException {
  const FeatureNotAvailableException([String? message])
    : super(message ?? "Fitur ini tidak tersedia di perangkat Anda.");
}

// ======================
// Location / Maps Exceptions (🔥 Tambahan Baru)
// ======================

class GeocodingException extends AppException {
  const GeocodingException([String? message])
    : super(message ?? "Gagal menemukan alamat dari titik koordinat tersebut.");
}

class LocationNotFoundException extends AppException {
  const LocationNotFoundException([String? message])
    : super(message ?? "Alamat atau nama tempat tidak ditemukan.");
}

// ======================
// Fallback Exception
// ======================

class UnknownException extends AppException {
  const UnknownException([String? message])
    : super(message ?? "Terjadi kesalahan. Silakan coba lagi.");
}
