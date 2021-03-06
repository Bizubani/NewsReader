import 'package:flutter/material.dart';
import 'utilityClasses.dart';


class NormalSettings extends StatefulWidget{
  NormalSettings(this.mySettings);
  final GlobalSettings mySettings;

  @override
  _NormalSettingsState createState() => _NormalSettingsState();
}

class _NormalSettingsState extends State<NormalSettings>{

  double _currentHeadlineCount;
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
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>
                [
                  Text("Please select preferred layout style", style: TextStyle(color: Colors.black54),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.list, color: _currentViewLayout? Colors.green : Colors.black54, size: 50.0,),
                      onPressed: (){
                        print(_currentViewLayout);
                        _currentViewLayout = true;
                        setState(() {});}

                    ),
                    IconButton(
                    icon: Icon(Icons.grid_on, color: _currentViewLayout? Colors.black54 : Colors.green, size: 50.0),
                        onPressed: () {
                          _currentViewLayout = false;
                          setState(() { });
                        }
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Center(
                        child: Text('We currently have ${_currentHeadlineCount.toInt()} stories set to read',
                            style: TextStyle(fontSize: 14.0, color: Colors.black54))),
                    Row(
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                            child: Slider(
                                value: _currentHeadlineCount,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                activeColor: Colors.green,
                                onChanged: (double newValue) { setState(() {
                                  _currentHeadlineCount = newValue;
                                }); })),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${_currentHeadlineCount.toInt()}"),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                Center(
                    child: Text('The current reading speed is set to $_readSpeed',
                        style: TextStyle(fontSize: 14.0, color: Colors.black54))),
                ]),
            ),
          ),

    ),
        ),
      );
  }

}