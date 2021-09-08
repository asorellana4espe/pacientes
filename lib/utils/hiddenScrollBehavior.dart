import 'package:flutter/material.dart';

class HiddenScrollBehavior extends ScrollBehavior{
  Widget buildViewportChrome(BuildContext context,Widget child,AxisDirection axisDirection){
    return child;
  }
}