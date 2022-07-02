//@dart=2.9

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:faceverse/phonelogscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> contacts;
  File relations;
  dynamic data = {};
  List<String> callMadeTo = <String>[];
  bool callAnyway = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadFile();
    getContactData();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,

      body: (contacts == null) ? const Center(
          child: const CircularProgressIndicator()) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: 60.0, left: 30.0, bottom: 30.0, right: 30.0),
            child: Row(
              children: [
                Text("Your Contacts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 33.0,
                    fontWeight: FontWeight.w700,
                  ),),
                SizedBox(
                  width: 16,
                ),
                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  PhoneLogScreen()));
                }, child: Text('View Log',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w100,
                ),) )
              ],
            ),

          ),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),

                )
            ),
            child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  Uint8List image = contacts[index].photo;
                  String number = (contacts[index].phones.isNotEmpty)
                      ? contacts[index].phones.first.number
                      : "";
                  String text = "";
                  if (data.containsKey(
                      contacts[index].name.first.toUpperCase())) {
                    text = (data[contacts[index].name.first.toUpperCase()])
                        .toString()
                        .substring(0, 1) + (data[contacts[index].name.first
                        .toUpperCase()]).toString().substring(1,).toLowerCase();
                  }
                  else {
                    index += 1;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListTile(
                      title: Column(
                          children: [(image == null) ? const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person,
color: Colors.white,
                              size: 50,),
                            radius: 60.0,) : CircleAvatar(
                            backgroundImage: MemoryImage(image),
                            radius: 60.0,),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, bottom: 3.0),
                              child: Center(
                                child: Text(contacts[index].name.first,

                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,


                                  ),),
                              ),
                            ),
                          ]
                      ),
                      subtitle: Column(
                          children: [
                            (text != "") ? Text(text,
                              style: const TextStyle(
                                fontSize: 20.0,


                              ),) : Text(text,
                              style: const TextStyle(
                                fontSize: 0.0,


                              ),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(onPressed: () {
                                  if (kDebugMode) {
                                    print(number.toString());
                                  }
                                  if (callMadeTo != null &&
                                      callMadeTo.contains(number.toString())
                                  ) {
                                    setState(() {
                                      callAnyway = false;
                                    });
                                    repeatedCall();
                                  }
                                  callMadeTo.add(number.toString());
                                  Timer.periodic(
                                      const Duration(minutes: 30), (Timer t) {
                                    callMadeTo.remove(number);
                                  });
                                  if (callAnyway) {
                                    launchUrl(Uri.parse('tel:' + number));
                                  }
                                },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            30.0),
                                      ),
                                      color: Colors.green[800],
                                      child:
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Icon(Icons.phone_in_talk,
                                                color: Colors.white,),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(3.0),
                                              child: Text('Call   ',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),),
                                            ),
                                          ],
                                        ),
                                      ),

                                    )),
                                TextButton(onPressed: () {
                                  launchUrl(Uri.parse('sms: ' + number));
                                },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            30.0),
                                      ),
                                      color: Colors.green[800],
                                      child:
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Icon(
                                                Icons.message_outlined,
                                                color: Colors.white,),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(3.0),
                                              child: Text('Text   ',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),),
                                            ),
                                          ],
                                        ),
                                      ),

                                    )),
                              ],
                            )
                          ]),

                    ),
                  );
                }),
          ),
          ),
        ],

      ),

    );
  }
  void loadFile()async{
   var tempDir = await getApplicationDocumentsDirectory();
   relations = File(tempDir.path + '/relation.json');
   setState(() {

     if (relations.existsSync()) data = json.decode(relations.readAsStringSync());
   });
  }
  void getContactData() async{
     loadFile();
    List<Contact> contactsAsync;

    if(await FlutterContacts.requestPermission()){

        contactsAsync = await FlutterContacts.getContacts(
            withProperties: true, withPhoto: true
        );

    }
    int ptr=0;
    for(int i=0; i<contactsAsync.length; i++){
      if(data.containsKey(contactsAsync[i].name.first.toUpperCase()) ){
        Contact contact = contactsAsync[i];
        contactsAsync.removeAt(i);
         contactsAsync.insert(ptr, contact);
         ptr+=1;
      }
    }
    setState(() {
      contacts = contactsAsync;
    });
  }

  Widget repeatedCall() {
    if (kDebugMode) {
      print("Executing repeatedCall");
    }
    var alert = AlertDialog(
      title: const Text("Repeated Call",
        style: TextStyle(

          fontWeight: FontWeight.bold,
          fontSize: 20.0,),),
      content: Row(
        children: const <Widget>[
          Expanded(
            child: Text('You have already called this person in the last 10 minutes, do you want to call again?'
            ),
          ),

        ],
      ),
      actions: <Widget>[
        TextButton(
            child: const Text("Call",
              style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 20.0,),),
            onPressed: () {
              callAnyway = true;
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
  }
}

