import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "../components/sidebar.dart";

import '../providers/user.dart';

import './signin.dart';

class Profil extends StatelessWidget{
  bool? isLogin;

  Profil(BuildContext context){
    this.isLogin = Provider.of<UserProvider>(context).getIsLogin();
  } 

  Widget build(BuildContext context){
    if(isLogin != true){
      return Signin(context);
    }

    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title : Text("Profil"),      
        ),
        drawer: Sidebar(parentContext: context),
        body : Text("Profil")
      )
    );
  }
}