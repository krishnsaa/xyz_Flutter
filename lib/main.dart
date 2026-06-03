import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myquiz/pages/authProvider.dart';
import 'package:myquiz/pages/loginpage.dart';
import 'package:myquiz/pages/home.dart';
import 'package:myquiz/pages/registerpage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'XYZ Quiz App',

          home: authProvider.userId != null ? const Home() : const LoginPage(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/home': (context) => const Home(),
            '/register': (context) => const RegisterPage(),
          },
        );
      },
    );
  }
}
