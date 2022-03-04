import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';

import '../pages/signin.dart';

class ProductAdd extends StatelessWidget{
  bool? isLogin;

  ProductAdd(BuildContext context){
    this.isLogin = Provider.of<UserProvider>(context).getIsLogin();
  } 

  Widget build(BuildContext context){
    if(isLogin != true){
      return Signin(context);
    }

    return MaterialApp(
      home : Scaffold(
        body : Text("Add/Edit Data")
      )
    );
  }
}