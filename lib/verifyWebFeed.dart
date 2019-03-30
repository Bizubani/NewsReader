import 'accessXMLData.dart';
import 'accessRSSData.dart';
import 'feedContent.dart';

//class to verify that user inputted feed is valid user and determine whether it is an Rss feed or
//a Xml feed.
class FeedVerification {
  FeedVerification(String testAddress) {
    _verifyFeed = testAddress;

  }
  // private class members

  String _newsTitle = '';
  String _imageURL = '';
  String _verifyFeed;

  //helper functions
  Future<void> getFeed(String testThis) async{
    WebRSSAccess source =  WebRSSAccess(testThis);
    FeedContent content = await source.makeFeedContent();

    // assign the two test items to class members to be checked.
    _newsTitle = content.newSiteTitle;
    _imageURL = content.imageUrl;

  }

  // utility functions
  Future<int> verifyFeed() async{ // will be used to test the member variables

    await getFeed(_verifyFeed);
    // TODO devise a good test for the string
      if(_newsTitle.length < 3 || _newsTitle.length > 25){
        print(_newsTitle);
        print(_imageURL);
        return 1; // Feed is not valid
      }
      else
        print(_newsTitle);
        print(_imageURL);
        print('3');
        return 3; // Feed is valid.
  }

}



