class TestData{

  // Clean up the string to be saved in feed content.
  String parseNewsTitle(String newsTitle){

    if (newsTitle.contains('-')){
      int stop = newsTitle.indexOf('-');
      newsTitle = newsTitle.substring(0, stop);
    }
    return newsTitle;
  }

  //Clean up the overview of the content before it is saved in feed content.
  String parseGibberish(String check) {

    int needsCorrection = 0;
    needsCorrection = check.indexOf('<div'); // checks if the garbage is attached to the file
    //if garbage is attached, clear it.
    if(needsCorrection != -1){
      check = check.substring(0, needsCorrection);
    }
    //TODO make this more general
    //check if the string still contains garbage elements. Is written intimately and therefore badly to fix a speciic problem with Buzzfeed
    if(check.contains('<')) {
      int stop = check.indexOf('<', 1);
      int start = 4; // this is the position that i know is after the garbage to start.
      check = check.substring(start, stop);
    }
    return check;
  }


}