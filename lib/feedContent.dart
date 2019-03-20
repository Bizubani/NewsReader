//Store Data acquired from the RSS Feed

class FeedContent {

  FeedContent(this.newSiteTitle, this.imageUrl, this.copyright,);

  final String newSiteTitle;
  final String imageUrl;
  final String copyright;
  bool shouldHeadlinesBeRead = false;
}

class FeedItems{

  FeedItems(this.headline, this.description, this.linkToTheStory);

  final String headline;
  String description;
  final String linkToTheStory;


}