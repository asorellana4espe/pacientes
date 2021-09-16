
import 'package:pacientes/pages/login/loginPage.dart';
import 'package:pacientes/utilities/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:firebase_core/firebase_core.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//Funcion que usar Firebase Auth para enviar un link de reseteo de Password al correo electrónico del usuario
resetPassword(BuildContext context,String email) async {
  try {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
    Toast.show("Revise su correo y siga el link para recuperar su contraseña", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  } catch (e) {
    Toast.show("Error al recuperar contraseña, intente nuevamente", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }
}


logOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => LoginPage()));
}

dialogResetPassword(BuildContext context1){

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
                      Text("Recuperar Contraseña",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w800,color: Color(
                          0xFF064583)),),
                      SizedBox(height: 15,),
                      Text("Por favor ingrese su correo electrónico",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
                      SizedBox(height: 10,),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: TextField(
                          controller: _mailText,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                            onPressed: (){
                              resetPassword(context1,_mailText.text);
                              Navigator.of(context).pop();
                              FocusScope.of(context).requestFocus(new FocusNode());
                            },

                            child: Text("Recuperar",style: TextStyle(fontSize: 18),)),
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
                        child: Image.asset("assets/img/conectabotTransparente.png",fit: BoxFit.contain,)
                    ),
                  ),
                ),
              ],
            ));
      }
  );
}

//Funcion que realiza la creacion del usuario en Firebase y devuelve el uuid previo a registrar el usuario en la base de datos
signUpWithEmailAndPassword(
    String email,
    String password,
    String nombre,
    String telefono,
    String cedula,BuildContext context) async {
  try {
    AuthResult result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(), password: password);
    //Registrar el usuario en la base de datos
    _registrarUsuario(nombre, telefono,
        email.trim().toLowerCase(), result.user.uid, cedula, '',context,password);
  } catch (e) {
    //print('Error: $e');
  }
}

_registrarUsuario(String nombre, String telefono, String correo,
    String uid, String cedula, String token,BuildContext context,String password) async {


  await _signInWithEmail(correo, password,context);
  /*DocumentReference ref =
  await Firestore.instance.collection('usuarios').add({
    'nombre': nombre,
    'telefono': telefono,
    'correo': correo,
    'uid': uid,
    'token': token,
    'photoUrl':"https://www.itdaviciscotechnology.com/wp-content/uploads/2020/05/cropped-logo-intro-1.png"
  });
  if (ref != null) {
  }*/
}

Future<bool> _signInWithEmail(String email,
    String password, BuildContext context) async {
  try {
    AuthResult result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
        email: email.trim().toLowerCase(), password: password);
    print('Signed in: ${result.user.uid}');
    if(result.user.uid.length > 0) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    Toast.show("Bienvenido", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    return true;}
  } catch (e) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    Toast.show("Registrado Correctamente, por favor inicie sesión", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    return false;
  }
}