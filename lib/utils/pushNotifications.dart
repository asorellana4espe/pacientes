import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotifications{
  FirebaseMessaging _firebaseMessaging=FirebaseMessaging();

  final _mensajesStreamController=StreamController<String>.broadcast();
  Stream<String> get mensajes=>_mensajesStreamController.stream;

   Future<String> initNotifications() async {
    String fcm="";
    _firebaseMessaging.requestNotificationPermissions();
    await _firebaseMessaging.getToken().then((token){
      fcm=token;
    });

    return fcm;
  }

  initConfigurations(){
    FirebaseMessaging _firebaseMessaging=FirebaseMessaging();
    _firebaseMessaging.configure(
        onMessage: (info){
          print('=== On Message ===');
          print(info);
        },
        onLaunch: (info){
          print('=== On Launch ===');
          print(info);
        },
        onResume: (info){
          print('=== On Resume ===');
          print(info);
        }
    );
  }
}