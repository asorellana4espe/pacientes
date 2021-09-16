import 'package:pacientes/pages/usuario/usuario.dart';
import 'package:pacientes/utilities/data.dart';
import 'package:pacientes/utilities/utils_Firebase.dart';
import 'package:pacientes/widgets/dialogWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pacientes/pages/login/registrarPage.dart';
import 'package:pacientes/pages/paginaInicio.dart';
import 'package:pacientes/widgets/buildImagenes.dart';
import 'package:pacientes/widgets/buildToScaffold.dart';
import 'package:toast/toast.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passObscure = true;
  TextEditingController _cedulaText= TextEditingController();
  TextEditingController _passwordText= TextEditingController();
  FirebaseUser _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _comprobarUsuarioFb();
  }

  //Determinar si el usuario esta registrado o no previamente
  void _comprobarUsuarioFb() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _user = user;
    });
  }

  Future<bool> _signInWithEmail(String email,
      String password) async {
    try {
      AuthResult result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email.trim().toLowerCase(), password: password);
      print('Signed in: ${result.user.uid}');
      _comprobarUsuarioFb();
      return true;
    } catch (e) {
      dialogCustom(context,"Error","Datos incorrectos por favor revise e intente ingresar nuevamente",0);
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return _user==null?Scaffold(
      floatingActionButton: buildFloatingWhastapp("",""),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: buildBoxImageDecoration(
            "fondo.jpg", BoxFit.cover, Alignment.center),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child:
            Column(children: [
              AspectRatio(aspectRatio: 3.5),
              Row(
                children: [
                  SizedBox(
                    width: 50,
                  ),
                  Expanded(
                      child: Text("SegMed Pacientes", style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),)),
                  SizedBox(
                    width: 50,
                  ),
                ],
              ),
              AspectRatio(aspectRatio: 8),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: TextField(
                  controller: _cedulaText,
                  decoration: InputDecoration(
                    labelText: "Correo",
                    icon: Icon(
                      MdiIcons.emailMultipleOutline,
                      color: Color(0xFF064583),
                      size: 33,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: TextField(
                  controller: _passwordText,
                  obscureText: _passObscure,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passObscure = !_passObscure;
                        });
                      },
                      icon: Icon(_passObscure ? MdiIcons.eye : MdiIcons.eyeOff),
                    ),
                    labelText: "Contraseña",

                    icon: Icon(
                      MdiIcons.lockCheck,
                      color: Color(0xFF064583),
                      size: 33,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value){},
                ),
              ),
              AspectRatio(aspectRatio: 10),
              AspectRatio(
                aspectRatio: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: MaterialButton(
                    clipBehavior: Clip.antiAlias,
                    onPressed: () {
                      _signInWithEmail(_cedulaText.text,_passwordText.text);
                    },
                    shape: StadiumBorder(),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4ABDAC), Color(0xff064583)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              "Ingresar",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      dialogResetPassword(context);
                    },
                    child: Text(
                      "¿Ha olvidado su contraseña?",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              AspectRatio(aspectRatio: 18,),
              Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrarPage()));
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            Text(
                              "¿No tiene una cuenta? ",
                              
                            ),
                            Text(
                              "Registrarse",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF4ABDAC),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ))),
            ],)),),
            SizedBox(height: 20,child:Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      "  2.0.9.21",
                      style: TextStyle(color: Color(0xFFCF6766),fontWeight: FontWeight.w500
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                )))
          ],
        ),
      ),
    ):Usuario(usuarioUID: _user.uid,);
  }
}