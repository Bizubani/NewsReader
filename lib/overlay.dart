import 'package:flutter/material.dart';

class CustomOverlay{
  CustomOverlay(this.myContext,);
  final BuildContext myContext;


  TextEditingController myTextControl;



  OverlayEntry _overlayEntry;
  OverlayState _overlayState;
// Todo Generalize for bottom bar functions.
  // Todo Keep track of how many times class was called and create list for _overlayentry so that each press can be popped.
 buildOverlay(String selection){



  _overlayState.insert(_overlayEntry);
  }

  Future<bool> removeOverlay() async{
   if(_overlayState.mounted == true){
     _overlayEntry.remove();
     myTextControl.dispose();
   }
   return true;
  }

}