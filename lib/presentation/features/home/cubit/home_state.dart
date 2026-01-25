// lib/presentation/features/home/bloc/home_state.dart
import '../../../../core/services/update_service.dart';
import 'home_action.dart';

class HomeState {
  final bool isCheckingUpdate;
  final UpdateInfo? updateInfo;
  final HomeAction? action;

  const HomeState({
    required this.isCheckingUpdate,
    this.updateInfo,
    this.action,
  });

  factory HomeState.initial() {
    return const HomeState(
      isCheckingUpdate: false,
      updateInfo: null,
      action: null,
    );
  }

  HomeState copyWith({
    bool? isCheckingUpdate,
    UpdateInfo? updateInfo,
    HomeAction? action, // Allow passing null explicitly
    bool clearAction = false, // Helper flag if needed
  }) {
    return HomeState(
      isCheckingUpdate: isCheckingUpdate ?? this.isCheckingUpdate,
      updateInfo: updateInfo ?? this.updateInfo,
      action: clearAction ? null : (action ?? this.action),
    );
  }
}
