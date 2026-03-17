import 'package:flutter_chat_room_app/core/pocketbase/pocket_base.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_remote_data_source.dart';
import 'package:flutter_chat_room_app/data/repository/chatrepository/chat_repository_impl.dart';
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_reposiroty.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/login_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/register_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_all_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/listen_to_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/send_message_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';

var locator = GetIt.instance;

Future<void> getItInit() async {
  //pocketBase
  locator.registerSingleton<PocketBase>(PocketBaseClient.pb);

  //useCase
  locator.registerSingleton<GetAllChatUseCase>(
    GetAllChatUseCase(locator<IChatRepository>()),
  );

  locator.registerSingleton<GetMessageUseCase>(
    GetMessageUseCase(locator<IChatRepository>()),
  );

  locator.registerSingleton<ListenToMessageUseCase>(
    ListenToMessageUseCase(locator<IChatRepository>()),
  );

  locator.registerSingleton<SendMessageUseCase>(
    SendMessageUseCase(locator<IChatRepository>()),
  );

  locator.registerSingleton<LoginUseCase>(
    LoginUseCase(locator<IAuthenticationReopsitory>()),
  );

  locator.registerSingleton<RegisterUseCase>(
    RegisterUseCase(locator<IAuthenticationReopsitory>()),
  );

  //repositories
  locator.registerFactory<IChatRepository>(() => locator<ChatRepositoryImpl>());

  //dataSource
  locator.registerFactory<IChatDataSource>(() => locator<ChatDataSourceImpl>());
}
