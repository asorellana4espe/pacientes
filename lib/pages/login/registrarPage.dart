import 'package:pacientes/utilities/utils_Firebase.dart';
import 'package:pacientes/widgets/dialogWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pacientes/pages/login/loginPage.dart';
import 'package:pacientes/pages/paginaInicio.dart';
import 'package:pacientes/widgets/buildImagenes.dart';

import 'package:firebase_core/firebase_core.dart';

class RegistrarPage extends StatefulWidget {
  @override
  _RegistrarPageState createState() => _RegistrarPageState();
}

class _RegistrarPageState extends State<RegistrarPage> {
  bool _passObscure = true;
  TextEditingController _nombreText = TextEditingController();
  TextEditingController _cedulaText = TextEditingController();
  TextEditingController _correoText = TextEditingController();
  TextEditingController _telefonoText = TextEditingController();
  TextEditingController _passwordText = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: buildBoxImageDecoration(
            "fondo.jpg", BoxFit.cover, Alignment.center),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(
              
              child: Column(
                children: [
                  AspectRatio(aspectRatio: 5.5),
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                      ),
                      Expanded(
                      child: Text("SegMed Pacientes", style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),)),
                      SizedBox(
                        width: 60,
                      ),
                    ],
                  ),
                  AspectRatio(aspectRatio: 25),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: TextField(
                      controller: _nombreText,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: "Nombres y Apellidos",
                        icon: Icon(
                          MdiIcons.account,
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
                      controller: _cedulaText,
                      decoration: InputDecoration(
                        labelText: "Cédula/Pasaporte",
                        icon: Icon(
                          MdiIcons.cardAccountDetailsStarOutline,
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
                      controller: _correoText,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Correo electrónico",
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
                      controller: _telefonoText,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Teléfono",
                        icon: Icon(
                          MdiIcons.phoneDial,
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
                          icon: Icon(
                              _passObscure ? MdiIcons.eye : MdiIcons.eyeOff),
                        ),
                        labelText: "Contraseña",
                        icon: Icon(
                          MdiIcons.lockCheck,
                          color: Color(0xFF064583),
                          size: 33,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {},
                    ),
                  ),
                  AspectRatio(aspectRatio: 12),
                  AspectRatio(
                    aspectRatio: 8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: MaterialButton(
                        elevation: 10,
                        clipBehavior: Clip.antiAlias,
                        onPressed: () {
                          signUpWithEmailAndPassword(
                                    _correoText.text,
                                    _passwordText.text,
                                    _nombreText.text,
                                    _telefonoText.text,
                                    _cedulaText.text,
                                    context);
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
                                  "Registrarse",
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(),
                                ),
                                Text(
                                  "¿Ya tiene una cuenta? ",
                                ),
                                Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Color(0xFF4ABDAC),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ))),
                ],
              ),
            ),),
            SizedBox(
                height: 22,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          "  2.0.0.21",
                          style: TextStyle(
                              color: Color(0xFFCF6766),
                              fontWeight: FontWeight.w500),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    )))
          ],
        ),
      ),
    );
  }
}
