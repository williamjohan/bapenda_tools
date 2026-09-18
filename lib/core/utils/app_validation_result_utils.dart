// 1. Definisikan tipe presentasi error
enum ErrorDisplayType { snackbar, modal }

// 2. Buat objek hasil validasi
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final ErrorDisplayType displayType;

  // Constructor sukses
  ValidationResult.success()
    : isValid = true,
      errorMessage = null,
      displayType = ErrorDisplayType.snackbar;

  // Constructor gagal
  ValidationResult.failure(
    this.errorMessage, {
    this.displayType = ErrorDisplayType.snackbar, // Default
  }) : isValid = false;
}
