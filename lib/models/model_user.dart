import 'dart:convert';

class UserModel {
  final String? uid;
  final String nama;
  final String email;
  final String password;
  final String role;

  UserModel({
    this.uid,
    required this.nama,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? map['id'],
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'asisten',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
