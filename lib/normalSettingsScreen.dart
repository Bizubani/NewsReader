import 'package:flutter/material.dart';
import 'settings.dart';


class NormalSettings extends StatefulWidget{
  @override
  _NormalSettingsState createState() => _NormalSettingsState();
}

class _NormalSettingsState extends State<NormalSettings>{

  int currentHeadlineCount;
  bool currentViewLayout;
  TextEditingController myController = new TextEditingController();

  @override
  void dispose(){
    super.dispose();
  }

  Future<void> getSettingInfo() async {
    currentHeadlineCount = await Setting.getAmountOfHeadlines();
    currentViewLayout = await Setting.getLayoutStyle();
  }

  @override
  Widget build(BuildContext context) {
      getSettingInfo();
      return Scaffold(
        body: Material(
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>
              [
                Text("Please select preferred layout style"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.list, color: Colors.black, ),
                    onPressed: ()=> Setting.setLayoutStyle(true)

                  ),
                  IconButton(
                  icon: Icon(Icons.grid_on, color: Colors.black,),
                      onPressed: ()=> Setting.setLayoutStyle(false)
                  )
                ],
              ),
              Text('We currentlhy have $currentHeadlineCount stories set to read'),
              Row(
                children: <Widget>[
                  Text('Change amount'),

                ],
              )],
            ),
            color: Colors.red,
          ),
        ),

    ),
      );
  }

}