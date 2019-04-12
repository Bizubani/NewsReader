import 'package:flutter/material.dart';
import 'package:read_2_me/verifyWebFeed.dart';
import 'utilityClasses.dart';

class AddFeed extends StatefulWidget{
  @override
  _AddFeedState createState() => _AddFeedState();
}

class _AddFeedState extends State <AddFeed>{

  final TextEditingController myTextControl = new TextEditingController();
  NewFeed myTestFeed = new NewFeed();


  @override
  void dispose(){
    super.dispose();
    myTextControl.dispose();
  }

  Future<void> waitForResult() async{
    FeedVerification test = new FeedVerification(myTestFeed.value);
    myTestFeed.result = await test.verifyFeed();
    informAndClose();
  }

  void informAndClose(){
    Navigator.pop(context, myTestFeed);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Material(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/settingbackground.jpg"),
                fit: BoxFit.cover
            )
          ),
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
                        print("before correction $text");
                        if(!text.contains("http")){ // if the text is improperly formatted, fix
                          text = text.trim();
                          text = "http://" + text;
                          print("after correction $text");
                        }
                        myTestFeed.value = text;
                        waitForResult();
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Website"
                      ),

                    ),
                  ),
                ],
              )),
        ),

      ),
    );
  }
}

