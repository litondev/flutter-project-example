import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import "../components/sidebar.dart";

import '../providers/user.dart';

import './signin.dart';
import "../providers/product.dart";
import "../models/product.dart";

class Dashboard extends StatelessWidget{
  bool? isLogin;

  Dashboard(BuildContext context){
    this.isLogin = Provider.of<UserProvider>(context).getIsLogin();
  } 

  Widget build(BuildContext context){
    if(isLogin != true){
      return Signin(context);
    }

    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title : Text("Dashboard"),      
        ),
        drawer: Sidebar(parentContext: context),
        body : DashboardScreen()
      )
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override 
  _DashboardScreen createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen>{
  ScrollController _scrollControllerVertical = new ScrollController();
  ScrollController _scrollControllerHorizontal = new ScrollController();
  
  List<ModelProduct> itemsVertical = [];
  int total_page_vertical = 0;
  int current_page_vertical = 0;

  bool isErrorFirstVertical = false;
  bool isLoadingFirstVertical = true;

  bool isErrorVertical = false;
  bool isLoadingVertical = false;

  List<ModelProduct> itemsHorizontal = [];
  int total_page_horizontal = 0;
  int current_page_horizontal = 0;

  bool isErrorFirstHorizontal = false;
  bool isLoadingFirstHorizontal = true;

  bool isErrorHorizontal = false;
  bool isLoadingHorizontal = false;

  bool initValue = false;
  
  _scrollVertical(){
    var triggerFetchMoreSize =
        0.9 * _scrollControllerVertical.position.maxScrollExtent;

    if (_scrollControllerVertical.position.pixels >
        triggerFetchMoreSize) {          
          setState(() {
            isLoadingVertical = true;
            current_page_vertical += 1;
          });

          onLoadVertical();
          // print("ajax");
      // call fetch more method here
    }
  }

  _scrollHorizontal(){
    var triggerFetchMoreSize =
        0.9 * _scrollControllerVertical.position.maxScrollExtent;

    if (_scrollControllerVertical.position.pixels >
        triggerFetchMoreSize) {          
          setState(() {
            isLoadingHorizontal = true;
            current_page_horizontal += 1;
          });

          onLoadHorizontal();
          // print("ajax");
      // call fetch more method here
    }
  }

  @override
  void initState() {
    _scrollControllerVertical
          .addListener(_scrollVertical);
    _scrollControllerHorizontal
          .addListener(_scrollHorizontal);
    super.initState();  
  }

  @override
  void dispose() {
      _scrollControllerVertical.removeListener(_scrollVertical);
      _scrollControllerHorizontal.removeListener(_scrollHorizontal);
      super.dispose();
  }

  @override 
  void didChangeDependencies() async {
      if (mounted) {
        if(initValue == false){    
          
          await onIntialLoadVertical();      
          await onIntialLoadHorizontal();
        }

        setState(() {
          initValue = true;
        });
      }   

    super.didChangeDependencies();
  }

  onIntialLoadHorizontal() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(dotenv.env['API_URL']! + "/product");
    
    final response = await http.get(
      url,
      headers : <String,String> {
        'accept' : 'application/json',
        'Authorization' : token!
      }
    );

    final convertData = json.decode(response.body) as Map<String,dynamic>;    

    setState((){
      if(response.statusCode == 200){
        itemsHorizontal = [
          ...convertData["data"].map((item){
            return ModelProduct(
              id: item["id"], 
              title: item["title"], 
              price: double.parse(item["price"]).toInt(), 
              stock: double.parse(item["stock"]).toInt(), 
              description: item['description'] == null 
                ? "" 
                : item["description"]      
            );
          }).toList()
        ];

        total_page_horizontal = convertData["last_page"];
        current_page_horizontal = 1;
        isLoadingFirstHorizontal = false;
      }else{
        print(response.statusCode);

        isLoadingFirstHorizontal = false;
        isErrorFirstHorizontal = true;
      }
    });
  }

  onLoadHorizontal() async {
    if(current_page_horizontal >= total_page_horizontal || isLoadingHorizontal != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final queryString = "?page=" + current_page_horizontal.toString();

    final url = Uri.parse(dotenv.env['API_URL']! + "/product" + queryString);
    
    final response = await http.get(
      url,
      headers : <String,String> {
        'accept' : 'application/json',
        'Authorization' : token!
      }
    );

    setState((){
      if(response.statusCode == 200){
        final convertData = json.decode(response.body) as Map<String,dynamic>;    

        itemsHorizontal = [
          ...itemsHorizontal,
          ...convertData["data"].map((item){
            return ModelProduct(
              id: item["id"], 
              title: item["title"], 
              price: double.parse(item["price"]).toInt(), 
              stock: double.parse(item["stock"]).toInt(), 
              description: item['description'] == null 
                ? "" 
                : item["description"]      
            );
          }).toList()
        ];      

        total_page_horizontal = convertData["last_page"];
        current_page_horizontal = convertData["current_page"];
        isLoadingHorizontal = false;
      }else{
        isErrorHorizontal = true;
      }
    });
  }

  onIntialLoadVertical() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(dotenv.env['API_URL']! + "/product");
    
    final response = await http.get(
      url,
      headers : <String,String> {
        'accept' : 'application/json',
        'Authorization' : token!
      }
    );

    final convertData = json.decode(response.body) as Map<String,dynamic>;    

    setState((){
      if(response.statusCode == 200){
        itemsVertical = [
          ...convertData["data"].map((item){
            return ModelProduct(
              id: item["id"], 
              title: item["title"], 
              price: double.parse(item["price"]).toInt(), 
              stock: double.parse(item["stock"]).toInt(), 
              description: item['description'] == null 
                ? "" 
                : item["description"]      
            );
          }).toList()
        ];

        total_page_vertical = convertData["last_page"];
        current_page_vertical = 1;
        isLoadingFirstVertical = false;
      }else{
        print(response.statusCode);

        isLoadingFirstVertical = false;
        isErrorFirstVertical = true;
      }
    });
  }

  onLoadVertical() async {
    if(current_page_vertical >= total_page_vertical || isLoadingVertical != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final queryString = "?page=" + current_page_vertical.toString();

    print(queryString);

    final url = Uri.parse(dotenv.env['API_URL']! + "/product" + queryString);
    
    final response = await http.get(
      url,
      headers : <String,String> {
        'accept' : 'application/json',
        'Authorization' : token!
      }
    );

    setState((){
      if(response.statusCode == 200){
        final convertData = json.decode(response.body) as Map<String,dynamic>;    

        itemsVertical = [
          ...itemsVertical,
          ...convertData["data"].map((item){
            return ModelProduct(
              id: item["id"], 
              title: item["title"], 
              price: double.parse(item["price"]).toInt(), 
              stock: double.parse(item["stock"]).toInt(), 
              description: item['description'] == null 
                ? "" 
                : item["description"]      
            );
          }).toList()
        ];      

        total_page_vertical = convertData["last_page"];
        current_page_vertical = convertData["current_page"];
        isLoadingVertical = false;
      }else{
        isErrorVertical = true;
      }
    });
  }

  Widget build(BuildContext context){
    Widget generateHorizontal(){
      if(isLoadingFirstHorizontal){
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      if(isErrorFirstHorizontal){
        return Center(
          child: Text("Terjadi Kesalahan"),
        );
      }

      if(itemsHorizontal.length == 0){
        return Center (
          child: Text("Data tidak ditemukan"),
        );
      }

      return ListView.builder(
          // shrinkWrap: true,
          controller: _scrollControllerHorizontal,
          itemCount : itemsHorizontal.length,
          scrollDirection: Axis.horizontal,
          itemBuilder :(ctx,i){
            return Card(
              elevation: 2.5,
              child:  ListTile(
                leading: CircleAvatar(
                  child : Text(itemsHorizontal[i].title as String),
                ),
                title : Text(itemsHorizontal[i].title as String),
                  subtitle: Text(
                  itemsHorizontal[i].description ?? '-',
                    style: TextStyle(
                      color:Colors.grey,
                      fontSize: 12
                      )
                    )
                )
              );
        });
    }


    Widget generateVertical(){
      if(isLoadingFirstVertical){
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      if(isErrorFirstVertical){
        return Center(
          child: Text("Terjadi Kesalahan"),
        );
      }

      if(itemsVertical.length == 0){
        return Center (
          child: Text("Data tidak ditemukan"),
        );
      }

      return ListView.builder(
          controller: _scrollControllerVertical,
          itemCount : itemsVertical.length,
          itemBuilder :(ctx,i){
            return Card(
              elevation: 2.5,
              child:  ListTile(
                leading: CircleAvatar(
                  child : Text(itemsVertical[i].title as String),
                ),
                title : Text(itemsVertical[i].title as String),
                  subtitle: Text(
                  itemsVertical[i].description ?? '-',
                    style: TextStyle(
                      color:Colors.grey,
                      fontSize: 12
                      )
                    )
                )
              );
        });
    }

      return Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          height: 200.0,
          child: ListView.builder(
            itemCount : itemsHorizontal.length,
            // This next line does the trick.
            scrollDirection: Axis.horizontal,
            itemBuilder :(ctx,i){
              return Card(
                elevation: 2.5,
                child:  ListTile(
                  leading: CircleAvatar(
                    child : Text(itemsHorizontal[i].title as String),
                  ),
                  title : Text(itemsHorizontal[i].title as String),
                    subtitle: Text(
                    itemsHorizontal[i].description ?? '-',
                      style: TextStyle(
                        color:Colors.grey,
                        fontSize: 12
                        )
                      )
                  )
                );
              })                    
        );

    // return  Container(
    //   child : Column(
    //   children: <Widget>[
    //   Expanded(
    //    child : ListView.builder(
    //       // shrinkWrap: true,
    //       controller: _scrollControllerHorizontal,
    //       itemCount : itemsHorizontal.length,
    //       scrollDirection: Axis.horizontal,
    //       itemBuilder :(ctx,i){
    //         return Card(
    //           elevation: 2.5,
    //           child:  ListTile(
    //             leading: CircleAvatar(
    //               child : Text(itemsHorizontal[i].title as String),
    //             ),
    //             title : Text(itemsHorizontal[i].title as String),
    //               subtitle: Text(
    //               itemsHorizontal[i].description ?? '-',
    //                 style: TextStyle(
    //                   color:Colors.grey,
    //                   fontSize: 12
    //                   )
    //                 )
    //             )
    //           );
    //     })      
    //  )]));

    // return Column(
    //   children: [
    //     Expanded(
    //       child : SizedBox(
    //         height: 100.0,
    //         child : generateHorizontal()
    //       )
    //     ),
    //     Container( 
    //       // height : MediaQuery.of(context).size.height,    
    //       height : 400,
    //       child : generateVertical()
    //     )
    //   ],
    // );
  }
}