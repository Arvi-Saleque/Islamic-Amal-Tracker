import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class IconGeneratorScreen extends StatefulWidget {
  const IconGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<IconGeneratorScreen> createState() => _IconGeneratorScreenState();
}

class _IconGeneratorScreenState extends State<IconGeneratorScreen> {
  final GlobalKey _iconKey = GlobalKey();
  String _status = 'Ready to generate icon';

  Future<void> _generateIcon() async {
    setState(() => _status = 'Generating...');

    try {
      RenderRepaintBoundary boundary =
          _iconKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 4.0); // 256 * 4 = 1024
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        final directory = await getApplicationDocumentsDirectory();
        final iconPath = '${directory.path}/app_icon.png';
        final file = File(iconPath);
        await file.writeAsBytes(pngBytes);

        setState(() => _status = 'Icon saved to:\n$iconPath');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Icon saved! Path: $iconPath'),
            backgroundColor: const Color(0xFFD4AF37),
          ),
        );
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text('Icon Generator'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon preview
            RepaintBoundary(
              key: _iconKey,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Icon(
                    Icons.mosque,
                    size: 160,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _generateIcon,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Generate Icon'),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
