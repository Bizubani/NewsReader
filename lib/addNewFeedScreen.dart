import 'package:flutter/material.dart';
class AddFeed extends StatefulWidget{
  @override
  _AddFeedState createState() => _AddFeedState();
}

class _AddFeedState extends State <AddFeed>{

  final TextEditingController myTextControl = new TextEditingController();

  @override
  void dispose(){
    super.dispose();
    myTextControl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Material(
        color: Colors.white70,
        child: Center(
            child: Card(
              margin: EdgeInsets.all(16.0),
              color: Colors.white,

              child: TextField(
                controller: myTextControl,

                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Website"
                ),

                autofocus: true,
              ),
            )),

      ),
    );
  }
}