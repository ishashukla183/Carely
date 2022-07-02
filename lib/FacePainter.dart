//@dart=2.9

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';


class FacePainter extends CustomPainter {
  CameraLensDirection cameraLensDirection;
  Size imageSize;
  dynamic results;
  dynamic relationResult;
  double scaleX, scaleY;
  Face face;

  FacePainter(this.imageSize, this.results, this.relationResult, this.cameraLensDirection);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.black87;
    for (String label in results.keys) {
      for (Face face in results[label]) {
        // face = results[label];
        scaleX = size.width / imageSize.width;
        scaleY = size.height / imageSize.height;

          canvas.drawRRect(
              _scaleRect(
                direction: cameraLensDirection,
                  rect: face.boundingBox,
                  imageSize: imageSize,
                  widgetSize: size,
                  scaleX: scaleX,
                  scaleY: scaleY),
              paint);

        TextSpan span = TextSpan(
            style: const TextStyle(color: Colors.white, fontSize: 20,
                 backgroundColor: Colors.black,
                 fontWeight: FontWeight.bold,),
                  text: label);
        TextPainter textPainter = TextPainter(
            text: span,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
        textPainter.layout();
        textPainter.paint(
            canvas,
           cameraLensDirection == CameraLensDirection.front? Offset(
                size.width - (300 + face.boundingBox.left.toDouble()) * scaleX,
                (face.boundingBox.top.toDouble() - 50) * scaleY): Offset((20 + face.boundingBox.left.toDouble()) * scaleX,(face.boundingBox.top.toDouble() - 50) * scaleY)) ;
      }
    }
    for (String label in results.keys) {
      for (Face face in results[label]) {
        if(label == 'NOT RECOGNIZED') {
          break;
        }
        // face = results[label];
        scaleX = size.width / imageSize.width;
        scaleY = size.height / imageSize.height;
        String label2 = relationResult[label].toString();
        canvas.drawRRect(
            _scaleRect(
                direction: cameraLensDirection,
                rect: face.boundingBox,
                imageSize: imageSize,
                widgetSize: size,
                scaleX: scaleX,
                scaleY: scaleY),
            paint);

        TextSpan span = TextSpan(
            style: const TextStyle(color: Colors.white, fontSize: 20,
              backgroundColor: Colors.black,

              fontWeight: FontWeight.bold,),
            text: label2.substring(1,label2.length-1));
        TextPainter textPainter = TextPainter(
            text: span,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
        textPainter.layout();
        textPainter.paint(
            canvas,
            cameraLensDirection == CameraLensDirection.front? Offset(
                size.width - (300 + face.boundingBox.left.toDouble()) * scaleX,
                (face.boundingBox.bottom.toDouble()+ 30) * scaleY): Offset((20 + face.boundingBox.left.toDouble()) * scaleX,(face.boundingBox.bottom.toDouble()-50) * scaleY)) ;
      }
    }

  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate.imageSize != imageSize || oldDelegate.results != results;
  }
}
RRect _scaleRect(
    { Rect rect,
       Size imageSize,
     Size widgetSize,
       double scaleX,
      double scaleY,
    CameraLensDirection direction}) {
  if(direction == CameraLensDirection.front) {
    return RRect.fromLTRBR(
        (widgetSize.width - rect.left.toDouble() * scaleX),
        rect.top.toDouble() * scaleY,
        widgetSize.width - rect.right.toDouble() * scaleX,
        rect.bottom.toDouble() * scaleY,
        const Radius.circular(5));
  }
  else{
    return RRect.fromLTRBR(
        ( rect.left.toDouble() * scaleX),
        rect.top.toDouble() * scaleY,
        rect.right.toDouble() * scaleX,
        rect.bottom.toDouble() * scaleY,
        const Radius.circular(5));
  }
}