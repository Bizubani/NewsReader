import 'package:flutter/material.dart';
import 'package:read_2_me/verifyWebFeed.dart';
class AddFeed extends StatefulWidget{
  @override
  _AddFeedState createState() => _AddFeedState();
}

class _AddFeedState extends State <AddFeed>{

  final TextEditingController myTextControl = new TextEditingController();
  String value = '';


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
        color: Colors.red,
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Copy and paste your feed into the box. '),
                Card(
                  margin: EdgeInsets.all(16.0),
                  color: Colors.white,

                  child: TextField(
                    controller: myTextControl,
                    onSubmitted: (text) {
                      value = text;
                      FeedVerification test = new FeedVerification(value);
                      var result = test.verifyFeed();
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Website"
                    ),

                    autofocus: true,
                  ),
                ),
              ],
            )),

      ),
    );
  }
}