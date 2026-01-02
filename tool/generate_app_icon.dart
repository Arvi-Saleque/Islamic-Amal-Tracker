import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await generateIcon();
}

Future<void> generateIcon() async {
  const size = 1024.0;
  
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));
  
  // Background with rounded corners
  final bgPaint = Paint()..color = const Color(0xFF1A1A1A);
  final rrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size, size),
    const Radius.circular(200),
  );
  canvas.drawRRect(rrect, bgPaint);
  
  // Golden color
  final goldPaint = Paint()
    ..color = const Color(0xFFD4AF37)
    ..style = PaintingStyle.fill;
  
  // Main mosque body
  canvas.drawRect(
    const Rect.fromLTWH(200, 500, 624, 350),
    goldPaint,
  );
  
  // Main dome
  canvas.drawOval(
    const Rect.fromLTWH(232, 280, 560, 280),
    goldPaint,
  );
  
  // Left minaret base
  canvas.drawRect(const Rect.fromLTWH(100, 350, 70, 500), goldPaint);
  
  // Left minaret top
  final leftTop = Path()
    ..moveTo(135, 220)
    ..lineTo(170, 350)
    ..lineTo(100, 350)
    ..close();
  canvas.drawPath(leftTop, goldPaint);
  canvas.drawCircle(const Offset(135, 200), 25, goldPaint);
  
  // Right minaret base
  canvas.drawRect(const Rect.fromLTWH(854, 350, 70, 500), goldPaint);
  
  // Right minaret top
  final rightTop = Path()
    ..moveTo(889, 220)
    ..lineTo(924, 350)
    ..lineTo(854, 350)
    ..close();
  canvas.drawPath(rightTop, goldPaint);
  canvas.drawCircle(const Offset(889, 200), 25, goldPaint);
  
  // Small side domes
  canvas.drawOval(const Rect.fromLTWH(220, 420, 160, 120), goldPaint);
  canvas.drawOval(const Rect.fromLTWH(644, 420, 160, 120), goldPaint);
  
  // Door (dark)
  final darkPaint = Paint()..color = const Color(0xFF1A1A1A);
  canvas.drawRRect(
    RRect.fromRectAndCorners(
      const Rect.fromLTWH(422, 620, 180, 230),
      topLeft: const Radius.circular(90),
      topRight: const Radius.circular(90),
    ),
    darkPaint,
  );
  
  // Windows
  canvas.drawCircle(const Offset(300, 600), 40, darkPaint);
  canvas.drawCircle(const Offset(724, 600), 40, darkPaint);
  
  // Crescent on main dome
  canvas.drawCircle(const Offset(512, 200), 45, goldPaint);
  canvas.drawCircle(const Offset(532, 190), 40, bgPaint);
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  
  if (byteData != null) {
    final buffer = byteData.buffer.asUint8List();
    
    // Save main icon
    final iconFile = File('assets/icons/app_icon.png');
    await iconFile.parent.create(recursive: true);
    await iconFile.writeAsBytes(buffer);
    print('✅ Icon saved to: ${iconFile.path}');
    
    // Save foreground icon (same for now)
    final fgFile = File('assets/icons/app_icon_foreground.png');
    await fgFile.writeAsBytes(buffer);
    print('✅ Foreground icon saved to: ${fgFile.path}');
  }
}
