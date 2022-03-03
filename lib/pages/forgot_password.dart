import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../components/spinner.dart';

class ForgotPassword extends StatelessWidget{
  Widget build(BuildContext context){
    return MaterialApp(
      home : Scaffold(      
        backgroundColor : Colors.white,
        body : Padding(
          padding : EdgeInsets.only(left : 20,right : 20),
          child : Column(    
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(                      
                child: 
                 SvgPicture.asset(
                  'images/forgot-password.svg',
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 200,
                )
              ),            
              // ForgotPassword(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children : [                
                  TextButton(
                      onPressed: (){
                        Navigator.of(context).pushReplacementNamed("/");
                      },
                      child : Text("Masuk",
                      style : TextStyle(
                        color: Colors.blueAccent
                      )
                    )
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }
}

// class ForgotPasswordScreen extends StatefulWidget{
//   @override 
//   ForgotPasswordState createState() => ForgotPasswordState();
// }

// class ForgotPasswordState extends State<ForgotPasswordScreen>{  
//   final formKey = GlobalKey<FormState>();

//   String email = '';
//   bool isLoadingForm = false;

//   @override 
//   Widget build(BuildContext context){
//     return Container(
//       child : Form(
//         key: formKey,
//         child: Column(
//           children: [
//             EmailField(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [ForgotPasswordButton()]
//             ),            
//           ],
//         ),
//       )
//     );
//   }


//   Widget EmailField(){
//     return TextFormField(
//       decoration: InputDecoration(
//         labelText: "Email",
//         // hintText: "*Masukan email"
//       ),
//       validator: (value) {        
//         if(value!.isEmpty){
//           return "Email tidak boleh kosong";
//         }

//         return null;
//       },
//     );
//   }


//   Widget ForgotPasswordButton(){
//     return ElevatedButton(
//       style : ElevatedButton.styleFrom(
//           primary: isLoadingForm == true 
//             ? Colors.green[600] 
//             : Colors.green[700],
//           onPrimary: Colors.white,          
//           textStyle: TextStyle(
//             fontSize: 16
//           ),
//           fixedSize : Size(130,40)
//       ),
//       child: Center(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             isLoadingForm == true
//             ? Spinner( icon: Icons.rotate_right )        
//             : Icon( Icons.save),
//             Padding(
//               padding: EdgeInsets.only(left : 5),
//               child : Text("Kirim")
//             )
//           ],
//         )
//       ),
//       onPressed: (){
//         if(formKey.currentState!.validate()){
//             formKey.currentState?.save(); 
//             onSubmit();
//         }
//       },
//     );
//   }

//   void onSubmit() async {
//     if(isLoadingForm) return;

//     setState(() {    
//       isLoadingForm = true;
//     });
    
//     try{    
//         var response = await http.post(
//           Uri.parse(dotenv.env['API_URL']! + "/forgot_password"),
//           headers : {
//              "Content-Type": "application/json"
//           },
//           body : jsonEncode({          
//             "email" : email,        
//           })
//         );    

//         print(json.decode(response.body));
//     }catch(e){
//       print(e);

//       Fluttertoast.showToast(
//           msg: "Something Wrong",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.TOP,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//           fontSize: 16.0,         
//       );
//     }finally{
//       setState(() {    
//         isLoadingForm = false;
//       });
//     }
//   }
// }