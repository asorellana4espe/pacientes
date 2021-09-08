import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toast/toast.dart';
class BuildAppBar{

  Widget App_Bar(BuildContext context){
    return AppBar(
      elevation: 0.0,
      title: Text("App Paciente"),
      flexibleSpace: Container(
        color: Color(0xFF064583),
      ),
      centerTitle: true,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right:22.0),
          child: InkWell(
              child: SizedBox(
                height: 25,
                width: 25,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SvgPicture.asset(
                      'assets/images/noti0.svg'),
                ),
              ),
              onTap: () {
                Toast.show("No tiene Nuevas Notificaciones", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              }),
        ),
      ],
    );
  }
}