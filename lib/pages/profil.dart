import 'package:flutter/material.dart';
import "../components/sidebar.dart";

class Profil extends StatelessWidget{
  Widget build(BuildContext context){
    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title : Text("Profil"),      
        ),
        drawer: Sidebar(),
        body : Text("Profil")
      )
    );
  }
}