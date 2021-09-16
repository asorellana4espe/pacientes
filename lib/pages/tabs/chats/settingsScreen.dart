import 'dart:async';
import 'dart:io';
import 'package:pacientes/pages/login/loginPage.dart';
import 'package:pacientes/pages/tabs/chats/chatSoporte.dart';
import 'package:pacientes/pages/tabs/chats/const.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class SettingsScreen extends StatefulWidget {
  final String documentPacienteID;

  const SettingsScreen({Key key, this.documentPacienteID}) : super(key: key);
  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = widget.documentPacienteID;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('pacientes')
              .document(widget.documentPacienteID)
              .updateData({'photoUrl': photoUrl}).then((data) {
            setState(() {
              isLoading = false;
            });
            Toast.show("Cargó Correctamente...", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Toast.show("Error...${err.toString()}", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Toast.show("Este archivo no es una imagen", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Toast.show("Este archivo no es una imagen", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Toast.show("Error...${err.toString()}", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Container()),
                  Icon(Icons.settings, color: Colors.blueGrey),
                  Text(
                    "Configuración de la Cuenta",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Color(0xFF064583)),
                    textAlign: TextAlign.center,
                  ),
                  Expanded(child: Container()),
                ],
              ),
              SizedBox(height: 15,),
              Padding(
                padding:
                const EdgeInsets.only(left: 12.0, right: 12.0),
                child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Center(
                              child: Text("Datos del Paciente",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF064583),
                                  )),
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: Firestore.instance
                                  .collection('pacientes')
                                  .document(widget.documentPacienteID)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data['nombre'] != null) {
                                    return Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          child: Center(
                                            child: Stack(
                                              children: <Widget>[
                                                (avatarImageFile == null)
                                                    ? (snapshot
                                                    .data[
                                                'photoUrl'] != ''
                                                    ? Material(
                                                  child: Image.asset(
                                                    "assets/images/avatar.png",
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(150.0)),
                                                  clipBehavior: Clip.hardEdge,
                                                )
                                                    : Icon(
                                                  Icons.account_circle,
                                                  size: 200.0,
                                                  color: greyColor,
                                                ))
                                                    : Material(
                                                  child: Image.file(
                                                    avatarImageFile,
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(150.0)),
                                                  clipBehavior: Clip.hardEdge,
                                                )
                                              ],
                                            ),
                                          ),
                                          width: double.infinity,
                                          margin: EdgeInsets.all(20.0),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(left:18.0,right: 18.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      "Nombre: ",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.blueGrey,
                                                        fontWeight:
                                                        FontWeight
                                                            .w700,
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Text(
                                                          "${snapshot.data['nombre'] != null ? "${snapshot.data['nombre']} ${snapshot.data['apellido']}" : ""}",
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: Color(0xFF007095),
                                                            fontWeight:
                                                            FontWeight
                                                                .w700,
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Divider(),
                                              Padding(
                                                padding: const EdgeInsets.only(left:18.0,right: 18.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <
                                                            Widget>[
                                                          Text(
                                                              "Dirección: ",
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                15,
                                                                color: Color(
                                                                    0xFF064583),
                                                                fontWeight:
                                                                FontWeight
                                                                    .w300,
                                                              )),
                                                          Text(
                                                              snapshot.data['direccion'] !=
                                                                  null
                                                                  ? snapshot.data[
                                                              'direccion']
                                                                  : "",
                                                              overflow:
                                                              TextOverflow
                                                                  .fade,
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                20,
                                                                color: Color(0xFF007095),
                                                                fontWeight:
                                                                FontWeight
                                                                    .w900,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 35,
                                                      width: 35,
                                                      child: AspectRatio(
                                                        aspectRatio: 1,
                                                        child: SvgPicture
                                                            .asset(
                                                            'assets/images/map.svg'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Divider(),
                                              Padding(
                                                padding: const EdgeInsets.only(left:18.0,right: 18.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <
                                                            Widget>[
                                                          Text(
                                                              "Ocupación: ",
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                15,
                                                                color: Color(
                                                                    0xFF064583),
                                                                fontWeight:
                                                                FontWeight
                                                                    .w300,
                                                              )),
                                                          Text(
                                                              snapshot.data['ocupacion'] !=
                                                                  null
                                                                  ? snapshot.data[
                                                              'ocupacion']
                                                                  : "",
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                20,
                                                                color: Color(0xFF007095),
                                                                fontWeight:
                                                                FontWeight
                                                                    .w900,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 30,
                                                      child: AspectRatio(
                                                        aspectRatio: 1,
                                                        child: SvgPicture
                                                            .asset(
                                                            'assets/images/work.svg'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Text(
                                      'No Registrado',
                                      style:
                                      TextStyle(color: Color(0xFF064583)),
                                    );
                                  }
                                } else {
                                  return SizedBox();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              SizedBox(height: 15,),
              Padding(
                padding:
                const EdgeInsets.only(left: 12.0, right: 12.0),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChatSoporte(documentDoctorID: widget.documentPacienteID,
                                    documentPacienteID: 'SoPoRtEtEcNiCo',
                                    doctorAvatar: "assets/images/soporte.png",
                                    nombre:
                                    "Soporte Técnico",)));
                    },
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Container(
                            width: 5,
                            height: 60,
                            color: Color(0xFF064583),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                            width: 45,
                            height: 45,
                            child: CircleAvatar(
                              backgroundColor: greyColor2,
                              backgroundImage: new AssetImage("assets/images/soporte.png"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: new Text(
                              'Contactar con Soporte Técnico',textAlign: TextAlign.center,
                              style: new TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF064583),),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Container(
                            width: 5,
                            height: 60,
                            color: Color(0xFF064583),
                          ),
                        ),
                      ],
                    ),
                  ),),
              ),
              SizedBox(height: 15,),
              Padding(
                padding:
                const EdgeInsets.only(left: 12.0, right: 12.0),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: InkWell(
                    onTap: (){_logOut(context);},
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Container(
                            width: 5,
                            height: 60,
                            color: Color(0xFFC30606),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: SvgPicture
                                  .asset(
                                  'assets/images/power.svg'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: new Text(
                              'Cerrar Sesión',textAlign: TextAlign.center,
                              style: new TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF064583),),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: Container(
                            width: 5,
                            height: 60,
                            color: Color(0xFFC30606),
                          ),
                        ),
                      ],
                    ),
                  ),),
              ),
              SizedBox(height: 15,),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),
        // Loading
        Positioned(
          child: isLoading
              ? Container(
            child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
            ),
            color: Colors.white.withOpacity(0.8),
          )
              : Container(),
        ),
      ],
    );
  }

  _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
  }
}
