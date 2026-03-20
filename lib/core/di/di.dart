import 'package:flutter_chat_room_app/data/dataSource/userdatasource/user_data_source_remote.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_chat_room_app/data/dataSource/authdatasource/auth_data_source.dart';
import 'package:flutter_chat_room_app/data/dataSource/authdatasource/auth_data_source_remote.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_remote_data_source.dart';
import 'package:flutter_chat_room_app/data/dataSource/userdatasource/user_data_source.dart'; // جدید
import 'package:flutter_chat_room_app/data/repository/authrepository/auth_repository.dart';
import 'package:flutter_chat_room_app/data/repository/chatrepository/chat_repository_impl.dart';
import 'package:flutter_chat_room_app/data/repository/userrepository/user_repository_impl.dart'; // جدید
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart'; // جدید
import 'package:flutter_chat_room_app/domain/usecase/authentication/log_out_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/login_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/register_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_all_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/listen_to_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/send_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/private_chat_use_case.dart'; // جدید
import 'package:flutter_chat_room_app/domain/usecase/user/search_user_use_case.dart'; // جدید

final locator = GetIt.instance;

Future<void> getItInit() async {
  locator.registerSingleton<PocketBase>(
    PocketBase('https://messageflow-aelbqjwyta.liara.run'),
  );

  // ۲. دیتاسورس‌ها (DataSources)
  locator.registerLazySingleton<IAuthDataSource>(
    () => AuthDataSourceRemote(locator<PocketBase>()),
  );

  locator.registerLazySingleton<IChatDatasource>(
    () => ChatRemoteDataSourceImpl(locator<PocketBase>()),
  );

  locator.registerLazySingleton<IUserDataSource>(
    () => UserDataSourceRemote(locator<PocketBase>()),
  );

  // ۳. ریپازیتوری‌ها (Repositories)
  locator.registerLazySingleton<IAuthenticationRepository>(
    () => AuthRepositoryImpl(locator<IAuthDataSource>()),
  );

  locator.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(locator<IChatDatasource>()),
  );

  locator.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(locator<IUserDataSource>()),
  );

  // ۴. یوزکیس‌ها (UseCases)
  // --- Auth ---
  locator.registerLazySingleton(() => LoginUseCase(locator<IAuthenticationRepository>()));
  locator.registerLazySingleton(() => RegisterUseCase(locator<IAuthenticationRepository>()));
  locator.registerLazySingleton(() => LogOutUseCase(locator<IAuthenticationRepository>()));

  // --- Chat ---
  locator.registerLazySingleton(() => GetAllChatUseCase(locator<IChatRepository>()));
  locator.registerLazySingleton(() => GetMessageUseCase(locator<IChatRepository>()));
  locator.registerLazySingleton(() => ListenToMessageUseCase(locator<IChatRepository>()));
  locator.registerLazySingleton(() => SendMessageUseCase(locator<IChatRepository>()));
  locator.registerLazySingleton(() => PrivateChatUseCase(locator<IChatRepository>()));

  // --- User ---
  locator.registerLazySingleton(() => SearchUserUseCase(locator<IUserRepository>()));
}
