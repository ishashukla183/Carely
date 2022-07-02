//@dart=2.9
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'Medicine.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({Key key}) : super(key: key);

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  File medicineFile;
  List<Medicine> medicines = <Medicine>[];
  TimeOfDay _time = TimeOfDay.fromDateTime(DateTime.now());
  final TextEditingController _name = TextEditingController();
  final TextEditingController _dose = TextEditingController();
  Color _color;
  bool isTaken = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadMedicineFile();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      color: const Color(0xff757575),
      child: Container(
        padding: const EdgeInsetsDirectional.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 15.0,
            ),
            const Text(
              'Medicine Name',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23.0,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: _name,
              autofocus: true,
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text(
              'Dosage',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23.0,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: _dose,
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text(
              'When to Take',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23.0,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
              height: 100,
              child: CupertinoDatePicker(
                use24hFormat: true,
                mode: CupertinoDatePickerMode.time,
                onDateTimeChanged: (DateTime value) {
                  setState(() {
                    _time = TimeOfDay.fromDateTime(value);
                  });
                },
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text(
              'Color',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23.0,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        _color = Colors.deepOrange;
                      });
                    },
                    child: const Icon(
                      Icons.circle,
                      color: Colors.deepOrange,
                    )),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _color = Colors.grey;
                      });
                    },
                    child: const Icon(
                      Icons.circle,
                      color: Colors.grey,
                    )),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _color = Colors.purpleAccent;
                      });
                    },
                    child: const Icon(
                      Icons.circle,
                      color: Colors.purpleAccent,
                    )),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _color = Colors.green;
                      });
                    },
                    child: const Icon(
                      Icons.circle,
                      color: Colors.green,
                    )),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _color = Colors.yellow;
                      });
                    },
                    child: const Icon(
                      Icons.circle,
                      color: Colors.yellow,
                    ))
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Card(
              color: Colors.lightBlueAccent,
              child: TextButton(
                onPressed: () {
                  if (kDebugMode) {
                    print('time = ' +
                        _time.toString() +
                        "name =" +
                        _name.text.toString() +
                        "dose = " +
                        _dose.text.toString() +
                        "color =" +
                        _color.toString());
                  }
                  setState(() {
                    List medicineFileJson = <Medicine>[];
                    String name = _name.text;
                    String dose = _dose.text;
                    if (name != null &&
                        _time != null &&
                        dose != null &&
                        _color != null) {
                      medicines.add(Medicine(
                        time: _time,
                        name: name,
                        dose: dose,
                        color: _color,
                        isChecked: false,
                      ));

                      medicineFile.writeAsStringSync(jsonEncode(medicines));
                    }
                  });

                  Navigator.pop(context);
                },
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  loadMedicineFile() async {
    var tempDir = await getApplicationDocumentsDirectory();
    medicineFile = File(tempDir.path + '/medicines.json');
    setState(() {
      if (medicineFile.existsSync()) {
        var jsonBody = json.decode(medicineFile.readAsStringSync());
        for (var data in jsonBody) {
          medicines.add(Medicine(
            name: data['name'],
            dose: data['dose'],
            time: TimeOfDay(
                hour: int.parse(data['time'].toString().substring(10, 12)),
                minute: int.parse(data['time'].toString().substring(13, 15))),
            color: Color(int.parse(data['color'].split('(0x')[1].split(')')[0],
                    radix: 16) +
                0xFF000000),
            isChecked: (data['isChecked'] == 'true'),
          ));
        }
      }
    });
  }
}
