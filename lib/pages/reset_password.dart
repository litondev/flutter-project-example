import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'dart:convert';

import '../components/spinner.dart';

import '../providers/user.dart';

class ResetPassword extends StatelessWidget{
  ResetPassword(BuildContext context){
    final isLogin = Provider.of<User>(context).getIsLogin();

    if(isLogin == true){
      Navigator.of(context).pushReplacementNamed("/dashboard");
    }
  }

  Widget build(BuildContext context){    
   final arguments = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>;   

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
                  'images/reset-password.png',
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 200,
                )
              ),            
              ResetPasswordScreen(
                email : arguments["email"],
                parentContext : context
              ),
            ]
          )
        )
      )
    );
  }
}

class ResetPasswordScreen extends StatefulWidget{
  final email;
  final parentContext;

  ResetPasswordScreen({
    @required this.email,
    @required this.parentContext
  });

  @override 
  ResetPasswordScreenState createState() => ResetPasswordScreenState(
    email : email,
    parentContext : parentContext
  );
}

class ResetPasswordScreenState extends State<ResetPasswordScreen>{  

  final formKey = GlobalKey<FormState>();
  final parentContext;
  
  String? email = '';
  String token = '';
  String password = '';
  String password_confirm = '';
  bool isLoadingForm = false;
  

  ResetPasswordScreenState({
    @required this.email,
    @required this.parentContext
  });

  @override 
  Widget build(BuildContext context){
    return Container(
      child : Form(
        key: formKey,
        child: Column(
          children: [
            TokenField(),          
            PasswordField(),      
            PasswordConfirmField(),    
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ResetPasswordButton()
              ]
            ),            
          ],
        ),
      )
    );
  }

  Widget TokenField(){
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Code",
        // hintText: "*Masukan email"
      ),
      validator: (value) {        
        if(value!.isEmpty){
          return "Code tidak boleh kosong";
        }

        return null;
      },
      onSaved: (String? value) { 
        token = value.toString();
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


  Widget PasswordConfirmField(){
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Password Konfirmasi",
        // hintText: "*Masukan password"
      ),
      validator: (value){
        if(value!.isEmpty){
          return "Password konfirmasi tidak boleh kosong";
        }

        if(value.length <= 7){
          return "Password konfirmasi tidak boleh kurang dari 8";
        }

        return null;
      },
      onSaved: (String? value) { 
        password_confirm = value.toString();
      },
    );
  }

  Widget ResetPasswordButton(){
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
          Uri.parse(dotenv.env['API_URL']! + "/reset-password"),
          headers : {
             "Content-Type": "application/json"
          },
          body : jsonEncode({
            "token" : token,
            "email" : email,
            "password" : password,
            "password_confirmation" : password_confirm
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
          Navigator.of(parentContext).pushReplacementNamed("/");
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