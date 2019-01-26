import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'feedContent.dart';
import 'package:xml/xml.dart';

class WebAccess {

  WebAccess(String webAddress){
    this.webAddress = webAddress;
  }

  String webAddress;
  var client = new http.Client();

  Future<List<RssItem>> provideRSSItems() {

    var retrievedContent = client.get(webAddress).then((response) {
      return response.body;
     }).then((body){

       var rssFeed = new RssFeed.parse(body);
       var rssItems = rssFeed.items;
       return rssItems;
    });


    return retrievedContent;

  }

  Future<RssFeed> provideRSSFeedInfo() {

    var retrievedContent = client.get(webAddress).then((response) {
      return response.body;
    }).then((body){
      var rssFeed = new RssFeed.parse(body);
      return rssFeed;
    });
    return retrievedContent;

  }

  // Clean up the string to be saved in feed content.
  String _parseNewsTitle(String newsTitle){

    if (newsTitle.contains('-')){
      int stop = newsTitle.indexOf('-');
      newsTitle = newsTitle.substring(0, stop);
    }
    return newsTitle;
  }

  //Clean up the overview of the content before it is saved in feed content.
  String _parseGibberish(String check) {

    int needsCorrection = 0;
    needsCorrection = check.indexOf('<div'); // checks if the garbage is attached to the file
    //if garbage is attached, clear it.
    if(needsCorrection != -1){
      check = check.substring(0, needsCorrection);
    }
    //TODO make this more general
    //check if the string still contains garbage elements. Is written intimately and therefore badly to fix a speciic problem with Buzzfeed
    if(check.contains('<')) {
      int stop = check.indexOf('<', 1);
      int start = 4; // this is the position that i know is after the garbage to start.
      check = check.substring(start, stop);
    }
    return check;
  }

  Future<FeedContent> makeFeedContent() async{
    var data = await provideRSSFeedInfo();

    return FeedContent(_parseNewsTitle(data.title), data.image.url, data.copyright);

  }

  Future<List<FeedItems>> makeItemContent() async{
    var data = await provideRSSItems();
    List<FeedItems> feedItems = new List();

    for(var element in data){
      feedItems.add(new FeedItems(element.title, _parseGibberish(element.description) , element.link));
    }
    return feedItems;
  }
}
