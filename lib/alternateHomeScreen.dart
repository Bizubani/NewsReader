import 'package:flutter/material.dart';
import 'settings.dart';
import 'accessRSSData.dart';
import 'feedContent.dart';
import 'newsArticles.dart';
import 'normalSettingsScreen.dart';
import 'dart:ui';
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

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  NewFeed myTestFeed = new NewFeed();
  GlobalSettings mySettings = new GlobalSettings();

  //navigate to the settings screen and return the changes made by the user.
  navigateToSettingsScreen(BuildContext context) async{
    var result = await Navigator.push(context,
    MaterialPageRoute(builder: (context) => NormalSettings(mySettings)));
    setState(() {
      updateSettings(result);
    });
  }
  // update the saved settings if the user made a change
  void updateSettings(var result){
    if(mySettings.numberOfHeadlines != result.numberOfHeadlines){
      mySettings.numberOfHeadlines = result.numberOfHeadlines;
      Setting.setAmountOfHeadlines(mySettings.numberOfHeadlines);
    }
    if(mySettings.gridLayout !=  result.gridLayout){
      mySettings.gridLayout = result.gridLayout;
      Setting.setLayoutStyle(mySettings.gridLayout);
    }
    if(mySettings.readSpeed != result.readSpeed){
      mySettings.readSpeed = result.readSpeed;
      Setting.setReadSpeed(mySettings.readSpeed);
    }
  }

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
    print(myTestFeed.result);
    // if the feed is valid
    if(myTestFeed.result == 3){
      // and the feed has not yet been added
      if(!feedAddresses.contains(myTestFeed.value)){
        feedAddresses.add(myTestFeed.value); // add the feed and update the shared preferences
        Setting.setDefaultWebsites(feedAddresses);
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(" ${myTestFeed.value} added to feed list")));
      }
    }else{
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("unable to add ${myTestFeed.value} to feed list. Invalid URL")));
    }
  }

  @override
  void initState() {

    super.initState();
  }
  List<String> feedAddresses = [];
  List<WebRSSAccess> feedData = new List();


  //use the user's feed list to generate a list view layout
  Widget _createListView(BuildContext context, AsyncSnapshot snap, List<WebRSSAccess> feedData){
    List<FeedContent> data = snap.data;
    return new ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index){

          String title = data[index].newSiteTitle;
          bool _readHeadlines = data[index].shouldHeadlinesBeRead;
        return Card(
          color: Colors.black26,
          child: Stack(
              children:<Widget>[
              Center(
              child: Container(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: data[index].imageUrl == null? Icon(Icons.aspect_ratio): Image.network( data[index].imageUrl,height: 60.0, width: 80.0 ,),
                ) // if there is no associated  image,
              )
              ),
              Column(
              children: <Widget>[
                ListTile(
                  title: Text(title, style: TextStyle(color: Colors.white,  )),
                  subtitle: Text("Click tile for the news", style: TextStyle(color: Colors.white, fontSize: 12.0, ) ),


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
                    _readHeadlines ? Text("Press green button toggle sound ", style: TextStyle(color: Colors.white, fontSize: 12.0, ), ):
                    Text(" Press red button to toggle sound ", style: TextStyle(color: Colors.white, fontSize: 12.0, ), ),
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
                      child: _readHeadlines ? Image(
                        image: AssetImage("assets/read.png"),
                        height: 20.0,
                        width: 20.0,
                        //color: Colors.red,
                      ): Image(
                        image: AssetImage("assets/dontread.png"),
                        height: 20.0,
                        width: 20.0,
                        //color: Colors.white,
                      ),
                    )

                  ],
                )
              ],
            ),
          ]));
    });
  }

  //use the user's feed list to generate a grid view layout
  Widget _createGridView(BuildContext context, AsyncSnapshot snap, List<WebRSSAccess> feedData){
    List<FeedContent> data = snap.data;
    return new GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index){

          String title = data[index].newSiteTitle;
          bool _readHeadlines = data[index].shouldHeadlinesBeRead;
          return Card(
              color: Colors.black26,
              child: Stack(
                  children:<Widget>[
                    Center(
                        child: Container(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: data[index].imageUrl == null? Icon(Icons.aspect_ratio): Image.network( data[index].imageUrl,height: 60.0, width: 80.0 ,),
                            ) // if there i
                        )
                    ),
                    Column(
                      children: <Widget>[
                        ListTile(
                            title: Text(title, style: TextStyle(color: Colors.white),),
                            subtitle: Text("Click for the news", style: TextStyle(color: Colors.white), ),

                            // launch detailed news feed listing when a source is selected.
                            onTap:  ()=> Navigator.push(
                                context, MaterialPageRoute(
                                builder: (context) =>
                                    NewsArticlesScreen(
                                      listing: feedData[index],
                                      newSite: title,
                                      shouldItRead: _readHeadlines,)))
                        ),
                       Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            // check the state of the readHeadlines variable and determine what should be displayed.
                            _readHeadlines ? Text(" Press green button to toggle sound ", style: TextStyle(color: Colors.white, fontSize: 12.0, ), ):
                            Text(" Press red button to toggle sound ", style: TextStyle(color: Colors.white, fontSize: 12.0, ), ),
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
                              child: _readHeadlines ? Image(
                                image: AssetImage("assets/read.png"),
                                height: 20.0,
                                width: 20.0,
                                //color: Colors.red,
                              ): Image(
                                image: AssetImage("assets/dontread.png"),
                                height: 20.0,
                                width: 20.0,
                                //color: Colors.white,
                              ),
                            )

                          ],
                        )
                      ],
                    ),
                  ]));
        });
  }


  Future<List<FeedContent>> initialize() async{
      print("Attempting to get feed addresses");
      feedAddresses = await Setting.getDefaultWebsites();
      print(feedAddresses.length);
      if (feedAddresses.isEmpty) {
        print("string null");
      } else {
        for (var url in feedAddresses) {
          feedData.add(WebRSSAccess(url));
          print(url);
        }
        mySettings.gridLayout = await Setting.getLayoutStyle(); // get the settings
        mySettings.numberOfHeadlines = await Setting.getAmountOfHeadlines();
        mySettings.readSpeed = await Setting.getReadSpeed();
        return getContent(feedData);
      }
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;


    // Test function for the loopTT feed link.

    //printTest();

    Widget _buildBottomLayout(Color color, IconData icon, String label ){
      return GestureDetector(
        onTap:() {
          if (label == 'Settings'){
            navigateToSettingsScreen(context);
          } else{
            navigateToAddFeed(context);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
                icon,
                color: color,
                size: 30.0,
            ),
            Container(
              margin: const EdgeInsets.only(top: 1.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.0,
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



    Widget loadingScreen = Container(
          child: FutureBuilder(
              future: feedAddresses.isEmpty ? initialize(): getContent(feedData),
              builder: (BuildContext context, AsyncSnapshot snap){
                if(snap.hasData){
                  return Column
                    (children: <Widget>[
                  topTitle,
                  new Container(
                      height: height *0.90,
                      child: mySettings.gridLayout ? _createListView(context, snap, feedData):_createGridView(context, snap, feedData) // decide what layout to use based on user preferences
                  ),
                  bottomLayout]); // decide what layout to use based on user preferences
                }
                else{
                  return Scaffold(
                      body: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/loadingbackground.jpg",),
                          fit: BoxFit.cover,
                        ),

                      ),
                  )
                  );
                }
              }),
    );



    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
          onRefresh: () => Future.delayed(Duration(seconds: 1)),
        child: Container(
          decoration: BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage("assets/mainback.jpg"),
              fit: BoxFit.cover
            )
          ),
          child: new BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: loadingScreen,
          )
        ),
      )
    );
  }
}


