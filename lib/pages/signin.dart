import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:math' as math;

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
                child: Image(
                  image: AssetImage('images/signin.svg'),
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 80,
                )
              ),            
              SigninScreen()
            ]
          )
        )
      )
    );
  }
}

class SigninScreen extends StatefulWidget{
  @override 
  SigninScreenState createState() => SigninScreenState();
}

class SigninScreenState extends State<SigninScreen>{
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
                    Navigator.of(context).pushReplacementNamed("/forgot_password");
                  },
                  child: Text("Lupa Password",
                    style : TextStyle(
                      color: Colors.blueAccent
                    )
                  ),            
                )
              ]
            ),
            SigninButton(),
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

  Widget SigninButton(){
    return ElevatedButton(
      style : ElevatedButton.styleFrom(
          primary: Colors.greenAccent,
          onPrimary: Colors.greenAccent,
          fixedSize : Size(150,50)
      ),
      child: Center(
        child: Row(
          children: [
            isLoadingForm 
            ? Transform.rotate(
                angle: 180 * math.pi / 180,
                child: Icon( Icons.rotate_left )
              ) 
            : Icon( Icons.save),
            Text("Save")
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
          Uri.parse(dotenv.env['API_URL']! + "/product"),
          headers : {
             "Content-Type": "application/json"
          },
          body : jsonEncode({
            "email" : email,
            "password" : password,
          })
        );    

        print(json.decode(response.body));
    }catch(e){
      print(e);

      Fluttertoast.showToast(
          msg: "Something Wrong",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }finally{
      setState(() {    
        isLoadingForm = false;
      });
    }
  }
}