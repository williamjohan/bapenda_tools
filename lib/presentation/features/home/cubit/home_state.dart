// lib/presentation/features/home/cubit/home_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/services/update_service.dart';
import 'home_action.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isCheckingUpdate,
    UpdateInfo? updateInfo,
    HomeAction? action,
    @Default('Memuat...') String userName,
    @Default('') String userRole,
  }) = _HomeState;
}