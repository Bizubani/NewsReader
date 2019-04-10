import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'atomContent.dart';
import 'verifyDataIntergity.dart';


// Class that takes a web address and gets the web feed associated with it.
// Also runs some data verification using the class verifyDataIntegrity.
class AtomAccess {

  // assign the url string to the web address variable.
  AtomAccess(String webAddress){
    this.webAddress = webAddress;
  }
  TestData dataTester = new TestData();
  String webAddress;
  var client = new http.Client();

// function that gets the actual items associated with the feed.
  Future<List<AtomItem>> provideAtomItems() {
    // attempt to contact webaddress
    var retrievedContent = client.get(webAddress).then((response) {
      return response.body;
    }).then((body){

      var atomFeed = new AtomFeed.parse(body);
      var atomItems = atomFeed.items;
      return atomItems;
    });
    return retrievedContent;
  }
//function that retrieves the main feed data
  Future<AtomFeed> provideAtomFeedInfo() {

    var retrievedContent = client.get(webAddress).then((response) {
      return response.body;
    }).then((body){
      var atomFeed = new AtomFeed.parse(body);
      return atomFeed;
    });
    return retrievedContent;

  }
// populates and returns a FeedContent object that stores the particulars of the feed
  Future<AtomFeedContent> makeFeedContent() async{
    var data = await provideAtomFeedInfo();
    var feed;
    try{
      feed = AtomFeedContent(data.title, data.id, data.icon, data.logo, data.rights, data.updated);
    }
    on NoSuchMethodError {
      feed = AtomFeedContent(data.title, data.id, data.icon, data.logo, data.rights, data.updated);
    }
    catch (e){
      print("Ran in to problem $e");
    }

    return feed;
  }
// populates and returns in list form, the series of items associated with the feed.
  Future<List<AtomItems>> makeItemContent() async{
    var data = await provideAtomItems();
    List<AtomItems> atomItems = new List();

    for(var element in data){
      try{
        print(element.media.thumbnails);}
      catch (e){
        print('Unable to print, error $e');
      }
      atomItems.add(new AtomItems(element.title, element.id, element.content, element.media, element.updated, element.published));
    }
    return atomItems;
  }

}
