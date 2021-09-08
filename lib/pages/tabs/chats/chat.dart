import 'dart:async';
import 'dart:io';

import 'package:pacientes/pages/tabs/chats/const.dart';
import 'package:pacientes/pages/tabs/chats/fullPhoto.dart';
import 'package:pacientes/pages/tabs/chats/settings.dart';
import 'package:pacientes/utils/triangleClipper.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class Chat extends StatelessWidget {
  final String documentDoctorID;
  final String doctorAvatar;
  final String documentPacienteID;
  final String nombre;
  final String especialidad;

  Chat({Key key,this.documentDoctorID, this.doctorAvatar, this.documentPacienteID, this.nombre, this.especialidad}) : super(key: key);


  List<Choice> choices = const <Choice>[
    const Choice(title: 'Configuración', icon: Icons.settings),
  ];
  BuildContext context1;
  void onItemMenuPress(Choice choice) {
    if (choice.title != 'Log out') {
      Navigator.push(context1, MaterialPageRoute(builder: (context) => Settings(documentPacienteID: documentPacienteID,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    context1=context;
    return new Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(doctorAvatar),
          ),
          title: Text(
            nombre,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          subtitle: Text(
            especialidad,
            style: TextStyle(color: Colors.white.withOpacity(.7)),
          ),
        ),
        flexibleSpace: Container(
          color: Color(0xFF064583),
        ),
        centerTitle: true,
        actions: <Widget>[
      PopupMenuButton<Choice>(
      onSelected: onItemMenuPress,
        itemBuilder: (BuildContext context) {
          return choices.map((Choice choice) {
            return PopupMenuItem<Choice>(
                value: choice,
                child: Row(
                  children: <Widget>[
                    Icon(
                      choice.icon,
                      color: primaryColor,
                    ),
                    Container(
                      width: 10.0,
                    ),
                    Text(
                      choice.title,
                      style: TextStyle(color: primaryColor),
                    ),
                  ],
                ));
          }).toList();
        },
      ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter:ColorFilter.mode(Colors.white.withOpacity(0.25),
                BlendMode.dstATop),
            image: AssetImage("assets/images/backFondo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: new ChatScreen(
          peerId: documentDoctorID,
          peerAvatar: doctorAvatar,
          peerActual:documentPacienteID
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerActual;

  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar, this.peerActual}) : super(key: key);

  @override
  State createState() => new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

  String peerId;
  String peerAvatar;
  String id;

  var listMessage;
  String groupChatId;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '${widget.peerActual}-${widget.peerId}';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Toast.show("Este archivo no es una imagen", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    });
  }

  Future<void> onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      ultimoMensaje(content,type);

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': widget.peerActual,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
            'visto':false
          },
        );
      });

      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Toast.show("Nada que enviar", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    }
  }

  Future<void> ultimoMensaje(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {

      try{
        await Firestore.instance
            .collection('ultimoMensaje')
            .document(groupChatId)
            .collection(groupChatId)
            .document(groupChatId).updateData(
          {
            'enviaPac': true,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
          },
        );
      }catch(e){
        var documentReference = Firestore.instance
            .collection('ultimoMensaje')
            .document(groupChatId)
            .collection(groupChatId)
            .document(groupChatId);

        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            documentReference,
              {
                'enviaPac': true,
                'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                'content': content,
                'type': type,
              },
          );
        });
      }

    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == widget.peerActual) {
      // Right (my message)
      return Padding(
        padding: const EdgeInsets.only(bottom:10.0),
        child: Row(
          children: <Widget>[
            document['type'] == 0
            // Text
                ?  Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right:7,
                  top: 0,
                  child: ClipPath(
                    clipper: TriangleClipper(),
                    child: Container(
                      height: 20,
                      width: 30,
                      color: greyColor2,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12,vertical: 0),
                  margin: EdgeInsets.symmetric(horizontal: 21,vertical: 0),
                  decoration: BoxDecoration(
                    color: greyColor2,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top:3.0,bottom: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            constraints: BoxConstraints(minWidth: 70, maxWidth: MediaQuery.of(context).size.width-100),
                            child: Text(document['content'],style: TextStyle(fontSize: 17,color:primaryColor))),
                        Text(DateFormat('dd MMM kk:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),style: TextStyle(fontSize: 12,color: Colors.grey),),
                      ],
                    ),
                  ),
                ),
              ],
            )
                : document['type'] == 1
            // Image
                ? Container(
              child: FlatButton(
                child: Material(
                  elevation: 6,
                  shadowColor: Colors.blueGrey,

                  child: Image.network( document['content'],
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
                },
                padding: EdgeInsets.all(0),
              ),
              margin: EdgeInsets.only(right: 10.0),
            )
            // Sticker
                : Container(
              child: new Image.asset(
                'assets/images/${document['content']}.gif',
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
              margin: EdgeInsets.only(right: 10.0),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      );
    } else {
      if (!document['visto']) {
        Firestore.instance
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .document(document.documentID)
            .updateData(
          {
            'visto': true,
            'fechaVisto': DateTime.now().millisecondsSinceEpoch.toString()
          },
        );
      }
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                document['type'] == 0
                    ? Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Positioned(
                      left:7,
                      top: 0,
                      child: ClipPath(
                        clipper: TriangleClipper(),
                        child: Container(
                          height: 20,
                          width: 30,
                          color: Color(0xFF82BFFE),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 0),
                      margin: EdgeInsets.symmetric(horizontal: 21,vertical: 0),
                      decoration: BoxDecoration(
                        color: Color(0xFF82BFFE),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top:3.0,bottom: 3.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                constraints: BoxConstraints(minWidth: 0, maxWidth: MediaQuery.of(context).size.width-100),
                                child: Text(document['content'],style: TextStyle(fontSize: 17,color: primaryColor))),
                            Text(DateFormat('dd MMM kk:mm')
                                .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),style: TextStyle(fontSize: 12,color: Colors.white),),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : document['type'] == 1
                    ? Container(
                  child: FlatButton(
                    child: Material(
                      elevation: 6,
                      shadowColor: Colors.blueGrey,
                      child: Image.network( document['content'],
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
                    },
                    padding: EdgeInsets.all(0),
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                )
                    : Container(
                  child: new Image.asset(
                    'assets/images/${document['content']}.gif',
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(bottom: 10.0, left: 10.0),
                ),
              ],
            ),

          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] == id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] != id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {

      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Sticker
              (isShowSticker ? buildSticker() : Container()),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: new Image.asset(
                  'assets/images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: new Image.asset(
                  'assets/images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: new Image.asset(
                  'assets/images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: new Image.asset(
                  'assets/images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: new Image.asset(
                  'assets/images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: new Image.asset(
                  'assets/images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: new Image.asset(
                  'assets/images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: new Image.asset(
                  'assets/images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: new Image.asset(
                  'assets/images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
        child: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
        ),
        color: Colors.white.withOpacity(0.8),
      )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                padding: const EdgeInsets.all(2.0),
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                padding: const EdgeInsets.all(2.0),
                icon: new Icon(Icons.sentiment_satisfied),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Escriba su mensaje...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () {
                  String mensaje=textEditingController.text;
                  onSendMessage(mensaje, 0);
                },
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
        stream: Firestore.instance
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }
}
class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}