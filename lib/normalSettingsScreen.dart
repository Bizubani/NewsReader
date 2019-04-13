import 'package:flutter/material.dart';
import 'utilityClasses.dart';


class NormalSettings extends StatefulWidget{
  NormalSettings(this.mySettings);
  final GlobalSettings mySettings;

  @override
  _NormalSettingsState createState() => _NormalSettingsState();
}

class _NormalSettingsState extends State<NormalSettings>{

  int _currentHeadlineCount;
  bool _currentViewLayout;
  double _readSpeed;
  TextEditingController myController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentHeadlineCount = widget.mySettings.numberOfHeadlines;
    _currentViewLayout = widget.mySettings.gridLayout;
    _readSpeed = widget.mySettings.readSpeed;
  }
  @override
  void dispose(){
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

      return WillPopScope(
        onWillPop: () {
          widget.mySettings.readSpeed = _readSpeed;
          widget.mySettings.gridLayout = _currentViewLayout;
          widget.mySettings.numberOfHeadlines = _currentHeadlineCount;
          Navigator.pop(context, widget.mySettings);
        },
        child: Scaffold(
          body: Material(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/settingbackground.jpg"),
                      fit: BoxFit.cover
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>
                [
                  Text("Please select preferred layout style"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.list, color: _currentViewLayout? Colors.green : Colors.white, size: 50.0,),
                      onPressed: (){
                        print(_currentViewLayout);
                        _currentViewLayout = true;
                        setState(() {});}

                    ),
                    IconButton(
                    icon: Icon(Icons.grid_on, color: _currentViewLayout? Colors.white : Colors.green, size: 50.0),
                        onPressed: () {
                          _currentViewLayout = false;
                          setState(() { });
                        }
                    )
                  ],
                ),
                Center(
                    child: Text('We currentlhy have $_currentHeadlineCount stories set to read',
                        style: TextStyle(fontSize: 14.0, color: Colors.white))),
                Center(
                    child: Text('The current reading speed is set to $_readSpeed',
                        style: TextStyle(fontSize: 14.0, color: Colors.white))),
                ]),
            ),
          ),

    ),
        ),
      );
  }

}