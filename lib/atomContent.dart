import 'package:webfeed/domain/media/media.dart';

class AtomFeedContent{

  AtomFeedContent(this.newSiteTitle, this.feedID, this.feedIcon, this.feedLogo,  this.rights, this.updated);

  String feedID;
  String newSiteTitle;

  String rights;
  String feedIcon;
  String feedLogo;
  String updated;
  bool shouldHeadlinesBeRead = false;

}

class AtomItems{
  String itemID;
  String title;
  String itemUpdated;
  String published;
  String content;
  Media media;

  AtomItems(this.title, this.itemID, this.content, this.media, this.itemUpdated, this.published);

}