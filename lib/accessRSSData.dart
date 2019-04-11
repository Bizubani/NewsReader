import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'feedContent.dart';
import 'verifyDataIntergity.dart';


// Class that takes a web address and gets the web feed associated with it.
// Also runs some data verification using the class verifyDataIntegrity.
class WebRSSAccess {

  // assign the url string to the web address variable.
  WebRSSAccess(String webAddress){
    this.webAddress = webAddress;
  }

  //attempt to find images attached to stories
  String findImageIfAvailable(RssItem item){
    String imageUrl = "";
    try{
      imageUrl = item.media.thumbnails[0].url;
    }
    catch(e){}
    try{
      imageUrl = item.media.contents[0].url;
    }
    catch (e){}
    String searchString = item.description;
    int start = searchString.indexOf("<img src");
    if(start > 0){
      int beginning = searchString.indexOf("\"", start);
      int end = searchString.indexOf("\"", beginning+1); // begin after the first quotation mark
      imageUrl = searchString.substring(beginning+1, end);
      if(imageUrl.contains("feedburner")){
        imageUrl = "";
      }
    }
    print("Image link: $imageUrl");
    return imageUrl;
  }
  //Test the name attribute from the feed items and return and empty string if none was provided
  String testAuthorName(RssItem item){
    String goodValue = "";
    if(item.author == null){
    } else {
      goodValue = item.author;
    }
    return goodValue;
  }

  String testDateFormat(String test){

  }

  TestData dataTester = new TestData();
  String webAddress;
  var client = new http.Client();
// function that gets the actual items associated with the feed.
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
//function that retrieves the main feed data
  Future<RssFeed> provideRSSFeedInfo() {

    var retrievedContent = client.get(webAddress).then((response) {
      return response.body;
    }).then((body){
      var rssFeed = new RssFeed.parse(body);
      return rssFeed;
    });
    return retrievedContent;

  }
// populates and returns a FeedContent object that stores the particulars of the feed
  Future<FeedContent> makeFeedContent() async{
    var data = await provideRSSFeedInfo();
    var feed;
    try{
       feed = FeedContent(dataTester.parseNewsTitle(data.title),data.image.url, data.copyright);
    }
    on NoSuchMethodError {
       feed = FeedContent(
          dataTester.parseNewsTitle(data.title), null, data.copyright);
    }
    catch (e){
      print("Ran in to problem $e");
    }

    return feed;
  }

// populates and returns in list form, the series of items associated with the feed.
  Future<List<FeedItems>> makeItemContent() async{
    var data = await provideRSSItems();
    List<FeedItems> feedItems = new List();
    String imageUrl = " ";
    for(var element in data){
      imageUrl = findImageIfAvailable(element);
      feedItems.add(new FeedItems(element.title, dataTester.parseGibberish(element.description) , element.link, element.content, imageUrl, element.pubDate, testAuthorName(element)));
    }
    return feedItems;
  }

}
