
//@dart=2.9
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'AddMedicine.dart';
import 'Medicine.dart';
import 'notification_api.dart';
class MedicineList extends StatefulWidget {
  const MedicineList({Key key}) : super(key: key);

  @override
  State<MedicineList> createState() => _MedicineListState();
}

class _MedicineListState extends State<MedicineList> {
File medicineFile;
int indexToDelete;

File LastTaken;
dynamic uncheck = {};
HashSet<String> toUncheck = HashSet();
List<Medicine> medicines = <Medicine>[];
@override
   initState() {
    // TODO: implement initState

    super.initState();

loadMedicineFile();


  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
floatingActionButton: FloatingActionButton(
  child: Icon(Icons.add),
  backgroundColor: Colors.lightBlueAccent, onPressed: () async {
    showModalBottomSheet<dynamic>( isScrollControlled: true,context: context, builder: (context) => Wrap(children: [AddMedicine()]) );

    await Future.delayed(const Duration(seconds: 20));
    loadMedicineFile();



    },
),
        backgroundColor: Colors.lightBlueAccent,
        body:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children:
              [ Container(

            padding: const EdgeInsets.only(top: 60.0, left: 30.0, bottom: 30.0, right: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
              const [
                CircleAvatar(child: Icon(Icons.list,
                size: 30.0,
                color: Colors.lightBlueAccent,),
                backgroundColor: Colors.white
                  ,
                radius: 30.0,),
                SizedBox(
                  height: 15.0,
                ),
                Text("Your Medication",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42.0,
                  fontWeight: FontWeight.w700,
                ),),
                SizedBox(
                  height: 10.0,
                ),
],),),
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
                    child: (medicines!=null)? ListView.builder(

                         itemCount: medicines.length
    ,
                        itemBuilder: (context, index) {
      return ListTile(

        title: Text(medicines[index].name, style: TextStyle(
          fontSize: 20.0,
          decoration: medicines[index].isChecked? TextDecoration.lineThrough : null,
        ),),
        subtitle: Row(
          children : [ Text(medicines[index].dose.toString() + ' pills, ' + medicines[index].time.toString().substring(10, 15) ,
            style: TextStyle(
              fontSize: 15.0,
            ),),
            Padding(
              padding: const EdgeInsets.only( left: 7.0),
              child:   Icon(Icons.circle,

                color: medicines[index].color,),
            )
          ],
        ),
        trailing : Checkbox(
          activeColor: Colors.lightBlueAccent
          ,value: medicines[index].isChecked, onChanged: (bool value) {
          setState(() {
            medicines[index].isChecked = !medicines[index].isChecked;
            medicineFile.writeAsStringSync(jsonEncode(medicines));
            if( medicines[index].isChecked){
              uncheck[medicines[index].toString()] = DateTime.now().toString();
              LastTaken.writeAsStringSync(json.encode(uncheck));
            }
          });

        },
          // onChanged: toggleCheckBox,
        ),
        onLongPress: (){
          indexToDelete = index;
          var alert = AlertDialog(
            title: Text('Do you want to delete this?'),
            actions: <Widget>[
              TextButton(
                  child: const Text("Delete",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 20.0,),),
                  onPressed: () {
                    setState(() {
                      medicines.removeAt(indexToDelete);
                      medicineFile.writeAsStringSync(jsonEncode(medicines));
                    });

                    Navigator.pop(context);
                  }),
              TextButton(
                child: const Text("Cancel",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.normal,),
                ),
                onPressed: () {

                  Navigator.pop(context);
                },
              )
            ],
          );
          showDialog(
              context: context,
              builder: (context) {
                return alert;});
        },
      );

                      }) : Container(

                    ),


                    ),
                  ),
              ],
            ),



    );
  }

   loadMedicineFile() async {
    medicines = [];
    var tempDir = await getApplicationDocumentsDirectory();
    medicineFile = File(tempDir.path + '/medicines.json');
    LastTaken =  File(tempDir.path + '/lastTaken.json');

      if (medicineFile.existsSync()){
        var jsonBody = json.decode(medicineFile.readAsStringSync());
        for(var data in jsonBody) {
          medicines.add(Medicine(name : data['name'], dose: data['dose'], time: TimeOfDay( hour : int.parse(data['time'].toString().substring(10,12)), minute: int.parse(data['time'].toString().substring(13,15))), color: Color(int.parse(data['color'].split('(0x')[1].split(')')[0], radix: 16) + 0xFF000000), isChecked: (data['isChecked'] == 'true'),));
        }
        if (kDebugMode) {
          print(json.decode(medicineFile.readAsStringSync()).toList());
        }

      }
      if(LastTaken.existsSync()){
        if(mounted){
          setState(() {
            uncheck = json.decode(LastTaken.readAsStringSync());
          });
        }

          

      }
      
      for ( String key in uncheck.keys ) {
        if (kDebugMode) {
          print("difference = " + DateTime.now().difference(DateTime.parse(uncheck[key.toString()])).inHours.toString());
        }
        if(DateTime.now().difference(DateTime.parse(uncheck[key.toString()]) ).inHours > 23 ){
          toUncheck.add(key);

        }
      }

      for(int index=0; index <medicines.length; index++){
        toUncheck.contains(medicines[index].toString())? medicines[index].isChecked = false : medicines[index].isChecked = medicines[index].isChecked;
      }



  }
  void onClickedNotification(String payload){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MedicineList()));
  }
  void listenNotifications() {
    NotificationAPI.onNotifications.stream.listen(onClickedNotification);
  }
}

