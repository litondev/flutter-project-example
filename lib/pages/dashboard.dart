import 'package:flutter/material.dart';
import "../components/sidebar.dart";

class Dashboard extends StatelessWidget{

  Widget build(BuildContext context){

    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title : Text("Dashboard"),      
        ),
        drawer: Sidebar(),
        body : Text("Dashboard")        
      )
    );
  }
}