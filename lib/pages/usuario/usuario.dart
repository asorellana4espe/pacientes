
import 'package:pacientes/pages/login/loginPage.dart';
import 'package:pacientes/pages/paginaInicio.dart';
import 'package:pacientes/utils/animateDo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pacientes/pages/login/utils/login_background.dart';
import 'package:pacientes/pages/usuario/nuevoUsuario.dart';
import 'package:pacientes/utils/pushNotifications.dart';
import 'package:url_launcher/url_launcher.dart';

class Usuario extends StatefulWidget {
  final String usuarioUID;

  const Usuario({Key key, this.usuarioUID}) : super(key: key);
  @override
  _UsuarioState createState() => _UsuarioState();
}

class _UsuarioState extends State<Usuario> {
  Size deviceSize;
  PushNotifications pushN;

  final db = Firestore.instance;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pushN=new PushNotifications();
    pushN.initConfigurations();
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('pacientes').where('uid',isEqualTo:widget.usuarioUID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents.length == 0) {
            return NuevoUsuario(usuarioUID: widget.usuarioUID,);
          } else {
            return snapshot.data.documents[0].data['activo']!=null?!snapshot.data.documents[0].data['activo']?Scaffold(
                backgroundColor: Color(0xffeeeeee),
                body: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    LoginBackground(showIcon: false,image: "assets/images/icono.png",),
                    Center(child: SingleChildScrollView(
                      child: Opacity(
                        opacity: 0.85,
                        child: SizedBox(
                          height: deviceSize.height / 2 - 20,
                          width: deviceSize.width * 0.85,
                          child: BounceInUp(
                            child: new Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                                color: Colors.white,
                                elevation: 5.0,
                                child: SizedBox(
                                  height: deviceSize.height / 2 - 20,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: ListView(children: <Widget>[
                                        Text("App Medicina",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
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
                          ),
                        ),
                      ),
                    ),)
                  ],
                )):InicioMedico(userID: widget.usuarioUID,documentPaciente: snapshot.data.documents[0].documentID,):NuevoUsuario(usuarioUID: widget.usuarioUID,);
          }
        } else {
          return Scaffold(
              backgroundColor: Color(0xffeeeeee),
              body: Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  LoginBackground(showIcon: false,image: "assets/images/icono.png",),
                  Center(child: CircularProgressIndicator(),)
                ],
              ));
        }
      },
    );
  }
  _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoginPage(

            )),
            (Route<dynamic> route) => false);
  }
}
