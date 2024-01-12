import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/screen/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VietFresh',
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 147, 229, 250),
          surface: const Color.fromARGB(255, 1, 94, 15),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 235, 235),
        primaryColorLight: const Color.fromARGB(255, 230, 228, 193),
        primaryColorDark: const Color.fromARGB(255, 161, 161, 147),
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 1, 94, 15), // Màu nền của AppBar
          iconTheme: IconThemeData(color: Colors.white), // Màu icon
          titleTextStyle: TextStyle(
            color: Colors.white, // Màu chữ của tiêu đề
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme:const BottomNavigationBarThemeData(
          selectedItemColor: Colors.yellow, // Màu khi item được chọn
          unselectedItemColor: Colors.white, // Màu khi item không được chọn
        ),
      ),
      home: const UserScreen(),
    );
  }
}
