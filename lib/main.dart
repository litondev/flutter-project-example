import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import "./pages/signin.dart";
import "./pages/signup.dart";
import "./pages/forgot_password.dart";
import "./pages/reset_password.dart";
import "./pages/dashboard.dart";
import "./pages/product.dart";
import "./pages/profil.dart";

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
