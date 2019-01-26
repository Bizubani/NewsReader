import 'package:flutter/material.dart';
import 'accessWebData.dart';
import 'feedContent.dart';
import 'newsArticles.dart';

class MyAlternateHomeScreen extends StatefulWidget {
  MyAlternateHomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyAlternateHomeScreenState createState() => _MyAlternateHomeScreenState();
}

class _MyAlternateHomeScreenState extends State<MyAlternateHomeScreen> {
  Future<List<FeedContent>> getContent(List<WebAccess> feedData) async {

    List<FeedContent> data = new List();
    for(var item in feedData){

      data.add(await item.makeFeedContent());
    }
    return data;
  }


  Widget _createListView(BuildContext context, AsyncSnapshot snap, List<WebAccess> feedData){
    List<FeedContent> data = snap.data;

    return new ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index){
        return Card(
          child: ListTile(
            title: Text(data[index].newSiteTitle, ),
            subtitle: Text("Click for the news", ),
            trailing: Image.network(data[index].imageUrl),
            onTap: ()=> Navigator.push(
                context, MaterialPageRoute(
                builder: (context) =>
                  NewsArticles(
                    listing: feedData[index],
                    newSite: data[index].newSiteTitle,)))
        ));
    });
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;

    List<String> feedAddresses = [
      'http://feeds.reuters.com/Reuters/worldNews',
      "http://feeds.bbci.co.uk/news/rss.xml",
      "https://www.buzzfeed.com/world.xml",
      "http://www.spiegel.de/international/index.rss",
      "http://www.espn.com/espn/rss/news",
      "https://www.techradar.com/rss",

    ];

    List<String> xmlfeedAddress = ["http://www.looptt.com/rss.xml"];

    List<WebAccess> feedData = new List();

    for (var url in feedAddresses) {
      feedData.add(WebAccess(url));
    }

    Widget _buildBottomLayout(Color color, IconData icon, String label){
      return GestureDetector(
        onTap: ()=> Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
         new Scaffold())
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: color),
            Container(
              margin: const EdgeInsets.only(top: 1.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.0,
                  color: color,
                ),
              ),
            ),
          ],

        ),
      );
    }

    Widget topTitle = new Container(
      height: height * 0.03,
      child: new Row(
        children: <Widget>[
          Expanded(
           child: Padding(
             padding: const EdgeInsets.only(top:32.0),
             child: Text(widget.title, textAlign: TextAlign.center,),
           )
          )
        ],
      )
    );
    Widget bottomLayout = new Container(
      height: height * 0.07,
      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildBottomLayout( Colors.white,  Icons.list,  'User Menu' ),
          _buildBottomLayout(Colors.white, Icons.add, 'Add new feed'),
          _buildBottomLayout(Colors.white, Icons.settings, 'Settings')

        ],
      ),
    );
    Widget mainContent = new Container(
          height: height *0.90,
          child: FutureBuilder(
              future: getContent(feedData),
              builder: (BuildContext context, AsyncSnapshot snap){
                if(snap.hasData){
                  return _createListView(context, snap, feedData);
                }
                else{
                  return Container(
                      child: Center(
                          child: Text("Loading... Please wait")
                      ));
                }
              }),
        

    );

    return Scaffold(
      body: Container(
        color: Colors.grey,
        child: Column(
          children: <Widget>[
            topTitle,
            mainContent,
            bottomLayout,
          ],
        )
      ),
    );
  }
}
