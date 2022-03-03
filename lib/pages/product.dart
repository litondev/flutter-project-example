import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "../components/sidebar.dart";

import '../providers/user.dart';

class Product extends StatelessWidget{
  Product(BuildContext context){
    final isLogin = Provider.of<User>(context).getIsLogin();

    if(isLogin != true){
      Navigator.of(context).pushReplacementNamed("/");
    }
  }

  Widget build(BuildContext context){
    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title : Text("Product"),      
        ),
        drawer: Sidebar(),
        body : Text("Product")
      )
    );
  }
}