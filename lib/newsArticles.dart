import 'package:flutter/material.dart';
import 'feedContent.dart';
import 'package:read_2_me/accessRSSData.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'webScrapper.dart';
import 'settings.dart';
import 'detailedScreen.dart';

class NewsArticlesScreen extends StatefulWidget{

  NewsArticlesScreen({this.listing, this.newSite, this.count, this.shouldItRead} );

  final WebRSSAccess listing;
  final String newSite;
  final int count;
  final bool shouldItRead;


  @override
  _NewsArticlesWidgetState createState() => _NewsArticlesWidgetState();
}


class _NewsArticlesWidgetState extends State<NewsArticlesScreen>{
  Future<List<FeedItems>> cycleItemList(WebRSSAccess list) async {
      var unique = await list.makeItemContent();
      return unique;
  }

  WebScrapping myAccess = new WebScrapping();
  //Todo make this dependent on the users settings.
  bool isSpeaking = false; // flag if headlines are meant to be read.
  FlutterTts myVoiceOver = new FlutterTts();
  //Todo: expand on this by having a variety of words for starting, ending and in-between
  List<String> transitionWords = ['Next ', 'Next up ', 'Continuing ', 'Among the other top stories ', 'Also ' ];
  List<String> openingWords = ['First up today ', 'The top story is ', 'First up ', 'We begin with '];
  List<String> lastWords = ['Finally ', 'Finally today ', 'Your final headline is ', 'Lastly '];
  bool firstEntry = true;

  List<int> _chooseWords(int length){
    int i = 0;
    int randInt;
    var random = new Random();
    List<int> myList = new List(length);
    while(i < length){
      randInt = random.nextInt(length);
      if(!myList.contains(randInt)){
        myList[i++] = randInt;
      }
    }
    return myList;
  }

  int _getRandomNumber(int length){
    var random = new Random();
    int myInt = random.nextInt(length);
    return myInt;
  }

  void _readHeadlines() async{
    String headlines = '';
    isSpeaking = true;
    var articles = await  cycleItemList(widget.listing);
    int count = await Setting.getAmountOfHeadlines();
    int openingLength = openingWords.length;
    int lastLength = lastWords.length;
    int transitionLength = transitionWords.length;
    List<int> randomOrder = _chooseWords(transitionLength);
    int randomStart = _getRandomNumber(openingLength);
    int randomEnd = _getRandomNumber(lastLength);

    for( var i = 0, j = 0; j <= count; j++ ){
      if(j == 0){ // if this is the first headline being generated to the headline list, choose from the opening words
        headlines += '... ' + openingWords[randomStart] + '... ';
      }
      else if(j == count ){ // if this is the last headline being added, put in a random closing word
        headlines += '... ' + lastWords[randomEnd] + '... ';
      }
      else{ // else choose from the transitional words
        headlines += '... ' + transitionWords[randomOrder[i++]] + '... ';
      }

      headlines += articles[j].headline + " ... ";
      if( i >= transitionLength ){ // if we need to, restart with the same random order
        i = 0; // set it to restart at zero
      }
    }

    print(headlines);
    myVoiceOver.speak("These are the latest headlines from " + widget.newSite + "..."+ headlines);
    // Todo: determine length of delay based on length of the string file.
    var speakForThisLong = Duration(seconds: 15);
    Future.delayed(speakForThisLong, _cancelSpeakingPriority);

  }

  Future<void> _cancelSpeakingPriority(){

    isSpeaking = false;

  }

  void _speak(String headline, String description){

    myVoiceOver.speak(headline + "..." + description + "...");
  }

  // external library to make link to stories possible.
  void _launchURL(String url) async{
    if(await canLaunch(url)){
      await launch(url);
    }
    else{
      throw 'Could not launch $url';
    }
  }

  Future<bool> _stopSpeaking() async{
      myVoiceOver.stop();
     if(isSpeaking == true){
      isSpeaking = false;
      return Future.value(false);
     }
     return true;
  }


  @override
  Widget build(BuildContext context) {

    if(widget.shouldItRead && firstEntry) {
      _readHeadlines();
      firstEntry = false;
    }
    var height = MediaQuery.of(context).size.height;

    Widget _buildBottomLayout(Color color, IconData icon, String label){
      return GestureDetector(
        onTap: ()=> print("Coming soon"),
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
                  child: Text(widget.newSite, textAlign: TextAlign.center,),
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
          _buildBottomLayout(Colors.white, Icons.landscape, 'Placeholder'),
          _buildBottomLayout(Colors.white, Icons.settings, 'Settings')

        ],
      ),
    );


    Widget loadingScreen = new Container(

      child: FutureBuilder(
          future : cycleItemList(widget.listing),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.hasData){
              return Column(
                children: <Widget>[
                  topTitle,
                Container(
                  height: height * 0.97,
                  child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index){
                        var headline = snapshot.data[index].headline ;
                        var description = snapshot.data[index].description ;
                        var pubDate = snapshot.data[index].pubDate;
                        var author = snapshot.data[index].author;
                       // var pubTime = DateTime.parse(pubDate);
                        return Column(
                          children: <Widget>[
                            ListTile(
                                title: Text(headline, style: TextStyle(color: Colors.white,fontSize: 18.0)),
                                subtitle: Text(description, style: TextStyle(color: Colors.white, fontSize: 12.0),),
                                onLongPress: () => _speak(headline, description),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) {
                                          _stopSpeaking();
                                         return DetailedScreen(snapshot.data[index]);

                                        } ) )

                            ),
                            Image(
                              image: NetworkImage(snapshot.data[index].itemImageURL),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                              children: <Widget>[
                                Text(pubDate, style: TextStyle(fontSize: 12.0),),
                                Text(author, style: TextStyle(fontSize: 12.0))
                              ],
                            ),
                            Divider(),
                          ],
                        );
                      }),
                ),
                 // bottomLayout
                ],
              );
            }
            else{
              return Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/loadingbackground.jpg"),
                      fit: BoxFit.cover)
                    ),
                  )
              );
            }
          }),
    );

    return WillPopScope(
      onWillPop: _stopSpeaking,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => Future.delayed(Duration(seconds: 1)), // Todo Implement the refresh command
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover)
            ),
            child: loadingScreen
          ),
        ),
      ),
    );
  }

}