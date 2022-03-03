import 'package:flutter/foundation.dart';

class ModelUser{
  int? id;
  String? name;
  String? email;
  String? photo;

  ModelUser({
    @required this.id,
    @required this.name,
    @required this.email,
    @required this.photo,
  });  
}