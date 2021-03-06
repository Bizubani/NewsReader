import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'feedContent.dart';
import 'verifyDataIntergity.dart';


// Class that takes a web address and gets the web feed associated with it.
// Also runs some data verification using the class verifyDataIntegrity.
class WebRSSAccess {
  // assign the url string to the web address variable.
  WebRSSAccess(String webAddress){
    _setWebAddress(webAddress);
  }

  void _setWebAddress(String address){
    if(address != "" || address != null){
      webAddress = address;
    } else{
      Exception invalidString = new Exception("Invalid url");
      throw invalidString;
    }
  }

  //test if a string contains a img src tag
  int _testForImgSrc(String value){
    int sourcePosition = 0;
    int position = value.indexOf("<img ");
    if(position != -1)
      {
        print("position in _testForImgSrc - $position");
        sourcePosition = value.indexOf("src", position);
      }

    return sourcePosition;
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

  bool _testForHTTPStart(String test)
  {
    if(test.startsWith("http"))
    {
      return true;
    }
    else
      return false;
  }

  String _parseHTML(String testText)
  {
    print("Before parsing this is the description: $testText");
        var myParser =parser.HtmlParser(testText);
        var parsedDocument = myParser.parse().querySelectorAll('body');
        testText = parsedDocument[0].text;
        print("\nAfter parsing this is the description: $testText");

    return testText;
  }

  //attempt to find images attached to stories
  String _findImageIfAvailable(RssItem item)
  {
    String temp = "";
    String imageUrl = "";

    try{
      temp = item.media.thumbnails[0].url;
      if(_testForHTTPStart(temp))
        {
          imageUrl = temp;
        }
    }
    catch(e){}
    try{

      temp = item.media.contents[0].url;
      if(_testForHTTPStart(temp))
      {
        imageUrl = temp;
      }
    }
    catch (e){}
    try{
      temp = item.enclosure.url;
      if(_testForHTTPStart(temp))
      {
        imageUrl = temp;
      }
    }
    catch (e){}
    try{
      temp = _extractImageURL(item.content.value);
      if(_testForHTTPStart(temp))
      {
        imageUrl = temp;
      }
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
      feedItems.add(new FeedItems(_parseHTML(element.title), _parseHTML(element.description), element.link, element.content, imageUrl, element.pubDate == null ? "": element.pubDate, _testAuthorName(element)));
    }
    return feedItems;
  }

}
