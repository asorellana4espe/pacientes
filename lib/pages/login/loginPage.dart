import 'package:pacientes/pages/usuario/usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:pacientes/pages/login/utils/PinInput.dart';
import 'package:pacientes/pages/login/utils/gradient_button.dart';
import 'package:pacientes/pages/login/utils/login_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pacientes/utils/animateDo.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  Size deviceSize;
  bool telefonoCorrecto = false;
  bool checkPolitica=true;
  String phoneNo,smsCode;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  /// Control the input text field.
  TextEditingController _pinEditingController = TextEditingController();

  /// Decorate the outside of the Pin.
  PinDecoration _pinDecoration =
  UnderlineDecoration(enteredColor: Colors.black, hintText: 'XXXXXX');

  Future<void> verifyPhone() async {
    phoneNo="+593${int.parse(phoneNo)}";
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
     // smsOTPDialog(context).then((value) {
       // print('No sea Sapo');
      //});
      setState(() {
        telefonoCorrecto=true;
      });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo, // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent:
          smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException exceptio) {
            print('${exceptio.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }


  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: _pinEditingController.text,
      );
      await _auth.signInWithCredential(credential);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(currentUser.uid == currentUser.uid);
      Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoginPage(
              )),
              (Route<dynamic> route) => false);
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }


  @override
  void initState() {
    super.initState();
    _comprobarUsuarioFb();
  }

  void _comprobarUsuarioFb() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _user = user;
    });
  }


  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return _user==null?Scaffold(
        key: scaffoldState,
        backgroundColor: Color(0xffeeeeee),
        body: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            LoginBackground(showIcon: false,image: "assets/images/icono.png",),
            Center(
              child: BounceInUp(
                child: SingleChildScrollView(
                  child: Opacity(
                    opacity: 0.85,
                    child: SizedBox(
                      height: deviceSize.height / 2 - 20,
                      width: deviceSize.width * 0.85,
                      child: new Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          color: Colors.white,
                          elevation: 5.0,
                          child: Center(
                            child: Form(
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: SingleChildScrollView(
                                  child: new Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text("Iniciar Sesión",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w900)),
                                      Row(
                                        children: <Widget>[
                                          Text("🇪🇨 +593  ",
                                              style: TextStyle(fontSize: 19)),
                                          Expanded(
                                            child: TextField(
                                              onChanged: (phone) =>
                                                  phoneNo = phone,
                                              keyboardType: TextInputType.phone,
                                              enabled: !telefonoCorrecto,
                                              style: new TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.black),
                                              decoration: new InputDecoration(
                                                  hintText: "",
                                                  labelText: "Número de Celular",
                                                  labelStyle: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.blue)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      new SizedBox(
                                        height: 10.0,
                                      ),
                                      new SizedBox(
                                        height: 10.0,
                                      ),
                                      !telefonoCorrecto
                                          ? new Row(
                                              children: <Widget>[
                                                Checkbox(
                                                  value: checkPolitica,
                                                    onChanged: (bool newValue) {
                                                      setState(() {
                                                        checkPolitica = newValue;
                                                        if(!newValue){

                                                          Toast.show("Por Favor acepte los términos condiciones para continuar", context,
                                                              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                                                        }
                                                      });
                                                    }
                                                ),
                                                Expanded(
                                                    child: Text(
                                                  "Acepto los Términos y Condiciones y la Politica de Privacidad.",
                                                  overflow: TextOverflow.fade,
                                                ))
                                              ],
                                            )
                                          : BounceInLeft(
                                            child: Column(
                                              children: <Widget>[
                                                Text("Ingrese el codigo de 6 digitos recibido vía SMS"),
                                                PinInputTextField(
                                                  pinLength: 6,
                                                  decoration: _pinDecoration,
                                                  controller: _pinEditingController,
                                                  autoFocus: true,
                                                  textInputAction: TextInputAction.done,
                                                  onSubmit: (pin) {
                                                    if (pin.length == 6) {
                                                      print("El pin es: $pin");
                                                    } else {
                                                      print("Codigo invalido");
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                      new SizedBox(
                                        height: 30.0,
                                      ),
                                      Container(
                                        child: !telefonoCorrecto
                                            ? checkPolitica?GradientButton(
                                                onPressed: () {
                                                  if (phoneNo.length == 10) {
                                                    verifyPhone();
                                                  } else {
                                                    print(
                                                        "Error numero no tiene 10 digitos");
                                                  }
                                                },
                                                text: "Solicitar código SMS"):Container()
                                            : new GradientButton(
                                                onPressed: () {
                                                  setState(() {
                                                    smsCode=_pinEditingController.text;
                                                  });
                                                  if(smsCode.length == 6){
                                                    _auth.currentUser().then((user) {
                                                      if (user != null) {
                                                        print("hola: ${user.phoneNumber} uid: ${user.uid}");
                                                      } else {
                                                        signIn();
                                                      }
                                                    });}
                                                      else{ print(
                                                          "Error sms no tiene 6 digitos");}
                                                },
                                                text: "Ingresar"),
                                      ),
                                      telefonoCorrecto
                                          ? new FlatButton(
                                              child: Text("Reenviar SMS"),
                                              onPressed: () {
                                                setState(() {
                                                  telefonoCorrecto = false;
                                                });
                                              },
                                            )
                                          : new Container()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            )
          ],
        )):Usuario(usuarioUID: _user.uid,);
  }
}
