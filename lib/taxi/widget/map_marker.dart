import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Uint8List> getBytesFromAssetString({
  required String path,
  required int width,
  String? text,
  double fontSize = 16.0,
  int color = 0xFFFFFFFF,
  double topPadding = 12.0,
}) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  ui.Image image = fi.image;


  final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: fontSize,
    ),
  )
    ..pushStyle(ui.TextStyle(color: ui.Color(color)))
    ..addText(text ?? '');

  final ui.Paragraph paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: width.toDouble()));

  //double requiredHeight = image.height.toDouble() + paragraph.height + topPadding;

  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(pictureRecorder);

  // Draw the icon image on the canvas
  canvas.drawImage(image, ui.Offset.zero, ui.Paint());

  // Calculate the offset with top padding
  final double textX = (width - paragraph.width) / 2.0;
  final double textY = topPadding;

  // Draw the text on top of the icon image with padding
  canvas.drawParagraph(paragraph, ui.Offset(textX, textY));


  // End the recording and obtain the resulting picture
  final ui.Picture picture = pictureRecorder.endRecording();

  final ui.Image finalImage = await picture.toImage(
    width,
    width,
  );

  final ByteData? byteData =
  await finalImage.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<Uint8List> getBytesFromAsset(
    {required String path, required int width, int height = 80}) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width, targetHeight: height);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<BitmapDescriptor> getBitmapDescriptorFromAsset(String assetPath,
    {int width = 24, int height = 24}) async {
  final Uint8List customMarker = await getBytesFromAsset(
    path: assetPath, //paste the custom image path
    width: width, // size of custom image as marker
    height: height,
  );
  BitmapDescriptor icon = BitmapDescriptor.fromBytes(customMarker);
  return icon;
}

Future<Uint8List> getnetWorkIcon(String? profilePhotoUrl) async {
  Uint8List? image = await _loadNetworkImage(profilePhotoUrl ?? "");

  final ui.Codec markerImageCodec = await instantiateImageCodec(
    image!.buffer.asUint8List(),
    targetHeight: 100,
    targetWidth: 100,
  );
  final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
  final ByteData? byteData = await frameInfo.image.toByteData(
    format: ImageByteFormat.png,
  );

  final Uint8List resizedMarkerImageBytes = byteData!.buffer.asUint8List();
  return resizedMarkerImageBytes;
}

Future<Uint8List?> _loadNetworkImage(String path) async {
  final completer = Completer<ImageInfo>();
  var img = NetworkImage(path);
  img
      .resolve(const ImageConfiguration(size: Size.fromHeight(10)))
      .addListener(ImageStreamListener((info, _) => completer.complete(info)));
  final imageInfo = await completer.future;
  final byteData = await imageInfo.image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return byteData?.buffer.asUint8List();
}
