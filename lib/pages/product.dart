import 'package:flutter/material.dart';
import 'package:project/models/product.dart';
import 'package:provider/provider.dart';

import "../components/sidebar.dart";

import '../providers/user.dart';
import "../providers/product.dart";

import './signin.dart';

class Product extends StatelessWidget{
  bool? isLogin;

  Product(BuildContext context){
    this.isLogin = Provider.of<UserProvider>(context).getIsLogin();
  } 

  Widget build(BuildContext context){
    if(isLogin != true){
      return Signin(context);
    }

    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title : Text("Product"),   
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed("/product/add"),
              icon: Icon(Icons.add)
            ),
            IconButton(
              onPressed: () => print("Sorting and Search"),
              icon : Icon(Icons.search)
            )
          ],   
        ),
        drawer: Sidebar(parentContext: context),
        // body: Text("Product"),
        body : ProductScreeen(context)
      )
    );
  }
}

class ProductScreeen extends StatefulWidget{
  final BuildContext parentContext;

  ProductScreeen(this.parentContext);

  @override 
  ProductScreenState createState() => ProductScreenState(parentContext);
}

class ProductScreenState extends State<ProductScreeen>{
  final BuildContext parentContext;

  ProductScreenState(this.parentContext);

  final isLoading = false;

  Widget build(BuildContext context){
    return FutureBuilder(
      future: Provider.of<ProductProvider>(context,listen : false).onLoad(),
      builder: (ctx,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if(snapshot.error != null){
          return Center(
            child: Text("Terjadi Kesalahan"),
          );
        }   

        return Padding(
          padding: EdgeInsets.all(10),
          child: RefreshIndicator(
            onRefresh: () => Provider.of<ProductProvider>(context,listen : false).onLoad(),
            child: Consumer<ProductProvider>(
              builder: (context,product,child) => product.items.length == 0 
              ? Center(child: Text("Data tidak ditemukan"),)
              : ListView.builder(
                itemCount : product.items.length,
                itemBuilder :(ctx,i) => Dismissible(
                  key : ValueKey(product.items[i].id),

                  background: Container(
                      color : Theme.of(context).errorColor,
                      child: Icon(
                        Icons.delete,
                        size : 40,
                        color: Colors.white,
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 4
                      ),
                  ),

                  direction:  DismissDirection.endToStart,

                  confirmDismiss: (dismiss){
                    return showDialog(
                      context: context, 
                      builder: (ctx) => AlertDialog(
                        title : Text("Kamu Yakin"),
                        content: Text("Kamu Mengahpus Data Ini"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: (){
                              Navigator.of(ctx).pop(false);
                            }, 
                            child: Text(
                              "Tidak",
                              style : TextStyle(
                                color : Colors.grey,
                                fontWeight : FontWeight.bold
                              )
                            )
                          ),  
                          TextButton(
                            onPressed: (){
                                Provider.of<ProductProvider>(ctx,listen: false)
                                .onDelete(product.items[i].id)
                                .then((_) => {
                                  Navigator.of(ctx).pop(false)
                                });
                            }, 
                            child: Text(
                              "Iya",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              )
                            )
                          )
                        ],
                      )
                    );
                  },

                  child: Card(
                    elevation: 2.5,
                    child:  ListTile(
                      leading: CircleAvatar(
                        child : Text(product.items[i].title as String),
                      ),
                      title : Text(product.items[i].title as String),
                        subtitle: Text(
                        product.items[i].description ?? '-',
                        style: TextStyle(
                          color:Colors.grey,
                          fontSize: 12
                        ),
                      ),
                      trailing: Container( 
                        width: 100,
                        child : Row(
                          children: <Widget>[
                            // EDIT BUTTON
                            IconButton(
                              onPressed: () => {
                                Navigator.of(parentContext).pushNamed("/product/add",arguments: product.items[i].id)
                              },
                              icon: Icon(Icons.edit)
                            ),

                            // DELETE BUTTON
                            IconButton(
                              onPressed: (){
                                showDialog(
                                  context: context, 
                                  builder: (ctx) => AlertDialog(
                                    title : Text("Kamu Yakin?"),
                                    content: Text("Proses ini akan menghapus data"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: (){
                                          Navigator.of(ctx).pop(false);
                                        }, 
                                        child: Text(
                                          "Batal",
                                          style : TextStyle(
                                            color : Colors.grey,
                                            fontWeight: FontWeight.bold
                                          )
                                        )
                                      ),  

                                      TextButton(
                                        onPressed: () => {
                                           Provider.of<ProductProvider>(ctx,listen: false)
                                            .onDelete(product.items[i].id)
                                            .then((_) {
                                              Navigator.of(ctx).pop(false);
                                            })
                                        },
                                        child: Text(
                                          "Lanjutkan",
                                          style:  TextStyle( 
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold
                                          ),
                                        )
                                      )
                                    ],
                                  )                        
                                );
                              }, 
                              icon: Icon(Icons.delete)
                            )
                          ],
                        )
                      ), 
                    ),
                  )  
                )
              ),
            ),
          ),
        );  
      }
    );
  }
}