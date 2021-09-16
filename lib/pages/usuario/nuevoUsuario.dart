import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pacientes/pages/login/loginPage.dart';
import 'package:pacientes/pages/login/utils/PinInput.dart';
import 'package:pacientes/utils/Constantes.dart';
import 'package:pacientes/utils/animateDo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pacientes/utils/hiddenScrollBehavior.dart';
import 'package:pacientes/utils/pushNotifications.dart';
import 'package:url_launcher/url_launcher.dart';

class NuevoUsuario extends StatefulWidget {
  final String usuarioUID;

  const NuevoUsuario({Key key, this.usuarioUID}) : super(key: key);
  @override
  _NuevoUsuarioState createState() => _NuevoUsuarioState();
}

class _NuevoUsuarioState extends State<NuevoUsuario> {
  PushNotifications pushN;
  String _token = "";
  bool registrar = true;

  /// Control the input text field.
  TextEditingController _pinEditingController = TextEditingController();

  /// Decorate the outside of the Pin.
  PinDecoration _pinDecoration =
  UnderlineDecoration(enteredColor: Colors.black, hintText: 'XXXXXXXXXX');

  final _formKey = GlobalKey<FormState>();
  String _cedula = "0";

  _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false);

    FocusScope.of(context).requestFocus(new FocusNode());
  }

  _pacienteRegistrado(BuildContext context) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('pacientes')
        .where('cedula', isEqualTo: _cedula)
        .getDocuments();
    if (snapshot.documents.length != 0) {
      if (snapshot.documents[0].data['uid'] == null) {
        Firestore.instance
            .collection('pacientes')
            .document(snapshot.documents[0].documentID)
            .updateData({'uid': widget.usuarioUID, 'token': _token});
        FocusScope.of(context).requestFocus(new FocusNode());
      } else {
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          registrar = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context1) => errorDialog(
                "Cédula incorrecta",
                "OK",
                "Ya existe un usuario registrado con este número de cedula, si considera esto como un error por favor comuníquese con Soporte 😊"));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pushN = new PushNotifications();
    initPushN();
  }

  initPushN() async {
    _token = await pushN.initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("ConectaMed"),
        flexibleSpace: Container(
          color: Color(0xFF064583),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _logout(context);
            },
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: ScrollConfiguration(
          behavior: HiddenScrollBehavior(),
          child: ListView(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Center(
                    child: Form(
                  key: _formKey,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 18.0, left: 15, right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Ingreso del Paciente",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Color(0xFF064583)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 25,),
                        Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 15,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Ingrese su Número de Cédula:",style:TextStyle(color: Colors.blue)),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.featured_video,color: Colors.blue,),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left:8.0),
                                        child: PinInputTextField(
                                          pinLength: 10,
                                          decoration: _pinDecoration,
                                          controller: _pinEditingController,
                                          autoFocus: true,
                                          textInputAction: TextInputAction.done,
                                          onChanged: (value) {
                                            setState(() {
                                              _cedula = value;
                                            });
                                            if (value.length == 10) {
                                              registrar = true;
                                              _pacienteRegistrado(context);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        _cedula.length == 10
                            ? BounceInUp(
                          child: new Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0)),
                              color: Colors.white,
                              elevation: 5.0,
                              child: SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Column(children: <Widget>[
                                      Text("ConectaMed",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                      Text("de uso exclusivo para Pacientes Registrados de ..........................",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15),),
                                      SizedBox(height: 15),
                                      Text("Por favor active su usuario comunicandose con el administrador, contacte via Whatsapp al Administrador",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                                      SizedBox(height: 15),
                                      Card(
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        elevation: 10,
                                        child: InkWell(
                                          onTap:() {
                                            launch(
                                                'https://api.whatsapp.com/send?phone=593996803139&text=Hola%20quiero%20validar%20mi%20Usuario%20en%20la%20App%20Paciente');
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(20.0)),color: Color(0xF0075E54),),
                                              child: Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Container(
                                                        width: 58,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                            image: new DecorationImage(
                                                              alignment: FractionalOffset.topCenter,
                                                              image: new AssetImage("assets/images/whatsapp.png"),
                                                              fit: BoxFit.fitHeight,
                                                            ))),
                                                  ),Expanded(child: Text('Contactar a Soporte',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w900,color: Colors.white),textAlign: TextAlign.center,)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Card(
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        elevation: 10,
                                        child: InkWell(
                                          onTap:() {
                                            _logout(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(20.0)),color: Color(0xFFeeeeee),),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[Text('Cerrar Sesión',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w900,color: Color(0xF0075E54)),textAlign: TextAlign.center,),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Icon(Icons.exit_to_app,color:Color(0xF0075E54)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],),
                                  ),
                                ),
                              )),
                        )
                            : Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(width:double.infinity,
                                    child:Image.asset(
                                        'assets/images/registro.png'
                                    ))
                            )
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          )),
    );
  }

  Widget errorDialog(String titulo, String boton, String descripcion) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constantes.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          //...bottom card part,
          Container(
            padding: EdgeInsets.only(
              top: Constantes.avatarRadius + Constantes.padding,
              bottom: Constantes.padding,
              left: Constantes.padding,
              right: Constantes.padding,
            ),
            margin: EdgeInsets.only(top: Constantes.avatarRadius),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(Constantes.padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 14.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          launch(
                              'https://api.whatsapp.com/send?phone=593996803139&text=Hola%20tengo%20un%20error%20al%20crear%20mi%20usuario%20en%20la%20app%20medico'); // To close the dialog
                        },
                        child: Text(
                          "Soporte",
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(
                          boton,
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //...top circlular image part,
          Positioned(
            left: Constantes.padding,
            right: Constantes.padding,
            child: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.9),
              radius: Constantes.avatarRadius,
              child: Icon(
                Icons.sentiment_neutral,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
