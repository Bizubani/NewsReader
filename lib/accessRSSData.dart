import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'feedContent.dart';
import 'verifyDataIntergity.dart';
import 'package:xml/xml.dart';

// create a class to access a website to retrieve web data.
class WebRSSAccess {

  // assign the url string to the webaddress variable.
  WebRSSAccess(String webAddress){
    this.webAddress = webAddress;
  }
  TestData dataTester = new TestData();
  String webAddress;
  var client = new http.Client();

  Future<List<RssItem>> provideRSSItems() {
  // attempt to contact webaddress
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


  Future<FeedContent> makeFeedContent() async{
    var data = await provideRSSFeedInfo();

    return FeedContent(dataTester.parseNewsTitle(data.title), data.image.url, data.copyright);

  }

  Future<List<FeedItems>> makeItemContent() async{
    var data = await provideRSSItems();
    List<FeedItems> feedItems = new List();

    for(var element in data){
      feedItems.add(new FeedItems(element.title, dataTester.parseGibberish(element.description) , element.link));
    }
    return feedItems;
  }
}
