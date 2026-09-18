import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_api_response_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseApiResponseModel<T> {
  @JsonKey(name: 'isSuccess', defaultValue: false)
  final bool isSuccess;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'status', defaultValue: 500)
  final int status;

  @JsonKey(name: 'traceId')
  final String? traceId;

  @JsonKey(name: 'errors')
  final dynamic errors;

  @JsonKey(name: 'data')
  final T? data;

  const BaseApiResponseModel({
    required this.isSuccess,
    this.title,
    required this.status,
    this.traceId,
    this.errors,
    this.data,
  });

  /// Factory untuk membedah JSON dari Dio menggunakan fungsi konverter tipe T
  factory BaseApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseApiResponseModelFromJson(json, fromJsonT);

  /// Method serializer ke JSON (opsional, berguna untuk logging/testing)
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseApiResponseModelToJson(this, toJsonT);

  /// 🚨 AUDITOR HELPER METHOD:
  /// Membantu DataSource mendapatkan pesan error yang paling deskriptif
  /// jika isSuccess == false, tanpa perlu membongkar struktur manual berulang kali.
  String get errorMessage {
    if (errors != null) {
      if (errors is String && (errors as String).isNotEmpty) {
        return errors as String;
      }
      if (errors is List && (errors as List).isNotEmpty) {
        return (errors as List).join(', ');
      }
      if (errors is Map && (errors as Map).isNotEmpty) {
        final List<String> errorMessages = [];
        (errors as Map).forEach((key, value) {
          if (value is List) {
            errorMessages.add('$key: ${value.join(', ')}');
          } else {
            errorMessages.add('$key: $value');
          }
        });
        return errorMessages.join(' | ');
      }
      return errors.toString();
    }
    return title ?? 'Terjadi kesalahan pada server Bapenda (Status: $status)';
  }
}
