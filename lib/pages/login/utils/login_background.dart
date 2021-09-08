import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pacientes/pages/login/utils/arc_clipper.dart';
import 'package:pacientes/pages/login/utils/uidata.dart';

class LoginBackground extends StatelessWidget {
  final showIcon;
  final image;
  LoginBackground({this.showIcon = true, this.image});

  Widget topHalf(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return new Flexible(
      flex: 2,
      child: ClipPath(
        clipper: new ArcClipper(),
        child: Stack(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(1, 1),
                colors: UIData.kitGradients1,
              )),
            ),
            showIcon
                ? Column(
                      children: <Widget>[
                        Flexible(
                          flex: 3,
                          child: Center(
                            child: SizedBox(
                              height: deviceSize.height / 8,
                              width: deviceSize.width / 2,
                              child: Container(
                                  //width: (MediaQuery.of(context).size.width * 0.45),
                                  height: deviceSize.height / 8,
                                  ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: new Container(),
                        )
                      ],
                    )
                : Row(
              children: <Widget>[
                Flexible(flex:1,child:Container()),
                Flexible(
                  flex:1,
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: image != null
                          ? Image.asset(
                        image,
                        fit: BoxFit.fitWidth,
                      )
                          : new Container()),
                ),
                Flexible(flex:1,child:Container()),
              ],
            )
          ],
        ),
      ),
    );
  }

  final bottomHalf = new Flexible(
    flex: 3,
    child: Container(
      decoration: new BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(1,1),
            colors: UIData.kitGradients1,
          )),
      child: new Column(
        children: <Widget>[
          Flexible(
            flex:16,
            child: ClipPath(
              clipper: ArcClipper(),
              child: Container(
                color: Color(0xffeeeeee),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom:8.0),
                    child: Text("ConectMed", textAlign: TextAlign.center,overflow: TextOverflow.fade,style: TextStyle(fontSize: 30,color:Colors.blueGrey)),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container()
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[topHalf(context), bottomHalf],
    );
  }
}
