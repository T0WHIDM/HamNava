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
  ) async {
    try {
      final body = <String, dynamic>{
        "email": email,
        "userName": userName,
        "name": name,
        "password": password,
        "passwordConfirm": passwordConfirm,
        "emailvisibility": true,
      };

      await pb.collection('users').create(body: body);
    } on ClientException catch (e) {
      final errorData = e.response['data'];

      if (errorData != null && errorData['username'] != null) {
        throw ApiException("این نام کاربری قبلاً توسط شخص دیگری رزرو شده است.");
      } else if (errorData != null && errorData['email'] != null) {
        throw ApiException("این ایمیل قبلاً در سیستم ثبت شده است.");
      }

      throw e.response['message'];
    }
  }
}
