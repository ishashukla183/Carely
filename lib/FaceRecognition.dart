//@dart=2.9

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as imglib;
import 'CameraUtils.dart';
import 'FacePainter.dart';
import 'package:quiver/collection.dart';

class FaceRecognition extends StatefulWidget {

  const FaceRecognition({Key key}) : super(key: key);
  @override
  State<FaceRecognition> createState() => _FaceRecognitionState();
}

class _FaceRecognitionState extends State<FaceRecognition> {
  File jsonFile;
  FlutterTts flutterTts = FlutterTts();
  var prevRes = '';

  File relations;
  dynamic _scanResults;
  dynamic _relationResult;
  dynamic relation = {};
  var interpreter;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  dynamic data = {};
  double threshold = 1.0;
  Directory tempDir;
  List e1;
  bool _faceFound = false;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _relation = TextEditingController();

  CameraController _camera;

  @override
  void initState() {


    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _initializeCamera();

  }
  //This method will load the mobilefacenet.tflite model
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




  //This method will initialize camera
  //Called from super constructor
    void _initializeCamera() async {
    //wait until tfl model has been loaded
    await loadModel();
    //passing camera direction to getCamera method and calling it
    CameraDescription description = await getCamera(_direction);


    //get rotated image
    InputImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
    _camera =
        CameraController(description, ResolutionPreset.max, enableAudio: false);
    await _camera.initialize();
    if (kDebugMode) {
      print('camera initialized');
    }
    await Future.delayed(const Duration(milliseconds: 500));
    tempDir = await getApplicationDocumentsDirectory();

    relations = File(tempDir.path + '/relation.json');
    jsonFile = File( tempDir.path + '/emb.json');

    setState(() {
      if (jsonFile.existsSync()) data = json.decode(jsonFile.readAsStringSync());
      if (relations.existsSync()) relation = json.decode(relations.readAsStringSync());
    });

    if (kDebugMode) {
      print(data.toString());
    }

    if (kDebugMode) {
      print(relation.toString());
    }
    _camera.startImageStream((CameraImage image) {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        String res;
        dynamic finalResult = Multimap<String, Face>();
        dynamic relResult = Multimap<String, String>();
        //calling detect method to detect if any faces exist in image stream
        detect(image, _getDetectionMethod(), rotation).then(
              (dynamic result) async {
            if (result.length == 0) {
              _faceFound = false;
            } else {
              _faceFound = true;
            }
            if (kDebugMode) {
              print("facefound = " + _faceFound.toString());
              print('Result length = ' + result.length.toString());
            }
            Face _face;
            imglib.Image convertedImage =
            _convertCameraImage(image, _direction);
            for (_face in result) {
              double x, y, w, h;
              x = (_face.boundingBox.left - 10);
              y = (_face.boundingBox.top - 10);
              w = (_face.boundingBox.width + 10);
              h = (_face.boundingBox.height + 10);
              imglib.Image croppedImage = imglib.copyCrop(
                  convertedImage, x.round(), y.round(), w.round(), h.round());
              croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
              // int startTime = new DateTime.now().millisecondsSinceEpoch;
              if (kDebugMode) {
                print("calling recognize");
              }
              res = _recognize(croppedImage);
              // int endTime = new DateTime.now().millisecondsSinceEpoch;
              // print("Inference took ${endTime - startTime}ms");
              finalResult.add(res, _face);
            }
            setState(() {
              _scanResults = finalResult;
              if(res!='NOT RECOGNIZED'){
                relResult.add(res, relation[res]);
              }
              _relationResult = relResult;
            });

            _isDetecting = false;
          },
        ).catchError(
              (_) {
            _isDetecting = false;
          },
        );
      }
    });

  }

  HandleDetection _getDetectionMethod() {

    final faceDetector = FaceDetector(
     options: FaceDetectorOptions(
       performanceMode: FaceDetectorMode.accurate
      ),
    );
    //returns raw image which is converted to image by detect
    return faceDetector.processImage;
  }


  imglib.Image _convertCameraImage(
      CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)?
         imglib.copyRotate(img, -90)
        : imglib.copyRotate(img, 90);
    return img1;
  }
  //recognize image
  String _recognize(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    if (kDebugMode) {
      print('e1 = ' + e1.toString());
    }

    return compare(e1).toUpperCase();
  }

  String compare(List currEmb) {

    if (data.length == 0) return "NO FACES SAVED";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    if (kDebugMode) {
      print("minDist = " + minDist.toString() + " " + predRes);
    }
    return predRes;
  }

  Widget _buildImage() {
    if (_camera == null || !_camera.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black
          ,
        ),
      );
    }

    return Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
        Color(0xFFf64f59),
    Color(0xFFc471ed),
    Color(0xFF12c2e9),],),),
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_camera),
          _buildResults(),
        ],
      ),
    );
  }
  Widget _buildResults(){
    const Text noResultsText = Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;
      final Size imageSize = Size(_camera.value.previewSize.height, _camera.value.previewSize.width,
      );

    painter = FacePainter(imageSize, _scanResults, _relationResult, _direction);
    return CustomPaint(
      painter: painter,
    );
  }
  void _addLabel() {
    setState(() {
      _camera = null;
    });
    if (kDebugMode) {
      print("Adding new face");
    }
    var alert = AlertDialog(
      title: const Text("Add Face",
        style: TextStyle(

        fontSize: 25.0,),),
      content: Column(
        children: <Widget>[
          Expanded(
            child: TextField(
              style: TextStyle(
                fontSize: 20.0,
              ),
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: "Name", icon: Icon(Icons.face),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              style: TextStyle(
                fontSize: 20.0,
              ),
              controller: _relation,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: "Your Relation", icon: Icon(Icons.family_restroom)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
            child: const Text("Save",
        style: TextStyle(


         fontSize: 15),),
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
            ),
          ),
          onPressed: () {
            _initializeCamera();
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
  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

    appBar: AppBar(
      backgroundColor: Colors.lightBlueAccent,
      toolbarHeight: 80,
    title: const Text('Who Is This?',
        style: TextStyle(
color: Colors.white,
        fontSize: 28.0,

    ),
    ),
    ),
    body: _buildImage(),
      floatingActionButton:
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            backgroundColor: (_faceFound) ? Colors.lightBlueAccent : Colors.grey,
            child: const Icon(Icons.add,
            ),
            onPressed: () {
              if (_faceFound) _addLabel();
            },
            heroTag: null,
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            backgroundColor: Colors.lightBlueAccent,

            onPressed: _toggleCameraDirection,
            heroTag: null,
            child: _direction == CameraLensDirection.back
                ? const Icon(Icons.cameraswitch)
                : const Icon(Icons.cameraswitch),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            backgroundColor: Colors.lightBlueAccent,
            child: const Icon(Icons.mic_rounded,
            ),
            onPressed: () {
              if (_scanResults!=null){

                  for(String key in _scanResults.keys){
                    if (kDebugMode) {
                      print("Speaking " + key);
                    }


                    if(key!= 'NOT RECOGNIZED'){
                      if (kDebugMode) {
                        print("Speaking " + relation[key]);
                      }
                      _speak(key + '. ' + relation[key]);
                      }
                    else{
                      _speak(key);
                    }


                  }

              }
            },
            heroTag: null,
          ),
        ),
      ]),
    );

  }
  void _handle(String text, String rel) {
    data[text] = e1;
    jsonFile.writeAsStringSync(json.encode(data));
    relation[text] = rel;
    relations.writeAsStringSync(json.encode(relation));
    _initializeCamera();
  }

  Future _speak(String text) async{
    if (kDebugMode) {
      print("Speaking....");

    }await flutterTts.getLanguages;
    await flutterTts.speak(text);
  }

}





