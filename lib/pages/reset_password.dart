import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../components/spinner.dart';

class ResetPassword extends StatelessWidget{
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
                  'images/reset_password.svg',
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 200,
                )
              ),            
              ResetPasswordScreen(),
            ]
          )
        )
      )
    );
  }
}

class ResetPasswordScreen extends StatefulWidget{
  @override 
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen>{  
  final formKey = GlobalKey<FormState>();

  String email = '';
  String token = '';
  String password = '';
  String password_confirm = '';
  bool isLoadingForm = false;

  @override 
  Widget build(BuildContext context){
    // GET EMAIL
    email = ModalRoute.of(context)?.settings.arguments as String;

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
              children: [ResetPasswordButton()]
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
    );
  }

  Widget ResetPasswordButton(){
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
          Uri.parse(dotenv.env['API_URL']! + "/reset_password"),
          headers : {
             "Content-Type": "application/json"
          },
          body : jsonEncode({
            "token" : token,
            "email" : email,
            "password" : password,
            "password_confirm" : password_confirm
          })
        );    

        print(json.decode(response.body));
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