import 'package:flutter/material.dart';
import 'settings.dart';
import 'feedContent.dart';
import 'accessRSSData.dart';
import 'dart:ui';

class SelectScreen extends StatefulWidget {
  @override
  _SelectScreenState createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen>
{
  List<String> _addresses = [];
  List<bool>  _addToUserList = [];
  List<String> _returnList = [];
  String _loadingMessage = '';
  List<FeedContent> _data = [];
  int count = 0;

   Future<List<FeedContent>> _getAddresses() async
  {
    if(_data.isNotEmpty) // prevent unnecessary data usage. if the list was already built;
    {
      return _data;
    }
    List<WebRSSAccess> feedData = [];
    _addresses = await Setting.getDefaultWebsites();
    for(String url in _addresses)
    {
      if(url != null || url != "")
      {
        feedData.add(new WebRSSAccess(url));
      }
    }
    if(_addToUserList.isEmpty)
    {
      _addToUserList = new List<bool>.filled(_addresses.length ,false); // initialize the bool list to match the length of the feed list
    }
    return _getContent(feedData);
  }

   Future<List<FeedContent>> _getContent(List<WebRSSAccess> feedData) async
  {

    for(var item in feedData)
    {
      _data.add(await item.makeFeedContent());

      setState(() {
        _loadingMessage = "Getting info from " + _data[count++].newSiteTitle;
      });
    }
    return _data;
  }


  Widget _createListView(BuildContext context, AsyncSnapshot snap)
  {
    List<FeedContent> data = snap.data;
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index)
        {
          String title = data[index].newSiteTitle;
          return Container(
            color: Colors.black54,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: CheckboxListTile(
                        title: Text(title, style: TextStyle(color: Colors.white),),
                        subtitle: Text("Check to add to your feed", style: TextStyle(color: Colors.white, fontSize: 14.0),),
                        value: _addToUserList[index],
                        onChanged: (bool newValue)
                        {
                          setState(() {
                            _addToUserList[index] = newValue;
                            if(_returnList.contains(_addresses[index]))
                            {
                              _returnList.remove(_addresses[index]);
                            } else
                              {
                                _returnList.add(_addresses[index]);
                              }
                            print("current return list = $_returnList");
                          });
                        },
                      ),
                    )
                  ],
                ),
                Divider(),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/mainback.jpg"),
          fit: BoxFit.cover)
        ),
        child: BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: FutureBuilder(
            future: _getAddresses(),
              builder: (BuildContext context, AsyncSnapshot snap){
              if(snap.hasData && _addresses.length <= _data.length ) // keep the loading screen until the list is completed filling
              {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: ()
                    {
                      Navigator.pop(context, _returnList);
                    },
                    backgroundColor: Colors.black54,
                    icon: Icon(Icons.save),
                    label: Text("Save and exit", style: TextStyle(color: Colors.white),),),
                  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                  body: _createListView(context, snap),
                );
              }
              else
                {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/loadingbackground.jpg"),
                      fit: BoxFit.cover),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Center(
                          child: Text(
                              "Obtaining feed list",
                          ),
                        ),
                        Center(
                          child: Text(_loadingMessage, style: TextStyle(color: Colors.white, fontSize: 14.0),),
                        ),
                        Center(
                          child: Text(
                            "Please wait..."
                          ),
                        )
                      ],
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}
