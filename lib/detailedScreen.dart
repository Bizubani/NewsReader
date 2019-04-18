import 'package:flutter/material.dart';
import 'feedContent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

class DetailedScreen extends StatelessWidget {

  DetailedScreen(this.thisItem);
  final FeedItems thisItem;
  final double topSection = 0.05;
  final double mainContent = 0.85;
  final double bottomSection = 0.10;

  Future<void> _launchURL(String url, BuildContext context) async{
    {
      try {
        if (await canLaunch(url)) {
          await launch(url);
        }
      }
      catch (e) {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("Unable to launch URL")));
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    final double height = MediaQuery.of(context).size.height *.96;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/mainback.jpg"),
            fit: BoxFit.cover
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: height * topSection,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.navigate_before, size: 35.0, color: Colors.white,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Share.share(thisItem.linkToTheStory),
                        child: Icon(Icons.share,
                          size: 35.0,
                          color: Colors.white,)),
                  )
                ],
              ),
            ),
            Divider(),
            SizedBox(
              height: height * mainContent,
              child: Container(
                color: Colors.black38,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(thisItem.headline, style: TextStyle(fontSize: 35.0)),
                    ),
                    Image(
                      image: NetworkImage(thisItem.itemImageURL),
                    ),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                          child: Text(thisItem.description)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * bottomSection,
              child: Center(
                child: RaisedButton(
                  child: Text("Visit website"),
                  onPressed: () => _launchURL(thisItem.linkToTheStory, context),
                ),
              ),
            )
          ],

        ),
      ),
    );
  }
}
