import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../components/spinner.dart';

import '../providers/user.dart';

import "./dashboard.dart";

class Signin extends StatelessWidget{
  bool? isLogin;

  Signin(BuildContext context){
    this.isLogin = Provider.of<UserProvider>(context).getIsLogin();
  } 

  Widget build(BuildContext context){
    if(isLogin == true){
      return Dashboard(context);
    }

    return MaterialApp(
      home : Scaffold(      
        backgroundColor : Colors.white,
        body : Padding(
          padding : EdgeInsets.only(
            left : 20,
            right : 20
          ),
          child : Column(    
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(                      
                child: Image.asset(
                  'images/signin.png',
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 200,
                )
              ),            
              SigninScreen(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children : [                
                  TextButton(
                      onPressed: (){
                        Navigator.of(context).pushReplacementNamed("/signup");
                      },
                      child : Text("Daftar",
                      style : TextStyle(
                        color: Colors.blueAccent
                      )
                    )
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }
}

class SigninScreen extends StatefulWidget{
  final BuildContext parentContext;

  SigninScreen(this.parentContext);

  @override 
  SigninScreenState createState() => SigninScreenState(this.parentContext);
}

class SigninScreenState extends State<SigninScreen>{
  final BuildContext parentContext;

  SigninScreenState(this.parentContext);

  final formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool isLoadingForm = false;

  @override 
  void dispose(){    
    super.dispose();
  }

  @override 
  Widget build(BuildContext context){
    return Container(
      child : Form(
        key: formKey,
        child: Column(
          children: [
            EmailField(),
            PasswordField(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children : [
                TextButton(
                  onPressed: (){
                    Navigator.of(parentContext).pushReplacementNamed("/forgot_password");
                  },
                  child: Text("Lupa Password",
                    style : TextStyle(
                      color: Colors.blueAccent
                    )
                  ),            
                )
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SigninButton()
              ]
            ),            
          ],
        ),
      )
    );
  }

  Widget EmailField(){
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Email",
        // hintText: "*Masukan email"
      ),
      validator: (value) {        
        if(value!.isEmpty){
          return "Email tidak boleh kosong";
        }

        return null;
      },
      onSaved: (String? value) { 
        email = value.toString();
      },
    );
  }

  Widget PasswordField(){
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Password",
        // hintText: "*Masukan password"
      ),
      validator: (value){
        if(value!.isEmpty){
          return "Password tidak boleh kosong";
        }

        if(value.length <= 7){
          return "Password tidak boleh kurang dari 8";
        }

        return null;
      },
      onSaved: (String? value) { 
        password = value.toString();
      },
    );
  }

  Widget SigninButton(){
    return ElevatedButton(
      style : ElevatedButton.styleFrom(
          primary: isLoadingForm == true 
            ? Colors.green[600] 
            : Colors.green[700],
          onPrimary: Colors.white,          
          textStyle: TextStyle(
            fontSize: 16
          ),
          fixedSize : Size(130,40)
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            isLoadingForm == true
              ? Spinner( icon: Icons.rotate_right )        
              : Icon( Icons.save),
            Padding(
              padding: EdgeInsets.only(left : 5),
              child : Text("Kirim")
            )
          ],
        )
      ),
      onPressed: (){
        if(formKey.currentState!.validate()){
            formKey.currentState?.save(); 
            onSubmit();
        }
      },
    );
  }

  void onSubmit() async {
    if(isLoadingForm) return;

    setState(() {    
      isLoadingForm = true;
    });    
    
    try{    
        var response = await http.post(
          Uri.parse(dotenv.env['API_URL']! + "/signin"),
          headers : {
             "Content-Type": "application/json"
          },
          body : jsonEncode({
            "email" : email,
            "password" : password,
          })
        );    

        if(response.statusCode == 404){
          Fluttertoast.showToast(
            msg: "Url tidak ditemukan",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,         
          );
        }else if(response.statusCode == 422){
          var message = json.decode(response.body);

          Fluttertoast.showToast(
            msg: message["message"],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,         
          );
        }else if(response.statusCode == 500){
          var message = json.decode(response.body);

          Fluttertoast.showToast(
            msg: message["message"] ?? "Terjadi Kesalahan",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,         
          );
        }else if(response.statusCode == 200){
          var responseBody = json.decode(response.body);

          print(responseBody);

          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('token', 'Bearer '+responseBody["access_token"]);
          // await prefs.setString('user',json.encode(responseBody["user"]));
          
          Provider.of<UserProvider>(context,listen: false).setIsLogin(true);        
        }else{
          print(response.statusCode);
          
          Fluttertoast.showToast(
            msg: "Terjadi Kesalahan",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,         
          );
        }
    }catch(e){
      print(e);

      Fluttertoast.showToast(
          msg: "Terjadi Kesalahan",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,         
      );

      setState(() {    
        isLoadingForm = false;
      });
    }
  }
}