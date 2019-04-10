//Store Data acquired from the RSS Feed
import 'package:webfeed/domain/rss_content.dart';
import 'package:webfeed/domain/media/media.dart';
class FeedContent {

  FeedContent(this.newSiteTitle, this.imageUrl, this.copyright,);

  final String newSiteTitle;
  String imageUrl;
  final String copyright;
  bool shouldHeadlinesBeRead = false;
}

class FeedItems{

  FeedItems(this.headline, this.description, this.linkToTheStory, this.storyImage, this.storyMedia, this.pubDate);

  final String headline;
  String description;
  final String linkToTheStory;
  final RssContent storyImage;
  final Media storyMedia;
  final String pubDate;



}