import 'package:flutter/material.dart';
class Medicine extends StatelessWidget {
  TimeOfDay time;
  String name;
  String dose;
  Color color;
  bool isChecked = false;
  Medicine( {required this.time, required this.name, required this.dose, required this.color, required this.isChecked});
 factory Medicine.fromJson(Map<String, dynamic> json)
  {
    return Medicine(name : json['name'],
    time : json['time'],
    dose : json['dose'],
    color :json['color'],
    isChecked : json['isChecked']);
    }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time.toString(),
      'dose' : dose,
      'color' : color.toString(),
      'isChecked' : isChecked.toString()
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

}
