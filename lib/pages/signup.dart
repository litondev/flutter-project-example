import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../components/spinner.dart';

class Signup extends StatelessWidget{
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
                  'images/signup.svg',
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 200,
                )
              ),            
              SignupScreen(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children : [                
                  TextButton(
                      onPressed: (){
                        Navigator.pushNamed(context,"/signin");
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

class SignupScreen extends StatefulWidget{
  @override 
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen>{  
  final formKey = GlobalKey<FormState>();

  String name = '';
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
            NameField(),
            EmailField(),
            PasswordField(),          
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [SignupButton()]
            ),            
          ],
        ),
      )
    );
  }

  Widget NameField(){
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Nama",
        // hintText: "*Masukan email"
      ),
      validator: (value) {        
        if(value!.isEmpty){
          return "Nama tidak boleh kosong";
        }

        return null;
      },
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

  Widget SignupButton(){
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
          Uri.parse(dotenv.env['API_URL']! + "/signup"),
          headers : {
             "Content-Type": "application/json"
          },
          body : jsonEncode({
            "name" : name,
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