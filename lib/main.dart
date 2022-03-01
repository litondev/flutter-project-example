import 'package:flutter/material.dart';

import "./pages/signin.dart";
import "./pages/signup.dart";
import "./pages/forgot_password.dart";
import "./pages/reset_password.dart";
import "./pages/dashboard.dart";
import "./pages/product.dart";
import "./pages/profil.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context){
    return MaterialApp(
      routes: {
        '/' : (ctx) => Signin(),
        '/signup' : (ctx) => Signup(),
        '/forgot_password' : (ctx) => ForgotPassword(),
        '/reset_password' : (ctx) => ResetPassword(),

        '/dashboard' : (ctx) => Dashboard(),
        '/product' : (ctx) => Product(),
        '/profil' : (ctx) => Profil()
      },
    );
  }
} 
