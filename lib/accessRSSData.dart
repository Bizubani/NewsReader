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

  //test if a string contains a img src tag
  int _testForImgSrc(String value){
    int position = value.indexOf("<img src");
    return position;
  }

  //hold logic to extract image Url from a string
  String _extractImageURL(String testString){
    int start = _testForImgSrc(testString);
    if(start > 0){
      int beginning = testString.indexOf("\"", start);
      int end = testString.indexOf("\"", beginning+1); // begin after the first quotation mark
      testString = testString.substring(beginning+1, end);
      if(testString.contains("feedburner")){
        testString = "";
      }
    }
    return testString;
  }

  //attempt to find images attached to stories
  String _findImageIfAvailable(RssItem item){

    String imageUrl = "";
    try{
      imageUrl = item.media.thumbnails[0].url;
    }
    catch(e){}
    try{

      imageUrl = item.media.contents[0].url;
    }
    catch (e){}
    try{
      imageUrl = item.enclosure.url;
    }
    catch (e){}
    try{
      imageUrl = _extractImageURL(item.content.value);
    }
    catch(e){}
    String searchString = item.description;
    if(_testForImgSrc(searchString) > 0){
      imageUrl = _extractImageURL(searchString);
    }
    print("Image link: $imageUrl");
    return imageUrl;
  }
  //Test the name attribute from the feed items and return and empty string if none was provided
  String _testAuthorName(RssItem item){
    String goodValue = "";
    if(item.author != null){
      goodValue = item.author;
    }else if(item.dc.creator != null) {
      goodValue = item.dc.creator;
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
      imageUrl = _findImageIfAvailable(element);
      feedItems.add(new FeedItems(element.title, dataTester.parseGibberish(element.description) , element.link, element.content, imageUrl, element.pubDate, _testAuthorName(element)));
    }
    return feedItems;
  }

}
