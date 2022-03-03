import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "../components/sidebar.dart";

import '../providers/user.dart';

import './signin.dart';

class Product extends StatelessWidget{
   bool? isLogin;

  Product(BuildContext context){
    this.isLogin = Provider.of<User>(context).getIsLogin();
  } 

  Widget build(BuildContext context){
    if(isLogin != true){
      return Signin(context);
    }

    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title : Text("Product"),      
        ),
        drawer: Sidebar(parentContext: context),
        body : Text("Product")
      )
    );
  }
}