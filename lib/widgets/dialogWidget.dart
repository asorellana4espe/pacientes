import 'package:pacientes/utilities/data.dart';
import 'package:flutter/material.dart';

dialogCustom(BuildContext context1,String titulo, String mensaje, int conectabot){
  List<String> conectabotList=["assets/img/conectabotTransparente.png"];

  TextEditingController _mailText= TextEditingController();
  showDialog(context: context1,
      builder: (BuildContext context){
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.padding),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child:Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
                      + Constants.padding, right: Constants.padding,bottom: Constants.padding
                  ),
                  margin: EdgeInsets.only(top: Constants.avatarRadius),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Constants.padding),
                      boxShadow: [
                        BoxShadow(color: Colors.black,offset: Offset(0,10),
                            blurRadius: 10
                        ),
                      ]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(titulo,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w800,color: Color(
                          0xFF064583)),),
                      SizedBox(height: 15,),
                      Text(mensaje,style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
                      SizedBox(height: 10,),
                      SizedBox(height: 10,),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            },

                            child: Text("Ok",style: TextStyle(fontSize: 18),)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: Constants.padding,
                  right: Constants.padding,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: Constants.avatarRadius,
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                        child: Image.asset(conectabotList[conectabot],fit: BoxFit.contain,)
                    ),
                  ),
                ),
              ],
            ));
      }
  );
}

