import 'package:flutter/material.dart';
import 'settings.dart';
import 'accessRSSData.dart';
import 'feedContent.dart';
import 'newsArticles.dart';
import 'normalSettingsScreen.dart';
import 'dart:ui';
import 'package:flutter_tts/flutter_tts.dart';
import 'addNewFeedScreen.dart';
import 'utilityClasses.dart';
import 'selectFeedScreen.dart';

class MyAlternateHomeScreen extends StatefulWidget {
  MyAlternateHomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyAlternateHomeScreenState createState() => _MyAlternateHomeScreenState();
}

class _MyAlternateHomeScreenState extends State<MyAlternateHomeScreen> {
  //class members
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  NewFeed _myTestFeed = new NewFeed();
  GlobalSettings _mySettings = new GlobalSettings();
  final double _bottomLayoutHeight = 0.07;
  final double _mainContentHeight = 0.85;
  final double _topLayoutHeight = 0.08;
  bool _readyForDeletion = false;
  String _loadingMessage = "";
  FlutterTts adviseUser = new FlutterTts();
  List<String> _feedAddresses = [];
  List<WebRSSAccess> _feedData = [];
  List<FeedContent> _data = [];
  List<String> _newFeedList = [];
  List<List<String>> _deletionList = [];
  List<bool> _markedForDeletion = [];

  Future<List<FeedContent>> _getContent(List<WebRSSAccess> feedData) async
  {
    int count = 0;
    for (var item in feedData) {
      FeedContent nextItem = await item.makeFeedContent();
      if (!_data
          .any((content) => content.newSiteTitle == nextItem.newSiteTitle)) {
        _data.add(nextItem);
      }

      setState(() {
        _loadingMessage =
            "Getting your news from " + _data[count++].newSiteTitle;
      });
      print(
          "FeedAddresses size = ${_feedAddresses.length} and Data's size = ${_data.length}");
      print(_loadingMessage);
    }
    for (var item in _data) {
      item.shouldHeadlinesBeRead =
          await Setting.getReadHeadlines(item.newSiteTitle);
    }
    _loadingMessage = "";
    return _data;
  }

  void _addNewFeeds(List<String> newFeeds) async {
    List<WebRSSAccess> _newFeedData = [];
    for (var newFeed in newFeeds) {
      _newFeedData.add(WebRSSAccess(newFeed));
    }
    _feedData.addAll(_newFeedData);
    _newFeedList = [];
    _initializeDeletionCheckList();
    _getContent(_newFeedData);
  }

  void _initializeDeletionCheckList()
  {
    _markedForDeletion = new List.filled(_feedAddresses.length, false);
  }

  void _speak(String message)
  {
    adviseUser.speak(message);
  }

  void _updateUserFeedList(List<String> updatedList) {
    print("FeedAddresses before additon = $_feedAddresses");
    if (_feedAddresses.isEmpty) {
      for (String address in updatedList) {
        _feedAddresses.add(address);
      }
      _initialize();
    } else {
      for (String feed in updatedList) {
        if (!_feedAddresses.contains(feed)) {
          _newFeedList.add(feed);
          _feedAddresses.add(feed);
        }
      }
      _addNewFeeds(_newFeedList);
    }
    setState(() {});

    print(
        "Length of feedA = ${_feedAddresses.length} and length of _data = ${_data.length}");
    print("FeedAddresses after work = $_feedAddresses");
    Setting.setUserWebsites(_feedAddresses);
  }

  // when the user's feed list is empty, allow them to navigate to the feed select screen
  _navigateToSelectFeedScreen(BuildContext context) async {
    var result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SelectScreen()));
    try {
      _updateUserFeedList(result);
    } catch (e) {
      print("Encounted error, $e");
    }
  }

  //navigate to the settings screen and return the changes made by the user.
  _navigateToSettingsScreen(BuildContext context) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NormalSettings(_mySettings)));
    setState(() {
      _updateSettings(result);
    });
  }

  // update the saved settings if the user made a change
  void _updateSettings(var result) {
    if (_mySettings.numberOfHeadlines != result.numberOfHeadlines) {
      _mySettings.numberOfHeadlines = result.numberOfHeadlines;
      Setting.setAmountOfHeadlines(_mySettings.numberOfHeadlines);
    }
    if (_mySettings.gridLayout != result.gridLayout) {
      _mySettings.gridLayout = result.gridLayout;
      Setting.setLayoutStyle(_mySettings.gridLayout);
    }
    if (_mySettings.readSpeed != result.readSpeed) {
      _mySettings.readSpeed = result.readSpeed;
      Setting.setReadSpeed(_mySettings.readSpeed);
    }
  }

  _navigateToAddFeed(BuildContext context) async {
    var result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddFeed()));

    print(_feedAddresses);
    setState(() {
      _determineIfToAddFeed(result);
    });
    print(_feedAddresses);
  }

  void _determineIfToAddFeed(var result) {
    _myTestFeed = result;
    try {
      print("result ${_myTestFeed.result}");
      // if the feed is valid
      if (_myTestFeed.result == 3) {
        if (_feedAddresses.isEmpty) {
          _feedAddresses.add(_myTestFeed.value);
          _initialize();
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(" ${_myTestFeed.value} added to feed list")));
        }
        // and the feed has not yet been added
        else if (!_feedAddresses.contains(_myTestFeed.value)) {
          _feedAddresses.add(_myTestFeed
              .value); // add the feed and update the shared preferences
          _newFeedList.add(_myTestFeed.value);
          _addNewFeeds(_newFeedList);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(" ${_myTestFeed.value} added to feed list")));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
                "unable to add ${_myTestFeed.value} to feed list. Invalid URL")));
      }
    } catch (e) {
      print("Null value entered, we encountered exception $e");
    }
    Setting.setUserWebsites(_feedAddresses);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _checkDeleteStatus(int index, String title) {
    List<String> _deletePair = [];
    try {
      _deletePair.add(_feedAddresses[index]);
      print(
          "in _checkDelete try block and _feed[index] = ${_feedAddresses[index]}");
      _deletePair.add(title);
    } catch (e) {}

    if (_readyForDeletion) {
      return GestureDetector(
        child: _markedForDeletion[index]
            ? Icon(Icons.delete_forever)
            : Icon(Icons.delete_outline),
        onTap: () {
          print(
              "pair for deletion is address = ${_deletePair[0]} and title = $title");
          if (_markedForDeletion[index]) {
            _markedForDeletion[index] = false;
            _deletionList.removeWhere((item) => item[1] == title);
          } else {
            _markedForDeletion[index] = true;
            _deletionList.add(_deletePair);
          }
          print(_deletionList);
          setState(() {});
        },
      );
    }
    return Container();
  }

  Future<bool> _cancelDeletionState() async {
    if (_readyForDeletion == true) {
      print("In will pop scope $_readyForDeletion");
      setState(() {
        _readyForDeletion = false;
      });

      return false;
    } else
      return true;
  }

  _deleteUserSelectedFeeds() {
    for (var item in _deletionList) {
      print("feedAddress before removal = $_feedAddresses");
      _feedAddresses.remove(item[0]);
      print("feedAddress after removal = $_feedAddresses");
      print("data before removal = $_data");
      _data.removeWhere((feed) => feed.newSiteTitle == item[1]);
      print("data after removal = $_data");
      if (_feedAddresses.isEmpty && _data.isEmpty) {
        _feedData =
            []; // Todo Refactor this class and make sensible. Meaning. Make WebRssFeed Static class and remove the workarounds
      }
    }
    Setting.setUserWebsites(_feedAddresses);
    setState(() {
      _readyForDeletion = false;
      _initializeDeletionCheckList();
    });
  }

  Widget _showDeletionConfirmationButton() {
    if (_readyForDeletion) {
      return FloatingActionButton.extended(
        onPressed: _deleteUserSelectedFeeds,
        label: Text("Delete"),
      );
    }
  }

  //use the user's feed list to generate a list view layout
  Widget _createListView(
      BuildContext context, AsyncSnapshot snap, List<WebRSSAccess> feedData) {
    List<FeedContent> data = snap.data;
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 1));
      },
      child: new ListView.builder(

          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            String title = data[index].newSiteTitle;
            bool _readHeadlines = data[index].shouldHeadlinesBeRead;
            return Card(
                color: Colors.black54,
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewsArticlesScreen(
                            listing: feedData[index],
                            newSite: title,
                            count: _mySettings.numberOfHeadlines,
                            shouldItRead: _readHeadlines,
                          ))),
                  onLongPress: () {
                    setState(() {
                      if (_readyForDeletion) {
                        print("in truth test = $_readyForDeletion");
                        _readyForDeletion = false;
                      } else {
                        print("in false test = $_readyForDeletion");
                        _readyForDeletion = true;
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Center(
                          child: Container(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 40.0,
                                  width: 100.0,
                                  child: data[index].imageUrl == null
                                      ? Text(title, style: TextStyle(fontSize: 14.0),)
                                      : Image.network(
                                    data[index].imageUrl,
                                    height: 40.0,
                                    width: 100.0,
                                  ),
                                ),
                              ) // if there i
                          )),
                      // check the state of the readHeadlines variable and determine what should be displayed.
                      _readHeadlines
                          ? Text(
                              "Speaking ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            )
                          : Text(
                              "Quiet",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                      GestureDetector(
                        onTap: () {
                          // when a tap is detected, toggle sound on or off as necessary

                          // if sound is enabled, disable
                          if (_readHeadlines == true) {
                            data[index].shouldHeadlinesBeRead =
                                false; // set value of class variable directly to expedite updates to the UI
                            Setting.setReadHeadlines(false, title);

                            //else if disabled, enable
                          } else if (_readHeadlines == false) {
                            _speak("Reeding headlines from $title");
                            data[index].shouldHeadlinesBeRead =
                                true; // set value of class variable directly to expedite updates to the UI
                            Setting.setReadHeadlines(true, title);
                          }
                          setState(() {});
                          print(_readHeadlines);
                        },
                        child: _readHeadlines
                            ? Icon(
                                Icons.volume_up,
                                color: Colors.white,
                              )
                            : Icon(
                              Icons.volume_off,
                              color: Colors.white,
                              ),
                      ),
                      _checkDeleteStatus(index, title)
                    ],
                  ),
                ));
          }),
    );
  }

  //use the user's feed list to generate a grid view layout
  Widget _createGridView(
      BuildContext context, AsyncSnapshot snap, List<WebRSSAccess> feedData) {
    List<FeedContent> data = snap.data;
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 1));
      },
      child: new GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: (200/200)),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            String title = data[index].newSiteTitle;
            bool _readHeadlines = data[index].shouldHeadlinesBeRead;
            return Card(
              color: Colors.black54,
              child: InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewsArticlesScreen(
                              listing: feedData[index],
                              newSite: title,
                              count: _mySettings.numberOfHeadlines,
                              shouldItRead: _readHeadlines,
                            ))),
                onLongPress: () {
                  setState(() {
                    if (_readyForDeletion) {
                      print("in truth test = $_readyForDeletion");
                      _readyForDeletion = false;
                    } else {
                      print("in false test = $_readyForDeletion");
                      _readyForDeletion = true;
                    }
                  });
                },
                child: Column(
                  children: <Widget>[
                    Center(
                        child: Container(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 100.0,
                                height: 60.0,
                                child: data[index].imageUrl == null
                                    ? Text(title, style: TextStyle(fontSize: 14.0),)
                                    : Image.network(
                                  data[index].imageUrl,
                                  height: 60.0,
                                  width: 80.0,
                                ),
                              ),
                            ) // if there i
                        )),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        // check the state of the readHeadlines variable and determine what should be displayed.
                        _readHeadlines
                            ? Text(
                                " Speaking ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              )
                            : Text(
                                " Quiet ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                        GestureDetector(
                          onTap: () {
                            // when a tap is detected, toggle sound on or off as necessary

                            // if sound is enabled, disable
                            if (_readHeadlines == true) {
                              data[index].shouldHeadlinesBeRead =
                                  false; // set value of class variable directly to expedite updates to the UI
                              Setting.setReadHeadlines(false, title);

                              //else if disabled, enable
                            } else if (_readHeadlines == false) {
                              _speak("Reeding headlines from $title");
                              data[index].shouldHeadlinesBeRead =
                                  true; // set value of class variable directly to expedite updates to the UI
                              Setting.setReadHeadlines(true, title);
                            }
                            setState(() {});
                            print(_readHeadlines);
                          },
                          child: _readHeadlines
                              ? Icon(
                                  Icons.volume_up,
                                  color: Colors.white,
                                )
                              : Icon(
                                  Icons.volume_off,
                                  color: Colors.white,
                                ),
                        ),
                        _checkDeleteStatus(index, title)
                      ],
                    ),

                  ],
                ),
              ),
            );
          }),
    );
  }

  Future<List<FeedContent>> _initialize() async {
    if (_data.isNotEmpty) {
      return _data;
    }
    print("Attempting to get feed addresses");
    _feedAddresses = await Setting.getUserWebsites();
    print("There are currently ${_feedAddresses.length} feed addresses");
    for (var url in _feedAddresses) {
      if (url != '' || url != null) {
        _feedData.add(WebRSSAccess(url));
      }
    }
    _initializeDeletionCheckList();
    _mySettings.gridLayout = await Setting.getLayoutStyle(); // get the settings
    _mySettings.numberOfHeadlines = await Setting.getAmountOfHeadlines();
    _mySettings.readSpeed = await Setting.getReadSpeed();
    return _getContent(_feedData);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    Widget _buildBottomLayout(Color color, IconData icon, String label) {
      return GestureDetector(
        onTap: () {
          if (label == 'Settings') {
            _navigateToSettingsScreen(context);
          } else if (label == 'Add feed') {
            _navigateToAddFeed(context);
          } else {
            _navigateToSelectFeedScreen(context);
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

    Widget _topTitle = new Container(
        height: height * _topLayoutHeight,
        child: new Row(
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text(
                "My feed",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ))
          ],
        ));
    Widget _bottomLayout = new Container(
      height: height * _bottomLayoutHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildBottomLayout(Colors.black54, Icons.add, 'Add feed'),
          _buildBottomLayout(Colors.black54, Icons.launch, 'Find feed'),
          _buildBottomLayout(Colors.black54, Icons.settings, 'Settings')
        ],
      ),
    );

    Widget _loadingScreen = Container(
      child: FutureBuilder(
          future: _initialize(),
          builder: (BuildContext context, AsyncSnapshot snap) {
            if (snap.hasData && _feedAddresses.length <= _data.length) {
              if (snap.data.length == 0) {
                return Container(
                  color: Colors.black26,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Center(
                        child: Text(
                          "Welcome",
                          style: TextStyle(color: Colors.white, fontSize: 28.0),
                        ),
                      ),
                      RaisedButton(
                        child: Text(
                          "Click me to find your first feed",
                          style:
                              TextStyle(fontSize: 12.0, color: Colors.black54),
                        ),
                        onPressed: () => _navigateToSelectFeedScreen(context),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(25.0)),
                      ),
                      RaisedButton(
                        child: Text(
                          "Click here to add your own",
                          style:
                              TextStyle(fontSize: 12.0, color: Colors.black54),
                        ),
                        onPressed: () => _navigateToAddFeed(context),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(25.0)),
                      ),
                      Center(
                        child: Text(
                          "Your feed is currently empty, add some feeds above",
                          style: TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                );
              }
              return Column(children: <Widget>[
                _topTitle,
                new Container(
                    height: height * _mainContentHeight,
                    child: _mySettings.gridLayout
                        ? _createListView(context, snap, _feedData)
                        : _createGridView(context, snap,
                            _feedData) // decide what layout to use based on user preferences
                    ),
                _bottomLayout
              ]); // decide what layout to use based on user preferences
            } else {
              return Scaffold(
                  body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/loadingbackground.jpg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Text(
                    _loadingMessage,
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ));
            }
          }),
    );

    return WillPopScope(
      onWillPop: _cancelDeletionState,
      child: Scaffold(
          floatingActionButton: _showDeletionConfirmationButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          key: _scaffoldKey,
          body: Container(
              color: Colors.grey[100],
              child: new BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: _loadingScreen,
              ))),
    );
  }
}
