import 'package:flutter/material.dart';

class SettingOverlay{
  SettingOverlay(this.myContext);
  final BuildContext myContext;

  OverlayEntry _overlayEntry;
  OverlayState _overlayState;
// Todo Generalize for bottom bar functions.
  // Todo Keep track of how many times class was called and create list for _overlayentry so that each press can be popped.
 buildOverlay(){
  _overlayState = Overlay.of(myContext);
  _overlayEntry = OverlayEntry(
       builder: (context) => Container(
         child: Center(
           child: Container(
             color: Colors.black87,
             height: 700,
             width: 400,
           ),
         )

       )
  );

  _overlayState.insert(_overlayEntry);
  }

  Future<bool> removeOverlay() async{
   if(_overlayState.mounted == true){
     _overlayEntry.remove();
   }
   return true;
  }

}