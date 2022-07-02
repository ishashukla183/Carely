//@dart=2.9

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'AddFaces.dart';
import 'ContactsScreen.dart';
import 'FaceRecognition.dart';
import 'Medicine.dart';
import 'MedicineList.dart';
import 'notification_api.dart';



File medicineFile;
List<Medicine> medicines = <Medicine>[];
loadMedicineFile() async {

  var tempDir = await getApplicationDocumentsDirectory();
  medicineFile = File(tempDir.path + '/medicines.json');


    if (medicineFile.existsSync()){
      var jsonBody = json.decode(medicineFile.readAsStringSync());
      for(var data in jsonBody) {

        medicines.add(Medicine(name : data['name'], dose: data['dose'], time: TimeOfDay( hour : int.parse(data['time'].toString().substring(10,12)), minute: int.parse(data['time'].toString().substring(13,15))), color: Color(int.parse(data['color'].split('(0x')[1].split(')')[0], radix: 16) + 0xFF000000), isChecked: (data['isChecked'] == 'true'),));
      }
      if (kDebugMode) {
        print(json.decode(medicineFile.readAsStringSync()).toList());
      }

    }


  for(int index=0; index<medicines.length; index+=1) {
    if (kDebugMode) {
      print('scheduling task..' + index.toString());
    }
    await NotificationAPI.showNotifications(id: index,
        title: medicines[index].name,
        body: medicines[index].dose + 'pills',
        payload: ' ',
        scheduledDate: DateTime(DateTime
            .now().year, DateTime.now().month, medicines[index].time.hour - 5 ,
            medicines[index].time.minute), time:  TimeOfDay(hour: medicines[index].time.hour , minute: medicines[index].time.minute ) );
    if (kDebugMode) {
      print("name = " + medicines[index].name + " date : " + DateTime(DateTime
        .now()
        .year, DateTime
        .now()
        .month, medicines[index].time.hour,
        medicines[index].time.minute).toString() +  " time: " +  medicines[index].time.toString());
    }

  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationAPI.init();
  loadMedicineFile();

  runApp(MaterialApp(
      debugShowCheckedModeBanner : false,
    theme: ThemeData(
      //primarySwatch: Colors.lightBlue[900],
      visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Montserrat',

    ),
    home: const HomeScreen(),
  ),
  );
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor : Colors.transparent));
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60.0, left: 30.0, bottom: 30.0, right: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               CircleAvatar(
                  child: Image.asset('images/Carely.png',
                  height: 70,),
                 backgroundColor: Colors.white,
                 radius: 50.0,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text("Carely",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50.0,
                    fontWeight: FontWeight.w700,
                  ),),
                SizedBox(
                  height: 10.0,
                ),],),),

                Expanded(
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),

                      )
                  ),
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric( vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                                color: Color(0xffFB90B7),
                                borderRadius: BorderRadius.all(
Radius.circular(20),
                                )
                            ),

                            child: ListTile(
                              leading: const Icon(CupertinoIcons.person_alt,
                              size: 40,),
                              title: Text('Face Recognition',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const FaceRecognition()));
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                                color: Color(0xffD18CE0),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                )
                            ),

                            child: ListTile(
                              leading: const Icon(CupertinoIcons.person_2_fill,
                              size: 40,),
                                title: Text('Edit Saved Faces',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 27.0,
                                    fontWeight: FontWeight.bold,

                                  ),
                                ),
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => const AddFaces()));
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                )
                            ),

                            child: ListTile(
                              leading: const Icon(CupertinoIcons.phone,
                              size: 40,),
                                title: Text('Call a Friend',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 27.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              onTap: (){

                                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactsScreen()));

                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                                color: Colors.lightGreen,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                )
                            ),

                            child: ListTile(
                              leading: const Icon(CupertinoIcons.square_list,
                              size: 40,),
                                title: Text('Your Medication',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 27.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              onTap: () async {

                                Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicineList(),
                                ),
                                );
                              },
                            ),
                          ),
                        ),

                      ],
                    )

                )

            ),

        ],
      ),
    );
  }

}

