

import 'package:cekreklamemobile/domain/entities/users/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.name,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      username: json['username'] ?? json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'name': name, 'role': role};
  }
}
