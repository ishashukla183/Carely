// @dart=2.9

import 'dart:convert';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'dart:io';
import 'package:faceverse/CameraUtils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

class AddFaces extends StatefulWidget {
  const AddFaces({Key key}) : super(key: key);

  @override
  State<AddFaces> createState() => _AddFacesState();
}

class _AddFacesState extends State<AddFaces> {

  File jsonFile;
  File relations;
  dynamic relation = {};
  final TextEditingController _name = TextEditingController();
  final TextEditingController _relation = TextEditingController();
  File imageToAdd;
  dynamic data = {};
  Directory tempDir;
  bool fileExists = false;
  bool faceFound = false;
  List e1;
  Face detectedFace;
  bool relationExists = false;
  //Multimap<String, String> relation = new Multimap<>();
  var interpreter;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getApplicationDocumentsDirectory().then((Directory dir) {
      tempDir = dir;
      jsonFile = File(dir.path + '/emb.json');
      relations = File(dir.path + '/relation.json');
      fileExists = jsonFile.existsSync();
      relationExists = relations.existsSync();
      if (fileExists) {
        setState(() {
          data = json.decode(jsonFile.readAsStringSync());
        });
        if (kDebugMode) {
          print(data.toString());
        }
      }
      if(relationExists){
        setState(() {
          relation = json.decode(relations.readAsStringSync());
        });
        if (kDebugMode) {
          print(relation.toString());
        }
      }
    });

  }
 Widget showFaces() {
   return Scaffold(
     backgroundColor: Colors.lightBlueAccent,
     body: Column(
       children: [
         Container(
           padding: const EdgeInsets.only(
               top: 80.0, left: 20.0, bottom: 30.0, right: 30.0),
           child: Column(
             children: const [ Text("Saved Faces",
               style: TextStyle(
                 color: Colors.white,
                 fontSize: 40.0,
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
             child: ListView.builder(
                 padding: const EdgeInsets.symmetric(
                     vertical: 40, horizontal: 20),
                 itemCount: data.length,
                 itemBuilder: (BuildContext context, int index) {
                   String name;

                   if (fileExists) {
                     name = data.keys.elementAt(index);
                   }


                   return Column(
                       children: <Widget>[
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Card(
                             elevation: 0,
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(20.0),
                             ),
                             child: Dismissible(
                               key: Key(name),
                               onDismissed: (direction) {
                                 setState(() {
                                   data.remove(name);
                                   jsonFile.writeAsStringSync(
                                       json.encode(data), flush: true);
                                   relation.remove(name);
                                   relations.writeAsStringSync(
                                       json.encode(relation), flush: true);
                                 });
                               },
                               child: ListTile(
                                 title: Text(name,
                                   style: const TextStyle(
                                     fontSize: 23.0,
                                     fontWeight: FontWeight.bold,
                                   ),),
                                 subtitle: Padding(
                                   padding: const EdgeInsets.symmetric(vertical : 3.0),
                                   child: Text(relation[name].toString(),
                                   style: const TextStyle(
                                     fontSize: 15.0,
                                   ),),
                                 ),
                                 trailing: const Icon(CupertinoIcons.delete_simple,
                                 color: Colors.black,),
                               ),
                             ),
                           ),
                         )

                       ],
                   );
                 }
             ),
           ),
         ),

       ],),);
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60.0, left: 30.0, bottom: 30.0, right: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  child: Icon(CupertinoIcons.list_bullet_below_rectangle,
                   size:40,),
                  backgroundColor: Colors.white,
                  radius: 50.0,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text("Actions",
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
                            title: const Text('View Saved Faces',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

    onTap: () async {

    Navigator.push(context, MaterialPageRoute(builder: (context) {
    return showFaces();
    },
                          )); },),
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
                            title: const Text('Add a Face',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27.0,
                                fontWeight: FontWeight.bold,

                              ),
                            ),
    onTap: () {
    getImageFromGallery().then((isImagePicked) async {
    await Future.delayed(
    const Duration(milliseconds: 1000));
    Navigator.push(context, MaterialPageRoute(builder: (
    context) {
    return _buildImage();
    },

    ),
    );
    } );}
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: const BoxDecoration(
                              color: Color(0xffF9CEEE),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              )
                          ),

                          child: ListTile(
                              title: const Text('Clear Everything',
                                style:  TextStyle(
                                  color: Colors.white,
                                  fontSize: 27.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              onTap: () {
                                var alertDialog = const AlertDialog(
                                  title: Text('No faces added, nothing to clear.'),
                                );

                                if(fileExists) {
                                  jsonFile.deleteSync();
                                  relations.deleteSync();
                                  alertDialog = const AlertDialog(
                                    title:  Text('Database cleared successfully.',
                                      style: TextStyle(
                                      ),),
                                  );
                                }

                                showDialog(context: context, builder: (BuildContext context){
                                  return alertDialog;
                                });



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
  Future loadModel() async {
    try {

      final gpuDelegateV2 = tfl.GpuDelegateV2(
        options: tfl.GpuDelegateOptionsV2(
          isPrecisionLossAllowed: false,
          inferencePreference: tfl.TfLiteGpuInferenceUsage.fastSingleAnswer,
          inferencePriority1: tfl.TfLiteGpuInferencePriority.minLatency,
          inferencePriority2 : tfl.TfLiteGpuInferencePriority.auto,
          inferencePriority3 : tfl.TfLiteGpuInferencePriority.auto,
        ),

      );

      var interpreterOptions = tfl.InterpreterOptions()
        ..addDelegate(gpuDelegateV2);
      interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite', options: interpreterOptions);
      if (kDebugMode) {
        print('Model loaded');
      }
    } on Exception {
      if (kDebugMode) {
        print('Failed to load model.');
      }
    }
  }

  Future<bool> getImageFromGallery() async{
    await loadModel();
    try {
      final pickedImage = await ImagePicker().pickImage(
          source: ImageSource.gallery);
      if (pickedImage == null) return false;

      final imageTemp = File(pickedImage.path);
      setState(() {
        imageToAdd = imageTemp;
      });
    } on PlatformException catch(e){
      if (kDebugMode) {
        print('Failed to pick an image: $e');
      }
    }
    if(imageToAdd!=null){
      await loadImage();
    }
    return true;
  }
  HandleDetection _getDetectionMethod() {
    if (kDebugMode) {
      print('Executing _getDetectionMethod');
    }
    final FaceDetector faceDetector = FaceDetector(
       options: FaceDetectorOptions(
           performanceMode: FaceDetectorMode.accurate
      ),
    );
    //returns raw image which is converted to image by detect
    if (kDebugMode) {
      print('Finished Executing _getDetectionMethod');
    }
    return faceDetector.processImage;
  }
  Widget _buildImage() {

    return Scaffold(

       appBar: AppBar(
         title: const Text('Selected Image'),
         backgroundColor: Colors.lightBlueAccent,
       ),
       body : Container(
         decoration: BoxDecoration(
           image: DecorationImage(
             image: FileImage(imageToAdd),
             fit: BoxFit.fitWidth,
           )
         ),
         child:

              Container(child:  Row(

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [ TextButton(
                    child:  Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Padding(
                      padding: EdgeInsets.symmetric(vertical : 18.0, horizontal: 18.0),
                      child: Text("Ok, Done!",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),),
                    ),
                    color: Colors.lightBlueAccent,),
                  onPressed: () {
                      Navigator.pop(context);
                  },

                ),
                  _buildResults(),
                ]
              ),
              alignment: Alignment.bottomCenter,),


       ),
    );
  }
  Widget _buildResults() {

    if(detectedFace == null){
      if (kDebugMode) {
        print('detectedface is nul???');
      }
      return const Text('Cannot add face. Please try with a different picture!');
    }
     return Padding(
       padding: const EdgeInsets.all(20.0),
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: FloatingActionButton(
           backgroundColor: Colors.lightBlueAccent,
           child: const Icon(Icons.add,

           ),
           onPressed: () {
           _addLabel();
           },

         ),
       ),
     );

  }

  _addLabel() {

    if (kDebugMode) {
      print("Adding new face");
    }
    var alert = AlertDialog(
      title: const Text("Add Face",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,),),
      content: SizedBox(
        width: 200,
        height: 200,
        child: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: "Name", icon: Icon(Icons.face)),
              ),

            ),
            Expanded(
                child: TextField(
                  controller: _relation,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: "Relation", icon: Icon(Icons.family_restroom)),
                ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: const Text("Save",
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,),),
            onPressed: () {
              _handle(_name.text.toUpperCase(), _relation.text.toUpperCase());
              _name.clear();
              _relation.clear();
              Navigator.pop(context);
            }),
        TextButton(
          child: const Text("Cancel",
            style: TextStyle(
              fontSize: 15.0,
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
  Future loadImage()  async {
     detectFromGalleryImage(imageToAdd, _getDetectionMethod()).then((dynamic result) async {
      if(result.length != 1){
        if (kDebugMode) {
          print("Face detected from gallery image = false");

        }}
      else{
        setState(() {
          faceFound = true;
          if (kDebugMode) {
            print('faceFound = ' + faceFound.toString());
          }
        });
        if (kDebugMode) {
          print("Face detected from gallery image = true");

        }
      }
      setState(() {
        if (kDebugMode) {

          print('result ==== ' + result.toString());

        }detectedFace = result[0];
      });
      if(detectedFace == null) {
        if (kDebugMode) {
          print('detectedface is nul???');
        }
      }
      else{
        if (kDebugMode) {
          print('detected face not null and  =' + detectedFace.toString());
        }
      }

      imglib.Image convertedImage =
      _convertGalleryImage(imageToAdd);

        double x, y, w, h;
        x = (detectedFace.boundingBox.left - 10);
        y = (detectedFace.boundingBox.top - 10);
        w = (detectedFace.boundingBox.width + 10);
        h = (detectedFace.boundingBox.height + 10);
        imglib.Image croppedImage = imglib.copyCrop(
            convertedImage, x.round(), y.round(), w.round(), h.round());
        croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
        _recognize(croppedImage);
    });
}

  imglib.Image _convertGalleryImage(
      File image1) {

    final decoder = imglib.JpegDecoder();
    final decodedImg = decoder.decodeImage(image1.readAsBytesSync());
    final decodedBytes = decodedImg.getBytes(format: imglib.Format.rgb);
    int width = decodedImg.width;
    int height =  decodedImg.height;
    var img = imglib.Image(width, height); // Create Image buffer
    int r, g,b;
    if(decodedImg == null){
      if (kDebugMode) {
        print("decodedImg resulting in null");
      }
    }
    else {
      for (int y = 0; y < decodedImg.height; y++) {
        for (int x = 0; x < decodedImg.width; x++) {
          r = decodedBytes[y * decodedImg.width * 3 + x * 3];
          g = decodedBytes[y * decodedImg.width * 3 + x * 3 + 1];
          b = decodedBytes[y * decodedImg.width * 3 + x * 3 + 2];
          final int index = y * width + x;

          const int hexFF = 0xFF000000;


          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          img.data[index] = hexFF | (b << 16) | (g << 8) | r;
        }
      }
    }
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    return img;
  }

   void _recognize(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);


    setState(() {
      e1 = List.from(output);
    });
    if (kDebugMode) {
      print('e1 = ' + e1.toString());
    }
  }
void _handle(String text, String rel) {
    setState(() {
      data[text] = e1;
      jsonFile.writeAsStringSync(json.encode(data));
      relation[text] = rel;
      relations.writeAsStringSync(json.encode(relation));
    });

}
    }







