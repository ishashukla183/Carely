


import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';



//user-defined datatypes
typedef HandleDetection = Future<dynamic> Function(InputImage image);
enum Choice { view, delete }

//async method that takes camera direction as a parameter, finds the first camera from list of all available cameras that matches the oreintation and returns it
Future<CameraDescription> getCamera(CameraLensDirection dir) async {
  return await availableCameras().then(
        (List<CameraDescription> cameras) => cameras.firstWhere(
          (CameraDescription camera) => camera.lensDirection == dir,
    ),
  );
}
//Some extra functions required for FaceRecognition are created here

//this method returns a rotated image
InputImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return InputImageRotation.rotation0deg;
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    default:
      assert(rotation == 270);
      return InputImageRotation.rotation270deg;
  }
}

double euclideanDistance(List e1, List e2) {
  double sum = 0.0;
  for (int i = 0; i < e1.length; i++) {
    sum += pow((e1[i] - e2[i]), 2);
  }
  return sqrt(sum);
}

Float32List imageToByteListFloat32(
    imglib.Image image, int inputSize, double mean, double std) {
  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(j, i);
      buffer[pixelIndex++] = (imglib.getRed(pixel) - mean) / std;
      buffer[pixelIndex++] = (imglib.getGreen(pixel) - mean) / std;
      buffer[pixelIndex++] = (imglib.getBlue(pixel) - mean) / std;
    }
  }
  return convertedBytes.buffer.asFloat32List();
}


//detect faces in incoming image stream
//this function takes in an CameraImage, rotation, handleDetection as a parameter and returns images of detected faces
Future<dynamic> detect(
    CameraImage cameraImage,
    HandleDetection handleDetection,
    InputImageRotation rotation,
    ) async {
  final WriteBuffer allBytes = WriteBuffer();
  for (Plane plane in cameraImage.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

  final InputImageRotation imageRotation = rotation;

  const InputImageFormat inputImageFormat =

          InputImageFormat.yuv420;

  final planeData = cameraImage.planes.map(
        (Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    },
  ).toList();
  final inputImageData = InputImageData(
    size: imageSize,
    imageRotation: imageRotation,
    inputImageFormat: inputImageFormat,
    planeData: planeData,
  );
  if (kDebugMode) {
    print('executing detect');
  }
  //converts CameraImage to InputImage and calls handleDetection
  return handleDetection(
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData,
    )
  );
}


Future detectFromGalleryImage(File image, HandleDetection handleDetection) async {
  if (kDebugMode) {
    print("Executing handleDetection");
  }
  return handleDetection(InputImage.fromFile(image));
}