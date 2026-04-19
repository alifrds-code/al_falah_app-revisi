// Cetakan data pengguna (Admin & Asisten)
class UserModel {
  final int? idUser;
  final String nama;
  final String email;
  final String password;
  final String role; // 'admin' atau 'asisten'

  UserModel({
    this.idUser,
    required this.nama,
    required this.email,
    required this.password,
    required this.role,
  });

  // Membuat UserModel dari data Map (dari database)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['id_user'],
      nama: map['nama'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }

  // Mengubah UserModel kembali jadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
