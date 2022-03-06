import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import "../components/sidebar.dart";

import '../providers/user.dart';

import './signin.dart';

class Profil extends StatelessWidget{
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey();
  bool? isLogin;
  
  Profil(BuildContext context){
    this.isLogin = Provider.of<UserProvider>(context).getIsLogin();
  } 

  backgroundContainer(context){
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color : Colors.blueAccent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(200),
          bottomRight: Radius.circular(200)
        )
      ),
      child: Padding(
        padding : EdgeInsets.only(top : 60,left : 10,right : 30),
        child: Row( 
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children : [
            TextButton(
              child :Icon(
                Icons.align_horizontal_left,size : 30,
                color: Colors.white
              ),
              onPressed: (){
               _keyScaffold.currentState!.openDrawer();
              }
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Image.network("http://192.168.8.215:8000/users/"
                    + (Provider.of<UserProvider>(context).getUser()!.photo ?? "default.png")),
                ),
                Text(
                   Provider.of<UserProvider>(context).getUser()!.name ?? '-',
                    style : TextStyle(
                    fontSize: 15,
                    color: Colors.white
                  )
                )
              ]
            ),
          
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context){
    if(isLogin != true){
      return Signin(context);
    }

    return MaterialApp(
      home : Scaffold(
        key : _keyScaffold,
        drawer: Sidebar(parentContext: context),
        body :  SingleChildScrollView(
          child: Column(
          children: [
          Stack(
              children: [
                Container(height: MediaQuery.of(context).size.height + 180), // Max stack size
                backgroundContainer(context),
                Positioned(
                  top : 180,              
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox( 
                  height: MediaQuery.of(context).size.height,                   
                    child: Column(
                      children: [
                        ProfilUpdatePhoto(),
                        ProfilUpdateData(),
                        ProfilUpdatePassword()                                                   
                    ]),
                  )
                )
              ],
            ),  ])
      )
    ));
  }
}


class ProfilUpdatePhoto extends StatefulWidget{
  @override 
  _ProfilUpdatePhoto createState() =>  _ProfilUpdatePhoto();
}

class _ProfilUpdatePhoto extends State<ProfilUpdatePhoto>{
  final ImagePicker _picker = ImagePicker();
  File? uploadimage; //variable for choosed file

  Future<void> chooseImage() async {        
        var picker = await _picker.pickImage(
          source: ImageSource.gallery
        );
        //set source: ImageSource.camera to get image from camera
        setState(() {
            uploadimage =  File(picker!.path);
        });
  }

 Future<void> uploadImage() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = await http.MultipartRequest(
        'POST', 
        Uri.parse(dotenv.env['API_URL']! + "/profil/photo")
      );
    
      request.headers['Authorization'] = token!;
      
      request.files.add(
        await http.MultipartFile.fromPath(
        'photo',
        uploadimage!.path
      ));

      var response = await request.send();

      if(response.statusCode == 200){
        final res = await http.Response.fromStream(response);
        var jsondata = json.decode(res.body); //decode json data         
        print("Upload successful");         
      }else{
        print("Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
    }catch(e){
       print(e);
       //there is error during converting file image to base64 encoding. 
    }
  }

  Widget build(BuildContext context){
      return Container(
        height: 300,
        width: MediaQuery.of(context).size.width  * 0.9,
        child : Card(
          elevation: 0.5,
          child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, //content alignment to center 
                    children: <Widget>[
                        Container(  //show image here after choosing image
                            child:
                               Container(   //elese show image here                               
                                  child:  uploadimage == null ? Text("Asd") : SizedBox( 
                                     height:150,
                                     child:Image.file(uploadimage!) //load image from file
                                  )
                               )
                        ),

                        Container( 
                            //show upload button after choosing image
                          child:uploadimage == null? 
                               Container(): //if uploadimage is null then show empty container
                               Container(   //elese show uplaod button
                                  child:RaisedButton.icon(
                                    onPressed: (){
                                        uploadImage();
                                        //start uploading image
                                    }, 
                                    icon: Icon(Icons.file_upload), 
                                    label: Text("UPLOAD IMAGE"),
                                    color: Colors.deepOrangeAccent,
                                    colorBrightness: Brightness.dark,
                                    //set brghtness to dark, because deepOrangeAccent is darker coler
                                    //so that its text color is light
                                  )
                               ) 
                        ),

                        Container(
                          child: RaisedButton.icon(
                            onPressed: (){
                                chooseImage(); // call choose image function
                            },
                            icon:Icon(Icons.folder_open),
                            label: Text("CHOOSE IMAGE"),
                            color: Colors.deepOrangeAccent,
                            colorBrightness: Brightness.dark,
                          ),
                        )
              ],),                          
        )
    );
  }
}

class ProfilUpdateData extends StatefulWidget{
  @override 
  _ProfilUpdateData createState() => _ProfilUpdateData();
}

class _ProfilUpdateData extends State<ProfilUpdateData>{
  String name = '';
  String email = '';
  String password = '';
  final formKey = GlobalKey<FormState>();

  onSubmit() async{    
    try{    
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        var response = await http.post(
          Uri.parse(dotenv.env['API_URL']! + "/profil/data"),
          headers : {
             "Content-Type": "application/json",
             "Authorization" : token!
          },
          body : jsonEncode({
            "name" : name,
            "email" : email,
            "password" : password
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
          Fluttertoast.showToast(
            msg: "Berhasil",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,         
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
    }
  }

  Widget build(BuildContext context){
    return Container(
        height: 260,
        width: MediaQuery.of(context).size.width  * 0.9,
        child : Card(
          elevation: 1.5,
          child: Form(            
            key: formKey,            
            child: Padding(padding: EdgeInsets.all(10),
            child : Column(
              children: [
                TextFormField(
                  initialValue: Provider.of<UserProvider>(context).getUser()!.name ?? "",
                  decoration: InputDecoration(
                    labelText: "Nama",
                    // hintText: "*Masukan password"
                  ),
                  validator: (value){                
                    return null;
                  },
                  onSaved: (String? value) { 
                    name = value.toString();
                  },
                ),
                TextFormField(
                  initialValue: Provider.of<UserProvider>(context).getUser()!.email ?? "",
                  decoration: InputDecoration(
                    labelText: "Email",
                    // hintText: "*Masukan password"
                  ),
                  validator: (value){                    
                    return null;
                  },
                  onSaved: (String? value) { 
                    email = value.toString();
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    // hintText: "*Masukan password"
                  ),
                  validator: (value){                    
                    return null;
                  },
                  onSaved: (String? value) { 
                    password = value.toString();
                  },
                ),

                ElevatedButton(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [            
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
                )
              ]
            )
        )
      )
    ));
  }
}

class ProfilUpdatePassword extends StatefulWidget{
  @override 
  _ProfilUpdatePassword createState() => _ProfilUpdatePassword();
}

class _ProfilUpdatePassword extends State<ProfilUpdatePassword>{
  String? password;
  String? password_confirmation;
  final formKey = GlobalKey<FormState>();

  onSubmit() async{    
    try{    
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        var response = await http.post(
          Uri.parse(dotenv.env['API_URL']! + "/profil/password"),
          headers : {
             "Content-Type": "application/json",
             "Authorization" : token!
          },
          body : jsonEncode({
            "old_password" : password_confirmation,
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
          Fluttertoast.showToast(
            msg: "Berhasil",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,         
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
    }
  }

  Widget build(BuildContext context){
    return Container(
        height: 190,
        width: MediaQuery.of(context).size.width  * 0.9,
        child : Card(
          elevation: 1.5,
          child: Form(
            key: formKey,
            child: Padding(padding: EdgeInsets.all(10),
              child : Column(
              children: [
                TextFormField(
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
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password Konfirmasi",
                    // hintText: "*Masukan password"
                  ),
                  validator: (value){
                    if(value!.isEmpty){
                      return "Password Konfirmasi tidak boleh kosong";
                    }

                    if(value.length <= 7){
                      return "Password Konfirmasi tidak boleh kurang dari 8";
                    }

                    return null;
                  },
                  onSaved: (String? value) { 
                    password_confirmation = value.toString();
                  },
                ),

                ElevatedButton(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [            
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
                )
              ]
            )
        ))
      )
    );
  }
}