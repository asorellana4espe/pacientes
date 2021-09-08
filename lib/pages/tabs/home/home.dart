import 'package:pacientes/utils/animateDo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Home extends StatefulWidget {
  final String documentPacienteID;

  const Home({Key key, this.documentPacienteID}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Size deviceSize;
  String tokenPaciente="";
  List<String> unidad = [
    "mg",
    "g",
    "mg",
    "ml",
    "puff(s)",
    "tab (s)",
    "UI"
  ];
  List<String> dias=["Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"];
  List<String> meses=["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];

  Widget _buildMedicamento(DocumentSnapshot doc){
    double por=0;
    int porcentaje=0;
    int porcentajeTotal=((doc['tomado']/(doc['total']))*100).toInt();
    if(doc['tomado']+doc['omitido']!=0){
      por = (doc['tomado']/(doc['tomado']+doc['omitido']))*100;
      porcentaje=por.toInt();
    }
    return BounceInUp(
      child: Padding(
        padding: const EdgeInsets.only(bottom:8.0,left:8.0,right: 8.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 15,
          child: InkWell(
            onTap: (){

            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("${doc['nombre']} (${doc['dosis']} ${unidad[doc['unidad']]})",style: TextStyle(color: Color(0xFF064583),fontSize: 17,fontWeight: FontWeight.bold),)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("$porcentaje%",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20,color: porcentaje>90?Color(0xff34C50C):porcentaje>85?Color(0xffC5BF0C):Color(0xffCA0000))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Total: ",style: TextStyle(color:Colors.blueGrey,fontWeight: FontWeight.w700,fontSize: 10)),
                                  Text("${doc['tomado']}/${doc['total']}",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 12,color:Color(0xFF007095))),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
    StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance
        .collection('medicamentos')
        .document(doc.documentID)
        .collection('notificaciones')
        .where('timestamp',
        isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .orderBy('timestamp', descending: false)
        .snapshots(),
    //.where('timestamp', isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)

    builder: (context, snapshot) {
    if (snapshot.hasData) {
      if(snapshot.data.documents.length!=0){

        return Column(children: snapshot.data.documents.map((item){
          if(!item['notificado']){
            print("Tiempo que ha pasado: ${DateTime.fromMillisecondsSinceEpoch(item['timestamp']).difference(DateTime.now()).inMinutes-300} minutos del ${item.documentID} fecha1: ${DateTime.fromMillisecondsSinceEpoch(item['timestamp'])}  fecha2: ${DateTime.now()}");
            if(DateTime.fromMillisecondsSinceEpoch(item['timestamp']).difference(DateTime.now()).inMinutes+300<-60){
              Firestore.instance
                  .collection('medicamentos')
                  .document(doc.documentID)
                  .collection('notificaciones').document(item.documentID).updateData({
                'notificado':true,
                'tomado':false
              });
            }
            return
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(width: 10,),
                Expanded(child: Text("${item['fecha']} ${item['hora']}",
                  style: TextStyle(
                    fontSize: 14,
                    color:Color(0xFF064583),
                    fontWeight: FontWeight.w900,
                  ),textAlign: TextAlign.center,),),
                Padding(
                  padding: const EdgeInsets.only(right:5.0),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 15,
                    color: Color(0xffCA0000).withOpacity(0.6),
                    child: InkWell(
                      onTap: () {
                        if(doc['tomado']+doc['omitido']!=doc['total']){
                          int omitido=doc['omitido'];
                          Firestore.instance
                              .collection("medicamentos")
                              .document(doc.documentID)
                              .updateData({'omitido': omitido+1});
                          Firestore.instance
                              .collection('medicamentos')
                              .document(doc.documentID)
                              .collection('notificaciones').document(item.documentID).updateData({
                            'notificado':true,
                            'tomado':false
                          });
                        }else{

                          Toast.show("Tratamiento Completado...", context,
                              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top:8.0,bottom: 8.0,left: 8.0,right: 8.0),
                        child: Text('Omitir',style: TextStyle(color:Colors.white),),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right:5.0),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 15,
                    color: Color(0xff34C50C).withOpacity(0.6),
                    child: InkWell(
                      onTap: () {
                        int tomado=doc['tomado'];
                        if(doc['tomado']+doc['omitido']<doc['total']){
                          if(doc['tomado']==0 && !doc['retiradoFarmacia']){
                            Firestore.instance
                                .collection("medicamentos")
                                .document(doc.documentID)
                                .updateData({'retiradoFarmacia': true,
                              'fechaRetiro':DateTime.now().millisecondsSinceEpoch.toString(),'tomado': tomado+1});
                            Firestore.instance
                                .collection('medicamentos')
                                .document(doc.documentID)
                                .collection('notificaciones').document(item.documentID).updateData({
                              'notificado':true,
                              'tomado':true
                            });
                          }else{
                            Firestore.instance
                                .collection('medicamentos')
                                .document(doc.documentID)
                                .collection('notificaciones').document(item.documentID).updateData({
                              'notificado':true,
                              'tomado':true
                            });
                            Firestore.instance
                                .collection("medicamentos")
                                .document(doc.documentID)
                                .updateData({'tomado': tomado+1});}}else{

                          Toast.show("Tratamiento Completado...", context,
                              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top:8.0,bottom: 8.0,left: 8.0,right: 8.0),
                        child: Text('Tomar',style: TextStyle(color:Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            );}else{return Container();}
        }).toList(),);
      }else{
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text("Has registrado todas las dosis programadas hasta el momento"),
        );
      }
    }else{
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text("Has registrado todas las dosis programadas"),
      );
    }}),
                      doc['alimentos']!=null?!doc['alimentos']?Container():Row(
                        children: <Widget>[
                          Icon(Icons.restaurant,color:Colors.red,size:15),
                          Text(" Recuerde Tomar con los Alimentos")
                        ],
                      ):Container()
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Container(
      child: Padding(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('pacientes')
                    .document(widget.documentPacienteID)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data['token'] != null) {
                      tokenPaciente=snapshot.data['token'];
                      return Container();
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                },
              ),
              Text("Medicamentos Programados",
                  style: TextStyle(
                    fontSize: 22,
                    color:Color(0xFF064583),
                    fontWeight: FontWeight.w900,
                  ),textAlign: TextAlign.center,),
        StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('medicamentos').where('paciente',isEqualTo:widget.documentPacienteID).where('estado',isEqualTo:true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if(snapshot.data.documents.length!=0){
                return Column(children: snapshot.data.documents.map((doc) => _buildMedicamento(doc)).toList());}else{
                return Dance(
                  child: Padding(
                    padding: const EdgeInsets.only(left:18.0,right:18.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 15,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.sentiment_dissatisfied),
                            Text(
                              'No tiene Medicamentos programados',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            } else {
              return Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(child: CircularProgressIndicator(),),
              );
            }
          },
        ),Divider(),
              Text("Próximas Citas Médicas",textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color:Color(0xFF064583),
                    fontWeight: FontWeight.w900,
                  )),

              StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('citas').where('paciente',isEqualTo:widget.documentPacienteID).where('estado',isEqualTo: 'Pendiente').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if(snapshot.data.documents.length!=0){
                      return Column(children: snapshot.data.documents.map((doc) => _buildCita(doc)).toList());}else{
                      return Dance(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 15,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.sentiment_dissatisfied),
                                  Text(
                                    'No tiene Citas programadas',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(child: CircularProgressIndicator(),),
                    );
                  }
                },
              ),
            ],
          )),
    );
  }


  Widget _buildCita(DocumentSnapshot doc){
    DateTime fecha=DateTime.parse("${doc.data['fecha']} ${doc.data['hora']}:00.000");
    String fechaText="${dias[fecha.weekday-1]}, ${fecha.day} de ${meses[fecha.month-1]} de ${fecha.year}";
    return BounceInUp(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 15,
          child: InkWell(
            onTap: (){},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    fechaText,
                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color:Color(0xFF007095)),
                  ),
                  Row(
                    children: <Widget>[Expanded(child:StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance.collection('doctores').document(doc.data['doctor']).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if(snapshot.data['Especialidad']!=null){
                            return Text(snapshot.data['Especialidad'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400));}else{return Text('No Registrado',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),);}
                        } else {
                          return SizedBox();
                        }
                      },
                    ),),
                      Text(
                        tiempo(fecha),
                        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color:DateTime.now().difference(fecha).inSeconds<0?Colors.green:Colors.red),
                      ),
                    ],
                  ),
                  StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance.collection('doctores').document(doc.data['doctor']).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if(snapshot.data['nombre']!=null){
                            return Text(snapshot.data['nombre'],style: TextStyle(color: Color(0xFF064583),fontSize: 20,fontWeight: FontWeight.bold),);}else{return Text('No Registrado',style: TextStyle(color: Color(0xFF064583)),);}
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  doc.data["observacion"]!=null?doc.data["observacion"].length!=0?Text(
                    'Observación:',
                    style: TextStyle(fontSize: 12,color:Colors.blueGrey,fontWeight: FontWeight.bold),
                  ):Container():Container(),
                  doc.data["observacion"]!=null?doc.data["observacion"].length!=0?Text(
                    doc.data["observacion"],
                    style: TextStyle(fontSize: 15,color:Color(0xFF007095)),
                  ):Container():Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String tiempo(DateTime newDateTime) {
    String hora, minuto;
    if (newDateTime.hour < 10) {
      hora = "0${newDateTime.hour.toString()}";
    } else {
      hora = "${newDateTime.hour.toString()}";
    }
    if (newDateTime.minute < 10) {
      minuto = "0${newDateTime.minute.toString()}";
    } else {
      minuto = "${newDateTime.minute.toString()}";
    }
    return "$hora:$minuto";
  }

}
