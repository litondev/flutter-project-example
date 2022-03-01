import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    return Drawer(
      child : Column(
        children: <Widget>[
          AppBar(
            title: Text("Menu"),
            automaticallyImplyLeading :  false
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.devices),
            title: Text("Dashabord"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/dashboard");
            }
          ),

         Divider(),

          ListTile(
            leading: Icon(Icons.devices),
            title: Text("Product"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/product");
            }
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.lens),
            title : Text("Profil"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/profil");
            },
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.lens),
            title : Text("Logout"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/logout");
            },
          )
        ],
      )
    );
  }
}