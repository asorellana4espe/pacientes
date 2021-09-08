import 'package:pacientes/pages/tabs/chats/settingsScreen.dart';
import 'package:flutter/material.dart';

class Cuenta extends StatelessWidget {
  final String documentPacienteID;

  const Cuenta({Key key, this.documentPacienteID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(documentPacienteID: documentPacienteID,);
  }
}
