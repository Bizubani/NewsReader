import 'package:shared_preferences/shared_preferences.dart';


// Simple class to set the users preferences and save them
class Setting{

  static final String _readSpeed = 'ReadSpeed';
  static final String _amountOfHeadlines = 'AmountOfHeadlines';
  static final String _getNotified = 'GetNotified';
  static final String _layoutStyle = 'LayoutStyle';
  static final String _websites = 'Websites';

  static Future<bool> setReadSpeed(double readSpeed) async{
    final prefs = await SharedPreferences.getInstance(); 
    return prefs.setDouble(_readSpeed, readSpeed);
  }// end of setReadSpeed

  static Future<double> getReadSpeed() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_readSpeed) ?? 1.0; // have a returnable default read speed
  }//end of getReadSpeed

  static Future<bool> setAmountOfHeadlines(int amount) async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_amountOfHeadlines, amount);
  }//end of setAmountOfHeadlines

  static Future<int> getAmountOfHeadlines() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_amountOfHeadlines) ?? 5; // have a returnable default amount
  }//end of getAmountOfHeadlines

  static Future<bool> setGetNotified(bool notify) async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_getNotified, notify);
  }//end of setGetNotified

  static Future<bool> getGetNotified() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getNotified) ?? false; // have a returnable default response, which is false in this case.
  }//end of getGetNotified

  static Future<bool> setLayoutStyle(bool layoutStyleList) async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_layoutStyle, layoutStyleList);// bool saying whether user wants list or Grid
  }// end of setLayoutStyle

  static Future<bool> getLayoutStyle() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_layoutStyle) ?? false; // set default layout style to list view
  }// end of getLayoutStyle

  static Future<bool> setReadHeadlines(bool answer, String newSiteTitle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(newSiteTitle, answer);
  } //end of setReadHeadlines

  static Future<bool> getReadHeadlines(String newSiteTitle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(newSiteTitle) ?? true; // have a returnable default amount
  } //end of getReadHeadlines

  static Future<bool> setWebsites(List<String> listOfSites) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_websites, listOfSites);
  } // end of setWebsites.

  static Future<List<String>> getWebsites() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_websites)  ?? [ //return default string list in case
      'http://feeds.reuters.com/Reuters/worldNews',
      "http://feeds.bbci.co.uk/news/world/rss.xml",
      "https://www.buzzfeed.com/world.xml",
      "http://www.spiegel.de/international/index.rss",
      "http://www.espn.com/espn/rss/news",
      "https://www.techradar.com/rss",
     "http://feeds.bbci.co.uk/news/rss.xml",
    ];
  }// end of getWebsites

}//end of Settings class