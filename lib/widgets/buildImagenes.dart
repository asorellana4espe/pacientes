import 'package:flutter/material.dart';

BoxDecoration buildBoxImageDecoration(
    String url, BoxFit boxFit, Alignment alignment) {
  return BoxDecoration(
    image: DecorationImage(
        image: AssetImage("assets/images/${url}"),
        fit: boxFit,
        alignment: alignment
    ),
  );
}

Widget buildImageAsset(String url, BoxFit boxFit, Alignment alignment) {
  return Image.asset("assets/images/${url}", fit: boxFit, alignment: alignment);
}
