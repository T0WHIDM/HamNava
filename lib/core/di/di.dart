import 'package:flutter_chat_room_app/data/dataSource/userdatasource/user_data_source_remote.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/add_friend_to_group_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/create_group_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/delete_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/delete_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/edit_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/leave_from_group_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/add_friend_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/friend_list_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/get_profile_info_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/update_profile_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_chat_room_app/data/dataSource/authdatasource/auth_data_source.dart';
import 'package:flutter_chat_room_app/data/dataSource/authdatasource/auth_data_source_remote.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_remote_data_source.dart';
import 'package:flutter_chat_room_app/data/dataSource/userdatasource/user_data_source.dart'; 
import 'package:flutter_chat_room_app/data/repository/authrepository/auth_repository.dart';
import 'package:flutter_chat_room_app/data/repository/chatrepository/chat_repository_impl.dart';
import 'package:flutter_chat_room_app/data/repository/userrepository/user_repository_impl.dart'; 
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart'; 
import 'package:flutter_chat_room_app/domain/usecase/authentication/log_out_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/login_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/register_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_all_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/listen_to_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/send_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/private_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/search_user_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

final locator = GetIt.instance;

Future<void> getItInit() async {
  // sharedprefrences
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  //pocketBase
  final store = AsyncAuthStore(
    initial: prefs.getString('pb_auth'),
    save: (String data) async => await prefs.setString('pb_auth', data),
    clear: () async => await prefs.remove('pb_auth'),
  );
  const apiUrl = String.fromEnvironment('API_URL');
  locator.registerSingleton<PocketBase>(PocketBase(apiUrl, authStore: store));

  //--- DataSources ---
  locator.registerLazySingleton<IAuthDataSource>(
    () => AuthDataSourceRemote(locator<PocketBase>()),
  );
  locator.registerLazySingleton<IChatDatasource>(
    () => ChatRemoteDataSourceImpl(locator<PocketBase>()),
  );
  locator.registerLazySingleton<IUserDataSource>(
    () => UserDataSourceRemote(locator<PocketBase>()),
  );

  // --- Repositories ---
  locator.registerLazySingleton<IAuthenticationRepository>(
    () => AuthRepositoryImpl(locator<IAuthDataSource>()),
  );
  locator.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(locator<IChatDatasource>()),
  );
  locator.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(locator<IUserDataSource>()),
  );

  // --- UseCases ---
  
  // --- Auth ---
  locator.registerLazySingleton(
    () => LoginUseCase(locator<IAuthenticationRepository>()),
  );
  locator.registerLazySingleton(
    () => RegisterUseCase(locator<IAuthenticationRepository>()),
  );
  locator.registerLazySingleton(
    () => LogOutUseCase(locator<IAuthenticationRepository>()),
  );

  // --- Chat ---
  locator.registerLazySingleton(
    () => CreateGroupUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => DeleteChatUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => DeleteMessageUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => EditMessageUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => GetAllChatUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => GetMessageUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => ListenToMessageUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => SendMessageUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => PrivateChatUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => AddFriendToGroupUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => LeaveFromGroupUseCase(locator<IChatRepository>()),
  );

  // --- User ---
  locator.registerLazySingleton(
    () => SearchUserUseCase(locator<IUserRepository>()),
  );
  locator.registerLazySingleton(
    () => UpdateProfileUseCase(locator<IUserRepository>()),
  );
  locator.registerLazySingleton(
    () => AddFriendUseCase(locator<IUserRepository>()),
  );
  locator.registerLazySingleton(
    () => FriendListUseCase(locator<IUserRepository>()),
  );
  locator.registerLazySingleton(
    () => GetProfileInfoUseCase(locator<IUserRepository>()),
  );
}
