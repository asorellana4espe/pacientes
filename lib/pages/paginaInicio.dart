
import 'package:pacientes/pages/tabs/chats/chats.dart';
import 'package:pacientes/pages/tabs/cuenta/cuenta.dart';
import 'package:pacientes/pages/tabs/home/home.dart';
import 'package:pacientes/widgets/appBar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
//import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';

class InicioMedico extends StatefulWidget {
  final String userID;
  final String documentPaciente;

  const InicioMedico({Key key, this.userID, this.documentPaciente}) : super(key: key);
  @override
  _InicioMedicoState createState() => _InicioMedicoState();
}

class _InicioMedicoState extends State<InicioMedico> {
  GlobalKey _bottomNavigationKey = GlobalKey();
  List<Color> coloresBottomNav=[Colors.blue,Colors.blueGrey,Colors.blueGrey];
  PageController _tabController;
  Size deviceSize;

  @override
  void initState() {
    super.initState();
    _tabController = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: BuildAppBar().App_Bar(context),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          color: Color(0xffeeeeee),
          backgroundColor: Colors.white,
          labels: <Widget>[
            Expanded(child: Text("Inicio",style: TextStyle(color: coloresBottomNav[0]),textAlign: TextAlign.center)),
            Expanded(child: Text("Chat",style: TextStyle(color: coloresBottomNav[1]),textAlign: TextAlign.center)),
            Expanded(child: Text("Mi Cuenta",style: TextStyle(color: coloresBottomNav[2]),textAlign: TextAlign.center)),
          ],
          items: <Widget>[
            Icon(Icons.home, size: 30,color: coloresBottomNav[0]),
            Icon(Icons.message, size: 30,color: coloresBottomNav[1]),
            Icon(Icons.person, size: 30,color: coloresBottomNav[2]),
          ],
          onTap: (index) {
            onTap(index);
            setState(() {
              coloresBottomNav[0]=Colors.blueGrey;
              coloresBottomNav[1]=Colors.blueGrey;
              coloresBottomNav[2]=Colors.blueGrey;
              coloresBottomNav[index]=Colors.blue;
            });
          },
        ),
        body: PageView(
              controller: _tabController,
              onPageChanged: onTabChanged,
              children: <Widget>[
                Home(documentPacienteID: widget.documentPaciente,),
                Chats(documentPacienteID: widget.documentPaciente,),
                Cuenta(documentPacienteID: widget.documentPaciente,)
              ]),
        );
  }

  void onTap(int tab) {
    _tabController.jumpToPage(tab);
  }
  void onTabChanged(int tab) {
    final CurvedNavigationBarState navBarState =
        _bottomNavigationKey.currentState;
    navBarState.setPage(tab);
  }
}
