
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(
         child: Column(
             children: [
               Image(image: AssetImage("assets/open_cloud.jpeg")),
               Image(image: AssetImage("assets/camera_app.jpg")),
               SizedBox(height: 100,),
               CircularProgressIndicator(),
             ]
         ),
       ),
    );
  }
}
