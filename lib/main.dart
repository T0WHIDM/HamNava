import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/routing/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await getItInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HamNava',
      routerConfig: appGlobalRouter,
    );
  }
}
