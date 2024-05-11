import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:realtimechatapp/state/Chat/ChatCubit.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';
import 'package:realtimechatapp/state/UserObserver.dart';
import 'firebase_options.dart';
import './pages/Home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = const StateObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => UserCubit()),
          BlocProvider(create: (_) => ChatCubit())
        ],
        child: MaterialApp(
          title: 'Chatty',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
                backgroundColor: Color.fromARGB(221, 255, 250, 250)),
            primaryColor: Color.fromARGB(221, 255, 237, 237),
            popupMenuTheme:
                PopupMenuThemeData(color: Color.fromARGB(221, 255, 237, 237)),
            cardColor: Color.fromARGB(255, 244, 244, 244),
            useMaterial3: true,
            /* light theme settings */
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: AppBarTheme(
                backgroundColor: const Color.fromARGB(221, 26, 26, 26)),
            primaryColor: Color.fromARGB(221, 44, 43, 43),
            popupMenuTheme:
                PopupMenuThemeData(color: Color.fromARGB(221, 48, 48, 48)),
            cardColor: const Color.fromARGB(255, 40, 40, 40),
            useMaterial3: true,
            /* dark theme settings */
          ),
          themeMode: ThemeMode.system,
          home: MyHomePage(),
        ));
  }
}
