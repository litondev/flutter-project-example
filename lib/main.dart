import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import "./pages/signin.dart";
import "./pages/signup.dart";
import "./pages/forgot_password.dart";
import "./pages/reset_password.dart";
import "./pages/dashboard.dart";
import "./pages/product.dart";
import "./pages/profil.dart";

void main() async {
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();

  bool isLogin = prefs.getString('token') != null 
    ? true
    : false;

  runApp(MyApp(isLogin));
}

class MyApp extends StatelessWidget {
  bool isLogin;

  MyApp(this.isLogin);

  Widget build(BuildContext context){    
    return MaterialApp(
      routes: {
        '/' : (context) => Signin(),
        '/signup' : (context) => Signup(),
        '/forgot_password' : (context) => ForgotPassword(),
        '/reset_password' : (context) => ResetPassword(),

        '/dashboard' : (context) => Dashboard(),
        '/product' : (context) => Product(),
        '/profil' : (context) => Profil()
      },
    );
  }
} 
