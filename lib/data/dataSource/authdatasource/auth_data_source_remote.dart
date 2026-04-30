import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dataSource/authdatasource/auth_data_source.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthDataSourceRemote extends IAuthDataSource {
  final PocketBase pb;
  AuthDataSourceRemote(this.pb);

  //login
  @override
  Future<void> login(String userName, String password) async {
    try {
      await pb.collection('users').authWithPassword(userName, password);
    } catch (e) {
      throw ApiException('نام کاربری یا رمز عبور اشتباه است');
    }
  }

  //logOut
  @override
  Future<void> logOut() async => pb.authStore.clear();

  //register
  @override
  Future<void> register(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirm,
    // File? avatarFile,
  ) async {
    try {
      final body = <String, dynamic>{
        'userName': userName,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'name': name,
        'emailVisibility': true,
      };

      // List<http.MultipartFile> files = [];
      // if (avatarFile != null) {
      //   files.add(await http.MultipartFile.fromPath('avatar', avatarFile.path));
      // }

      await pb.collection('users').create(body: body);
      await login(userName, password);
    } on ClientException catch (e) {
      throw ApiException(e.response['message'] ?? 'خطا در ارتباط با سرور');
    } catch (e) {
      throw ApiException('خطای نامشخص در ثبت نام');
    }
  }
}
