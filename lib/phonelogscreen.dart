//@dart=2.9
import 'package:call_log/call_log.dart';
import 'package:faceverse/callLogs.dart';
import 'package:flutter/material.dart';
import 'phone_textfield.dart';

class PhoneLogScreen extends StatefulWidget {


  @override
  _PhoneLogScreenState createState() => _PhoneLogScreenState();
}

class _PhoneLogScreenState extends State<PhoneLogScreen> with WidgetsBindingObserver{
  PhoneTextField pt = PhoneTextField();
  CallLogs cl = CallLogs();
  AppLifecycleState _notification;
  Future<Iterable<CallLogEntry>> logs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    logs = cl.getCallLogs();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    super.didChangeAppLifecycleState(state);
    if(AppLifecycleState.resumed == state){
      setState(() {
        logs = cl.getCallLogs();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone'),
      ),
      body: Column(
        children: [
          pt, FutureBuilder(future: logs,builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done){
              Iterable<CallLogEntry> entries = snapshot.data;
              return Expanded(child:
              ListView.builder(itemBuilder: (context, index) {
                return GestureDetector(
                  child: Card(
                    child: ListTile(
                    leading: cl.getAvatar(entries.elementAt(index).callType),
                    title: cl.getTitle(entries.elementAt(index)),
                      subtitle: Text(cl.formatDate(new DateTime.fromMillisecondsSinceEpoch(entries.elementAt(index).timestamp)) + '\n'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: Icon(Icons.phone), color: Colors.green, onPressed: (){
                          cl.call(entries.elementAt(index).number);
                      },
                      ),
                    ),
                  ),


                  onLongPress: (){
                    pt.update(entries.elementAt(index).number.toString());
                  },

              );
              },
              ),
    );

            }
            else{
              return const Center(
              child: CircularProgressIndicator(),
              );
    }
          })
        ],
      ),
    );
  }
}
