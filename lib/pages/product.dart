import 'package:flutter/material.dart';
import "../components/sidebar.dart";

class Product extends StatelessWidget{
  Widget build(BuildContext context){
    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title : Text("Product"),      
        ),
        drawer: Sidebar(),
        body : Text("Product")
      )
    );
  }
}