import 'package:pacientes/pages/tabs/chats/chat.dart';
import 'package:pacientes/pages/tabs/chats/chatSoporte.dart';
import 'package:pacientes/pages/tabs/chats/const.dart';
import 'package:pacientes/utils/animateDo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chats extends StatefulWidget {
  final String documentPacienteID;

  const Chats({Key key, this.documentPacienteID}) : super(key: key);
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {

  Widget _tituloChat(String group, String photo, String nombre) {

    return StreamBuilder(
      stream: Firestore.instance
          .collection('ultimoMensaje')
          .document(group)
          .collection(group)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Row(
            children: <Widget>[
              SizedBox(
                width: 100,
                height: 100,
                child: CircleAvatar(
                  backgroundColor: greyColor2,
                  backgroundImage: new NetworkImage(photo),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: new Text(
                    nombre,
                    style: new TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        } else {
          if (snapshot.data.documents.length != 0) {
            return Row(
              children: <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircleAvatar(
                    backgroundColor: greyColor2,
                    backgroundImage: new NetworkImage(photo),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            nombre,
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM kk:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(int.parse(
                                  snapshot.data.documents[0]['timestamp']))),
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        )
                      ],
                    ),
                    subtitle: new Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        children: <Widget>[
                          snapshot.data.documents[0]['enviaPac']
                              ? Icon(
                            Icons.check,
                            color: Colors.grey,
                            size: 18,
                          )
                              : Container(),
                          snapshot.data.documents[0]['type'] == 0
                              ? Container()
                              : snapshot.data.documents[0]['type'] == 1
                              ? Icon(
                            Icons.photo,
                            color: Colors.grey,
                            size: 18,
                          )
                              : Icon(
                            Icons.insert_drive_file,
                            color: Colors.grey,
                            size: 18,
                          ),
                          Expanded(
                            child: new Text(
                              snapshot.data.documents[0]['type'] == 0
                                  ? " ${snapshot.data.documents[0]['content']}"
                                  : snapshot.data.documents[0]['type'] == 1
                                  ? " Foto"
                                  : " Sticker",
                              style: new TextStyle(
                                  color: Colors.grey, fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircleAvatar(
                    backgroundColor: greyColor2,
                    backgroundImage: new NetworkImage(photo),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: new Text(
                      nombre,
                      style: new TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }
        }
      },
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('doctores')
          .document(document['doctor'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          String groupChatId =
              '${widget.documentPacienteID}-${document['doctor']}';
          return Column(
            children: <Widget>[
              FlatButton(
                child: _tituloChat(groupChatId, snapshot.data['photoUrl'],
                    "${snapshot.data['nombre']}"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                            documentDoctorID: document['doctor'],
                            documentPacienteID: widget.documentPacienteID,
                            doctorAvatar: snapshot.data['photoUrl'],
                            nombre:
                            "${snapshot.data['nombre']}",
                            especialidad: "${snapshot.data['Especialidad']}",
                          )));
                },
                padding: EdgeInsets.only(left: 25.0, right: 25.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              Divider(),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(),
        FlatButton(
          padding: EdgeInsets.only(left: 0.0, right: 0.0),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatSoporte(
                      documentDoctorID: widget.documentPacienteID,
                      documentPacienteID: 'SoPoRtEtEcNiCo',
                      doctorAvatar: "assets/images/soporte.png",
                      nombre:
                      "Soporte Técnico",
                    )));
          },
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  width: 15,
                  height: 60,
                  color: Color(0xFF064583),
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: CircleAvatar(
                  backgroundColor: greyColor2,
                  backgroundImage: new AssetImage("assets/images/soporte.png"),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: new Text(
                    'Contactar con Soporte Técnico',
                    style: new TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Container(
                  width: 15,
                  height: 60,
                  color: Color(0xFF064583),
                ),
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('pacienteDoctor')
                .where('paciente', isEqualTo: widget.documentPacienteID)
                .where('chat', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    Dance(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                  height: double.infinity,
                                  child: Image.asset(
                                      'assets/images/registroChat.png')))),
                    ),
                  ],
                );
              } else {
                if (snapshot.data.documents.length != 0) {
                  return ListView.builder(
                    itemBuilder: (context, index) =>
                        buildItem(context, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      Dance(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 15,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: double.infinity,
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.sentiment_dissatisfied),
                                    Text(
                                      'No tiene Doctores asignados para chat',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                    height: double.infinity,
                                    child: Image.asset(
                                        'assets/images/registroChat.png')))),
                      ),
                    ],
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
