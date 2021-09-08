import 'package:pacientes/pages/tabs/chats/settingsScreen.dart';
import 'package:pacientes/widgets/appBar.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  final String documentPacienteID;

  const Settings({Key key, this.documentPacienteID}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: BuildAppBar().App_Bar(context),
      body: SettingsScreen(documentPacienteID: documentPacienteID,),
    );
  }
}
