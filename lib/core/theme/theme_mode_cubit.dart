import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../storage/app_preference.dart';

/// Pilihan tampilan (Sistem / Terang / Gelap), disimpan di SharedPreferences.
@lazySingleton
class ThemeModeCubit extends Cubit<ThemeMode> {
  final AppPreferences _preferences;

  ThemeModeCubit(this._preferences)
    : super(_decode(_preferences.getThemeMode()));

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _preferences.setThemeMode(mode.name);
  }

  static ThemeMode _decode(String value) => ThemeMode.values.firstWhere(
    (m) => m.name == value,
    orElse: () => ThemeMode.system,
  );
}
