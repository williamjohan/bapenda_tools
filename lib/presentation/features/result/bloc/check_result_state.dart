// lib/presentation/features/result/bloc/check_result_state.dart
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/billboard_entity.dart';

abstract class CheckResultState extends Equatable {
  const CheckResultState();

  @override
  List<Object?> get props => [];
}

class CheckResultInitial extends CheckResultState {}

class CheckResultLoading extends CheckResultState {}

class CheckResultLoaded extends CheckResultState {
  final List<BillboardEntity> results;

  const CheckResultLoaded(this.results);

  @override
  List<Object?> get props => [results];
}

class CheckResultError extends CheckResultState {
  final String message;

  const CheckResultError(this.message);

  @override
  List<Object?> get props => [message];
}

class CheckResultReporting extends CheckResultState {}

class CheckResultReportSuccess extends CheckResultState {
  final String message;
  CheckResultReportSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CheckResultReportError extends CheckResultState {
  final String message;
  CheckResultReportError(this.message);

  @override
  List<Object?> get props => [message];
}
