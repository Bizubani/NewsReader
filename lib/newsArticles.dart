import 'package:flutter/material.dart';
import 'feedContent.dart';
import 'package:read_2_me/accessRSSData.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'loading_screen.dart';
import 'webScrapper.dart';
import 'settings.dart';

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
  List<String> transitionWords = ['First up ', 'Second', 'Next','','Finally ', ' ', ''];

  void _readHeadlines() async{
    isSpeaking = true;
    var articles = await  cycleItemList(widget.listing);
    int count = await Setting.getAmountOfHeadlines();
    String headlines = '';
    for( var i = 0; i <= count; i++ ){
      headlines += '... ' +transitionWords[i] + '... ';
      headlines += articles[i].headline + " ... ";
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

    if(widget.shouldItRead) {
      _readHeadlines();
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
    Widget mainContent = new Container(
      height: height * 0.9,
      child: FutureBuilder(
          future : cycleItemList(widget.listing),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.hasData){
              return ListView.builder(

                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index){
                    var headline = snapshot.data[index].headline ;
                    var description = snapshot.data[index].description ;
                    return Card(
                      child: ListTile(
                        title: Text(headline, style: TextStyle(fontSize: 20.0)),
                        subtitle: Text(description),
                        onLongPress: () => _speak(headline, description),
                        onTap: () =>
                           myAccess.getHttpBody(snapshot.data[index].linkToTheStory)
                         //_launchURL(snapshot.data[index].linkToTheStory),
                      ),
                    );
                  });
            }
            else{
              return Scaffold(
                  backgroundColor: Colors.white,
                  body: new ColorLoader5());
            }
          }),
    );

    return WillPopScope(
      onWillPop: _stopSpeaking,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => Future.delayed(Duration(seconds: 1)), // Todo Implement the refresh command
          child: Container(
            color: Colors.grey,
            child: Column(
              children: <Widget>[
                topTitle,
                mainContent,
                bottomLayout
              ],
            )
          ),
        ),
      ),
    );
  }

}