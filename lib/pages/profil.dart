import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "../components/sidebar.dart";

import '../providers/user.dart';

import './signin.dart';

class Profil extends StatelessWidget{
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey(); // Create a key
  var _itemsView = GlobalKey();
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
              child :Icon(Icons.align_horizontal_left,size : 30,color: Colors.white),
              onPressed: (){
               _keyScaffold.currentState!.openDrawer();
              }
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Data",
                  style: TextStyle( 
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold   
                  ),
                ),
                Text(
                  "Toni",
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
        // appBar: AppBar(
        //   title : Text("Profil"),      
        // ),
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
                        Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width  * 0.6,
                          child : Card(
                            elevation: 0.5,
                            child: Text("Upload"),  
                          )
                        ),
                        Container(
                          height: 400,
                          width: MediaQuery.of(context).size.width  * 0.7,
                          child : Card(
                            elevation: 1.5,
                            child: Text("Change Data Form"),  
                          )
                        ),      
                        Container(
                          height: 400,
                          width: MediaQuery.of(context).size.width  * 0.7,
                          child : Card(
                            elevation: 1.5,
                            child: Text("Change Data Password"),  
                          )
                        ),                                  
                    ]),
                  )
                )
              ],
            ),  ])
      )
    ));
  }
}