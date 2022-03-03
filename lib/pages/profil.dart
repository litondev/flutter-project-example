import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "../components/sidebar.dart";

import '../providers/user.dart';

class Profil extends StatelessWidget{
  Profil(BuildContext context){
    final isLogin = Provider.of<User>(context).getIsLogin();
    
    if(isLogin != true){
      Navigator.of(context).pushReplacementNamed("/");
    }
  }

  Widget build(BuildContext context){
    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title : Text("Profil"),      
        ),
        drawer: Sidebar(),
        body : Text("Profil")
      )
    );
  }
}