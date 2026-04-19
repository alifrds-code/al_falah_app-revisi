import '../database/sqflite_helper.dart';
import '../services/local_storage_service.dart';
import '../models/model_user.dart';

class LoginController {
  Future<UserModel?> login(String email, String password) async {
    final userData = await DBHelper.login(email, password);
    if (userData != null) {
      final user = UserModel.fromMap(userData);
      await LocalStorageService.saveUser(user);
      return user;
    }
    return null;
  }

  Future<void> logout() async {
    await LocalStorageService.logout();
  }

  Future<UserModel?> getCurrentUser() async {
    return await LocalStorageService.getUser();
  }
}
