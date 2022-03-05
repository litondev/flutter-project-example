import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user.dart';

import "../providers/product.dart";

import '../pages/signin.dart';

import '../components/spinner.dart';

import "../components/sidebar.dart";

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
        appBar: AppBar(
          title : Text("Product Detail"),           
          leading: IconButton(
              onPressed: () => Navigator.of(context).pushNamed("/product"),
              icon: Icon(Icons.arrow_back)
          ),
        ),
        body : ProductAddState(context)
      )
    );
  }
}

class ProductAddState extends StatefulWidget{
  final BuildContext parentContext;

  ProductAddState(this.parentContext);

  @override 
  _ProductAddState createState() => _ProductAddState(parentContext);
}

class _ProductAddState extends State<ProductAddState> {
  final BuildContext parentContext;
  final formKey = GlobalKey<FormState>();

  int? id;
  String? title = "";
  int? stock = 0;
  int? price = 0;
  String? description = "";
  bool isLoading = false;
  bool isLoadingForm = false;
  bool initValue = false;

  _ProductAddState(this.parentContext);

  @override 
  void didChangeDependencies() async {
      if (mounted) {
        if(initValue == false){
          setState(() {
            isLoading = true;
          });        

          id = ModalRoute.of(parentContext)?.settings.arguments as int?;  

          if(id != null){        
            final response = await Provider.of<ProductProvider>(context).onShow(id as int);
            print(response?.title);
            title = response?.title;
            stock = response?.stock;
            price = response?.price;
            description = response?.description;
          }
      
          setState(() {
            isLoading = false;
          });        
        }

        setState(() {
          initValue = true;
        });
    }   

    super.didChangeDependencies();
  }

  @override 
  Widget build(BuildContext context){
    return Container(
      child: isLoading 
        ? Center(
          child : CircularProgressIndicator()
        )
        : Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue : title.toString(),
                  decoration: InputDecoration(
                    labelText: 'Nama Barang'
                  ),
                  validator: (value){
                    if(value!.isEmpty){
                      return "Nama harus diisi";
                    }
                    return null;
                  },
                  onSaved: (value){
                    title = value.toString();
                  },
                ),
                TextFormField(
                  initialValue : stock.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Stock"
                  ),
                  validator: (value){
                    return null;
                  },
                  onSaved: (value){
                    stock = int.parse(value as String);
                  },
                ),
                TextFormField(
                  initialValue : price.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Harga"
                  ),
                  validator: (value){
                    return null;
                  },
                  onSaved: (value){
                    price = int.parse(value as String);
                  },
                ),
                TextFormField(
                  initialValue : description.toString(),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Deskripsi"
                  ),
                  validator: (value){
                    return null;
                  },
                  onSaved: (value){
                    description = value.toString();
                  },
                ),
                 ElevatedButton(
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
                        ? Spinner( 
                            icon: Icons.rotate_right 
                          )        
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
                )
              ],
            ),
          ),
        ),
    );
  }

  void onSubmit() async {
    if(isLoadingForm) return;

    setState(() {    
      isLoadingForm = true;
    });
    
    try{    
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        var response = await http.post(
            Uri.parse(dotenv.env['API_URL']! + "/product"),
            headers : {
              "Content-Type": "application/json",
              "Authorization" : token!
            },
            body : jsonEncode({
              "title" : title,
              "price" : price,
              "stock" : stock,
              "description" : description
            })
          );    

        if(id != null){
          response = await http.put(
            Uri.parse(dotenv.env["API_URL"]! + "/product/" + id.toString()),
            headers : {
              "Content-Type": "application/json",
              "Authorization" : token
            },
            body : jsonEncode({
              "title" : title,
              "price" : price,
              "stock" : stock,
              "description" : description
            })
          );
        }

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
            msg: "Berhasil Simpan Data",
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
    }finally{
      setState(() {    
        isLoadingForm = false;
      });
    }
  }
}