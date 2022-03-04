import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'dart:convert';

import '../components/spinner.dart';

import '../providers/user.dart';

import "./dashboard.dart";

class ForgotPassword extends StatelessWidget{
  bool? isLogin;

  ForgotPassword(BuildContext context){
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
                child: 
                 Image.asset(
                  'images/forgot-password.png',
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 200,
                )
              ),            
              ForgotPasswordScreen(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children : [                
                  TextButton(
                      onPressed: (){
                        Navigator.of(context).pushReplacementNamed("/");
                      },
                      child : Text("Masuk",
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

class ForgotPasswordScreen extends StatefulWidget{
  final parentContext;

  ForgotPasswordScreen(this.parentContext);

  @override 
  ForgotPasswordState createState() => ForgotPasswordState(parentContext);
}

class ForgotPasswordState extends State<ForgotPasswordScreen>{  
  final formKey = GlobalKey<FormState>();
  final parentContext;

  String email = '';
  bool isLoadingForm = false;

  ForgotPasswordState(this.parentContext);

  @override 
  Widget build(BuildContext context){
    return Container(
      child : Form(
        key: formKey,
        child: Column(
          children: [
            EmailField(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ForgotPasswordButton()
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


  Widget ForgotPasswordButton(){
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
          Uri.parse(dotenv.env['API_URL']! + "/forgot-password"),
          headers : {
             "Content-Type": "application/json"
          },
          body : jsonEncode({          
            "email" : email,        
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
          print(message);

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
          Navigator.of(parentContext).pushReplacementNamed("/reset_password",
            arguments : {
              "email" : email
            }
          );
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
    }finally{
      setState(() {    
        isLoadingForm = false;
      });
    }
  }
}