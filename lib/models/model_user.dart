// ini cetakan buat data akun pengguna (admin atau asisten)
class UserModel {
  final int? idUser;
  final String nama;
  final String email;
  final String password;
  final String role; // aslinya cuma 'admin' atau 'asisten' aja sih

  UserModel({
    this.idUser,
    required this.nama,
    required this.email,
    required this.password,
    required this.role,
  });

  // fungsi buat ngerubah data dari map (database) jadi objek biar enak dipake di flutter
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['id_user'],
      nama: map['nama'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }

  // fungsi buat ngerubah objek balik lagi jadi map biar bisa disimpen ke database
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
