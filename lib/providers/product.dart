import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import "../models/product.dart";

class ProductProvider extends ChangeNotifier{
  List<ModelProduct> items = [];

  Map<String,dynamic> itemsPagination = {    
    "total" : "0",
    "per_page" : "10",
    "current_page" : "1",
    "search" : "",  
    "column" : "id",
    "order" : "desc"
  };

  void setPagination(Map<String,dynamic> pagination){
    itemsPagination = pagination;
  }

  Future<void> onLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final queryString = "?page=" + itemsPagination["current_page"] + 
      "&column=" + itemsPagination["column"] +
      "&order=" + itemsPagination["order"] + 
      "&per_page=" + itemsPagination["per_page"] +
      "&search=" + itemsPagination["search"];

    final url = Uri.parse(dotenv.env['API_URL']! + "/product" + queryString);
    
    final response = await http.get(
      url,
      headers : <String,String> {
        'accept' : 'application/json',
        'Authorization' : token!
      }
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
      final convertData = json.decode(response.body) as Map<String,dynamic>;    

      items = [
        ...convertData["data"].map((item){
          return ModelProduct(
            id: item["id"], 
            title: item["title"], 
            price: double.parse(item["price"]).toInt(), 
            stock: double.parse(item["stock"]).toInt(), 
            description: item["description"]
          );
        }).toList()
      ];      

      itemsPagination = {
        "current_page" : convertData["current_page"].toString(),
        "per_page" : convertData["per_page"].toString(),
        "total" : convertData["total"].toString(),
        "search" : itemsPagination["search"].toString(),
        "column" : itemsPagination["column"].toString(),
        "order" : itemsPagination["order"].toString()
      };

      notifyListeners();
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
  }

  Future<void> onDelete(int? id) async {
  
    final url = Uri.parse(dotenv.env['API_URL']! + "/product/" + id.toString());
    
    final response = await http.delete(
      url,
      headers: <String,String> {
        "accept" : "application/json"
      }
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
      await onLoad();
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
  } 

  Future<void> onUpdate(ModelProduct product) async {
    final url = Uri.parse(dotenv.env['API_URL']! + "/product/" + (product.id as String));

    final response = await http.put(
      url,
      headers: <String,String> {
        "Content-Type": "application/json"
      },
      body :jsonEncode( <String,dynamic> {
        "title" : product.title,
        "stock" : product.stock,
        "price" : product.price,
        "description" : product.description
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
      await onLoad();
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
  }

  Future<void> onAdd(ModelProduct product) async {
    final url = Uri.parse(dotenv.env['API_URL']! + "/product");
    
    final response = await http.post(
      url,
      headers: <String,String> {
        "Content-Type": "application/json"
      },
      body : jsonEncode( <String,dynamic> {
        "title"  : product.title,
        "stock" : product.stock,
        "price" : product.price,
        "description" : product.description
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
      await onLoad();
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
  }

  Future<ModelProduct?> onShow(int id) async {
    final url = Uri.parse(dotenv.env['API_URL']! + "/product/" + (id as String));
    
    final response = await http.get(
      url,
      headers : <String,String> {
        "accept" : "application/json"
      }
    );

    final convert = json.decode(response.body);

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
      return ModelProduct(
        id: convert['id'], 
        title: convert['title'], 
        stock: convert['stock'], 
        price : convert["price"],
        description: convert['description'] == null 
          ? '-' 
          : convert["description"]
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
  }
}