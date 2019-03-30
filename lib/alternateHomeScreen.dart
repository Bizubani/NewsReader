import 'package:flutter/material.dart';
import 'overlay.dart';
import 'settings.dart';
import 'accessRSSData.dart';
import 'accessXMLData.dart';
import 'feedContent.dart';
import 'newsArticles.dart';
import 'normalSettingsScreen.dart';
import 'loading_screen.dart';
import 'addNewFeedScreen.dart';
import 'utilityClasses.dart';

class MyAlternateHomeScreen extends StatefulWidget {
  MyAlternateHomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyAlternateHomeScreenState createState() => _MyAlternateHomeScreenState();
}

class _MyAlternateHomeScreenState extends State<MyAlternateHomeScreen> {


  Future<List<FeedContent>> getContent(List<WebRSSAccess> feedData) async {

    List<FeedContent> data = new List();
    for(var item in feedData){

      data.add(await item.makeFeedContent());
    }

    for(var item in data){
      item.shouldHeadlinesBeRead = await Setting.getReadHeadlines(item.newSiteTitle);
    }

    return data;
  }

  NewFeed myTestFeed = new NewFeed();

   navigateToAddFeed(BuildContext context) async{

   var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> AddFeed()));

   print(feedAddresses);
  setState(() {
    determineIfToAddFeed(result);
  });
  print(feedAddresses);
  }

  void determineIfToAddFeed(var result){
    myTestFeed = result;
    // if the feed is valid
    if(myTestFeed.result == 3){
      // and the feed has not yet been added
      if(!feedAddresses.contains(myTestFeed.value)){
        feedAddresses.add(myTestFeed.value); // add the feed and update the shared preferences
        Setting.setWebsites(feedAddresses);
      }
    }else{
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("unable to add $myTestFeed.value")));
    }
  }

  @override
  void initState() {

    super.initState();
  }
  List<String> feedAddresses = [];
  List<WebRSSAccess> feedData = new List();

  WebXMLAccess test = new WebXMLAccess("http://www.looptt.com/rss.xml");
  bool _listLayout;

  Widget _createListView(BuildContext context, AsyncSnapshot snap, List<WebRSSAccess> feedData){
    List<FeedContent> data = snap.data;
    return new ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index){

          String title = data[index].newSiteTitle;
          bool _readHeadlines = data[index].shouldHeadlinesBeRead;
        return Card(
          color: Colors.transparent,
          child: Stack(
              children:<Widget>[
              Center(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Image.network( data[index].imageUrl,fit:BoxFit.fill ,)
              )
              ),
              Column(
              children: <Widget>[
                ListTile(
                  title: Text(title,),
                  subtitle: Text("Click for the news", ),
                  //trailing: Image.network(data[index].imageUrl, height: 75, width: 200,), // Todo remove magic numbers

                  // launch detailed news feed listing when a source is selected.
                  onTap:  ()=> Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) =>
                        NewsArticlesScreen(
                          listing: feedData[index],
                          newSite: title,
                          shouldItRead: _readHeadlines,)))
        ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // check the state of the readHeadlines variable and determine what should be displayed.
                    _readHeadlines ? Text(" Click to disable sound ", style: TextStyle(color: Colors.black26, fontSize: 12.0, ), ):
                    Text(" Click to enable sound ", style: TextStyle(color: Colors.black26, fontSize: 12.0, ), ),
                    GestureDetector(
                      onTap: () {
                        // when a tap is detected, toggle sound on or off as necessary

                        // if sound is enabled, disable
                        if (_readHeadlines == true){
                          data[index].shouldHeadlinesBeRead = false; // set value of class variable directly to expedite updates to the UI
                          Setting.setReadHeadlines(false, title);

                          //else if disabled, enable
                        } else if (_readHeadlines == false){
                          data[index].shouldHeadlinesBeRead = true; // set value of class variable directly to expedite updates to the UI
                          Setting.setReadHeadlines(true, title);
                        }
                        setState(() {});
                        print(_readHeadlines);

                      },
                      child: _readHeadlines ? Icon(
                        Icons.volume_up,
                        color: Colors.red[500],
                      ): Icon(
                        Icons.volume_off,
                        color: Colors.white,
                      ),
                    )

                  ],
                )
              ],
            ),
          ]));
    });
  }

  Widget _createGridView(BuildContext context, AsyncSnapshot snap, List<WebRSSAccess> feedData){
    List<FeedContent> data = snap.data;
    return new GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index){

          String title = data[index].newSiteTitle;
          bool _readHeadlines = data[index].shouldHeadlinesBeRead;
          return Card(
              color: Colors.transparent,

              child: Stack(

                  children:<Widget>[
                    Center(
                        child: Container(

                            alignment: Alignment.bottomCenter,

                            child: Image.network( data[index].imageUrl,fit:BoxFit.fill ,)
                        )
                    ),
                    Column(
                      children: <Widget>[
                        ListTile(

                            title: Text(title,),
                            subtitle: Text("Click for the news", ),
                            //trailing: Image.network(data[index].imageUrl, height: 75, width: 200,), // Todo remove magic numbers

                            // launch detailed news feed listing when a source is selected.
                            onTap:  ()=> Navigator.push(
                                context, MaterialPageRoute(
                                builder: (context) =>
                                    NewsArticlesScreen(
                                      listing: feedData[index],
                                      newSite: title,
                                      shouldItRead: _readHeadlines,)))
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            // check the state of the readHeadlines variable and determine what should be displayed.
                            _readHeadlines ? Text(" Click to disable sound ", style: TextStyle(color: Colors.black26, fontSize: 12.0, ), ):
                            Text(" Click to enable sound ", style: TextStyle(color: Colors.black26, fontSize: 12.0, ), ),
                            GestureDetector(
                              onTap: () {
                                // when a tap is detected, toggle sound on or off as necessary

                                // if sound is enabled, disable
                                if (_readHeadlines == true){
                                  data[index].shouldHeadlinesBeRead = false; // set value of class variable directly to expedite updates to the UI
                                  Setting.setReadHeadlines(false, title);

                                  //else if disabled, enable
                                } else if (_readHeadlines == false){
                                  data[index].shouldHeadlinesBeRead = true; // set value of class variable directly to expedite updates to the UI
                                  Setting.setReadHeadlines(true, title);
                                }
                                setState(() {});
                                print(_readHeadlines);

                              },
                              child: _readHeadlines ? Icon(
                                Icons.volume_up,
                                color: Colors.red[500],
                              ): Icon(
                                Icons.volume_off,
                                color: Colors.white,
                              ),
                            )

                          ],
                        )
                      ],
                    ),
                  ]));
        });
  }

  Future<void> printTest() async{
    var result = await  test.provideXMLContent();
    print(result);
  }


  Future<List<FeedContent>> initialize()async{
      feedAddresses = await Setting.getWebsites();
      if (feedAddresses.isEmpty) {
        print("string null");
      } else {
        for (var url in feedAddresses) {
          feedData.add(WebRSSAccess(url));
        }
        _listLayout = await Setting.getLayoutStyle();
        return getContent(feedData);
      }
  }

  @override
  Widget build(BuildContext context) {

    CustomOverlay myMainOverlay = CustomOverlay(context);
    var height = MediaQuery.of(context).size.height;



    List<String> xmlfeedAddress = ["http://www.looptt.com/rss.xml"]; // Todo Decide what is to be done with this

    // Test function for the loopTT feed link.

    //printTest();

    Widget _buildBottomLayout(Color color, IconData icon, String label ){
      return GestureDetector(
        onTap:() {
          if (label == 'Settings'){
            Navigator.push(context, MaterialPageRoute(builder: (context) => NormalSettings()));
          } else{
            navigateToAddFeed(context);
          }
        },
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
             padding: const EdgeInsets.only(top:24.0),
             child: Text(widget.title, textAlign: TextAlign.center,),
           )
          )
        ],
      )
    );
    Widget bottomLayout = new Container(
      //Todo change magic numbers
      height: height * 0.07,
      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildBottomLayout(Colors.white, Icons.add, 'Add new feed',  ),
          _buildBottomLayout(Colors.white, Icons.settings, 'Settings', ),
        ],
      ),
    );
    Widget mainContent = new Container(
          height: height *0.90,
          child: FutureBuilder(
              future: feedAddresses.isEmpty ? initialize(): getContent(feedData),
              builder: (BuildContext context, AsyncSnapshot snap){
                if(snap.hasData){
                  return _listLayout ? _createListView(context, snap, feedData):_createGridView(context, snap, feedData); // decide what layout to use based on user preferences
                }
                else{
                  return Scaffold(
                      backgroundColor: Colors.white,
                      body: new ColorLoader5());
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


