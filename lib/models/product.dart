import 'package:flutter/material.dart';

class ModelProduct {
 int? id;
 String? title;
 int? price;
 int? stock;
 String? description;

 ModelProduct({
   @required this.id,
   @required this.title,
   @required this.price,
   @required this.stock,
   @required this.description
 });
}