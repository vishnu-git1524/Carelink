import 'package:carelink/screens/home.dart';
import 'package:carelink/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import 'screens/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

late Size mq;


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
      ],
      child: MaterialApp(
        themeMode: ThemeMode.system,
        routes: {
          '/home': (context) => Home(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Atlas',
                theme: lightThemeData(context),
        darkTheme: darkThemeData(context),
        // theme: buildLightChatTheme(),
        // darkTheme: buildDarkChatTheme(),
        home: SplashScreen(),
      ),
    );
  }
}
