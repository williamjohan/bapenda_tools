import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String name;
  final String? role;

  const UserEntity({
    required this.id,
    required this.username,
    required this.name,
    this.role,
  });

  @override
  List<Object?> get props => [id, username, name, role];
}
