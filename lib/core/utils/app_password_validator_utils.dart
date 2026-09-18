class PasswordValidationStatus {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final bool hasNoSpace;
  final bool isMatch;

  const PasswordValidationStatus({
    this.hasMinLength = false,
    this.hasUppercase = false,
    this.hasLowercase = false,
    this.hasNumber = false,
    this.hasSpecialChar = false,
    this.hasNoSpace = false,
    this.isMatch = false,
  });

  bool get isValid =>
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasNumber &&
      hasSpecialChar &&
      hasNoSpace &&
      isMatch;
}

class AppPasswordValidatorUtils {
  static PasswordValidationStatus validate(
    String password,
    String confirmPassword,
  ) {
    if (password.isEmpty) {
      return const PasswordValidationStatus();
    }

    return PasswordValidationStatus(
      hasMinLength: password.length >= 8,
      hasUppercase: password.contains(RegExp(r'[A-Z]')),
      hasLowercase: password.contains(RegExp(r'[a-z]')),
      hasNumber: password.contains(RegExp(r'[0-9]')),
      // Karakter khusus: selain huruf, angka, dan spasi
      hasSpecialChar: password.contains(RegExp(r'[^a-zA-Z0-9\s]')),
      // Tidak mengandung spasi
      hasNoSpace: !password.contains(' '),
      // Match jika confirm tidak kosong dan sama persis
      isMatch: confirmPassword.isNotEmpty && password == confirmPassword,
    );
  }
}
