import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../components/spinner.dart';

class Signin extends StatelessWidget{
  Widget build(BuildContext context){
    return MaterialApp(
      home : Scaffold(      
        backgroundColor : Colors.white,
        body : Padding(
          padding : EdgeInsets.only(left : 20,right : 20),
          child : Column(    
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(                      
                child: 
                 SvgPicture.asset(
                  'images/signin.svg',
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
              children: [SigninButton()]
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
          primary: (isLoadingForm == true ? Colors.green[600] : Colors.green[700]),
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


        if(response.statusCode == 400){
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
          
          Fluttertoast.showToast(
            msg: "Berhasil login",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,         
          );
        }else{
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
          msg: "Something Wrong",
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