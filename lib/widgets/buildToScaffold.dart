import 'package:pacientes/utilities/utils_Firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pacientes/pages/login/loginPage.dart';

Widget buildAppBar(bool menu,BuildContext context) {
  return AppBar(
    backgroundColor: Color(
        0xFF064583),
    title: Text("SegMed",style: TextStyle(color: Colors.white),),
    centerTitle: true,
    actions: [
      //menu?myPopMenu(context):Container()
    ],
  );
}

Widget myPopMenu(BuildContext context) {
  return PopupMenuButton(
      onSelected: (value) {
        switch(value){
          case 2:
           /* Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AgregarUsuarioPariente()));*/
            break;
          case 3:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
            break;
        }
      },
      icon: Icon(MdiIcons.accountReactivate),
      itemBuilder: (context) => [
        PopupMenuItem(
            value: 1,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(MdiIcons.account,color: Colors.black87,),
                ),
                Text('Alejandro Salas (Yo)')
              ],
            )),
        PopupMenuItem(
            value: 2,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(MdiIcons.accountChild,color: Colors.black,),
                ),
                Text('Rosa Zambrano (Madre)')
              ],
            )),
        PopupMenuItem(
            value: 2,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(MdiIcons.accountPlus,color: Colors.blueGrey,),
                ),
                Text('Agregar usuario (Familiar)',style: TextStyle(color: Colors.blueGrey),)
              ],
            )),
        PopupMenuItem(
            value: 3,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(MdiIcons.exitToApp,color: Colors.redAccent,),
                ),
                Text('Cerrar Sesión',style: TextStyle(color: Colors.redAccent),)
              ],
            )),
      ]);
}

Drawer buildDrawer(BuildContext context){
  return Drawer(child: ListView(children: [
    DrawerHeader(decoration: BoxDecoration(color: Color(0xFF128C7E)),child: Container()),
    ListTile(onTap: (){},title: Text("Mi Cuenta"),),
    Divider(),
    ListTile(onTap: (){},title: Text("Historia Clínica"),),
    Divider(),
    ListTile(onTap: (){},title: Text("Mis Doctores"),),
    Divider(),
    ListTile(onTap: (){},title: Text("Mis Citas Médicas"),),
    Divider(),
    ListTile(onTap: (){},title: Text("Mis Medicamentos"),),
    Divider(),
    ListTile(onTap: (){
      logOut(context);
    },title: Text("Cerrar Sesión"),),
  ],),);
}


Widget buildFloatingWhastapp(String telefono, String Mensaje) {
  return FloatingActionButton(
    backgroundColor: Color(0xFF128C7E),
    onPressed: () {},
    child: Icon(MdiIcons.whatsapp,size: 35,),
  );
}