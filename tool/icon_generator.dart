import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create a simple app icon generator
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);
  
  // Background
  final bgPaint = Paint()..color = const Color(0xFF1A1A1A);
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  
  // Golden color
  final goldPaint = Paint()..color = const Color(0xFFD4AF37);
  
  // Draw mosque shape
  // Main body
  canvas.drawRect(
    const Rect.fromLTWH(200, 450, 624, 400),
    goldPaint,
  );
  
  // Main dome
  canvas.drawOval(
    const Rect.fromLTWH(262, 200, 500, 300),
    goldPaint,
  );
  
  // Left minaret
  canvas.drawRect(const Rect.fromLTWH(100, 300, 80, 550), goldPaint);
  final leftMinaretPath = Path()
    ..moveTo(140, 180)
    ..lineTo(180, 300)
    ..lineTo(100, 300)
    ..close();
  canvas.drawPath(leftMinaretPath, goldPaint);
  
  // Right minaret
  canvas.drawRect(const Rect.fromLTWH(844, 300, 80, 550), goldPaint);
  final rightMinaretPath = Path()
    ..moveTo(884, 180)
    ..lineTo(924, 300)
    ..lineTo(844, 300)
    ..close();
  canvas.drawPath(rightMinaretPath, goldPaint);
  
  // Door (dark)
  final darkPaint = Paint()..color = const Color(0xFF1A1A1A);
  canvas.drawRRect(
    RRect.fromRectAndCorners(
      const Rect.fromLTWH(412, 600, 200, 250),
      topLeft: const Radius.circular(100),
      topRight: const Radius.circular(100),
    ),
    darkPaint,
  );
  
  // Windows
  canvas.drawCircle(const Offset(320, 550), 40, darkPaint);
  canvas.drawCircle(const Offset(704, 550), 40, darkPaint);
  
  // Crescent on top
  canvas.drawCircle(const Offset(512, 170), 40, goldPaint);
  canvas.drawCircle(const Offset(530, 160), 35, bgPaint);
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(1024, 1024);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  
  if (byteData != null) {
    final file = File('assets/icons/app_icon.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print('Icon saved to assets/icons/app_icon.png');
  }
}
