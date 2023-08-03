import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo_app/register.dart';
import './screens/home.dart';
import 'checkLogin.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return FutureBuilder<bool>(
      future: SharedPreferencesHelper.isLoggedIn,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final isLoggedIn = snapshot.data ?? false;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ToDo App',
            home: isLoggedIn ? Home() : MyLogin(),
          );
        } else {
          // Show a loading indicator or a splash screen while waiting for the future to complete
          return CircularProgressIndicator();
        }
      },
    );
  }
}
