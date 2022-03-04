import 'package:flutter/material.dart';
import  "../models/user.dart";

class UserProvider extends ChangeNotifier{  
  ModelUser? _user;
  bool _isLogin = false;

  UserProvider(this._isLogin);

  setUser(Map<String,dynamic> user){
    _user = ModelUser(
      id : user["id"],
      name : user["name"],
      email : user["email"],
      photo:  user["photo"]
    );

    notifyListeners();
  }

  ModelUser? getUser(){
    return _user;
  }

  setIsLogin(isLogin){
    _isLogin = isLogin;
    notifyListeners();
  }

  bool getIsLogin(){
    return _isLogin;
  }
}