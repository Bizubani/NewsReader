import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:html/dom.dart';

//class to access the body of the web story to allow reading it out
class WebScrapping{
  //web client, used to access remote data
  var client = new http.Client();
 Future<void> getHttpBody(String url){
   print(url);
    client.get(url).then((response) {
      var body  = response.body;
      var document = parse.parse(body);
      print(document.outerHtml);
    });
  }

  static void myPrint(){
  print('test');
  }


}