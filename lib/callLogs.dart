//@dart=2.9
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';

class CallLogs {
  void call(String text) async {
    bool res = await FlutterPhoneDirectCaller.callNumber(text);
  }

  getAvatar(CallType callType) {
    switch (callType) {
      case CallType.outgoing:
        return CircleAvatar(maxRadius: 30,
          foregroundColor: Colors.green,
          backgroundColor: Colors.greenAccent[100],);
      case CallType.missed:
        return CircleAvatar(
          maxRadius: 30,
          foregroundColor: Colors.red,
          backgroundColor: Colors.red[400],);
      default:
        return const CircleAvatar(maxRadius: 30,
          foregroundColor: Colors.indigo,
          backgroundColor: Colors.indigo,);
    }
  }

  Future<Iterable<CallLogEntry>> getCallLogs() {
    return CallLog.get();
  }

  String formatDate(DateTime dt) {
    return DateFormat('d-MMM-y H:m:s').format(dt);
  }

  getTitle(CallLogEntry entry){
    if(entry.name == null){
      return Text(entry.number);
    }
    if(entry.name.isEmpty){
      return Text(entry.number);
    }
    else{
      return Text(entry.name);
    }
  }
  String getTime(){
    return '';
  }
}