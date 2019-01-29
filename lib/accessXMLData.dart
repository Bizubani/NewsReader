import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'feedContent.dart';
import 'verifyDataIntergity.dart';

class WebXMLAccess{

  WebXMLAccess(String webAddress){
    this.webAddress = webAddress;
  }
  TestData dataTester = new TestData();
  String webAddress;
  var client = new http.Client();

  Future<xml.XmlDocument> provideXMLContent() {

    print(webAddress);

    var retrievedContent = client.get(webAddress).then((response){
      return response.body;
    }).then((body){
      return xml.parse(body);
    });
    return retrievedContent;
  }
}