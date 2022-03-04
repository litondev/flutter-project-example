import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import "./pages/signin.dart";
import "./pages/signup.dart";
import "./pages/forgot_password.dart";
import "./pages/reset_password.dart";
import "./pages/dashboard.dart";
import "./pages/product.dart";
import "./pages/profil.dart";

import "./screens/product_add.dart";

import './providers/user.dart';
import "./providers/product.dart";

void main() async {
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();

  final isLogin = prefs.getString('token') != null 
    ? true
    : false;

  runApp(MyApp(isLogin));
}

class MyApp extends StatelessWidget {
  final isLogin;

  MyApp(this.isLogin);

  Widget build(BuildContext context){    
    return MultiProvider(
      providers : [
        ChangeNotifierProvider(
          create: (context) => UserProvider(isLogin)
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider()
        )      
      ],
      child : MaterialApp(
        routes: {
          '/' : (context) => Signin(context),
          '/signup' : (context) => Signup(context),
          '/forgot_password' : (context) => ForgotPassword(context),
          '/reset_password' : (context) => ResetPassword(context),

          '/dashboard' : (context) => Dashboard(context),

          '/product' : (context) => Product(context),
          "/product/add" : (context) => ProductAdd(context),
          
          '/profil' : (context) => Profil(context)
        },
      )    
    );
  }
} 
