import 'dart:async';
import 'dart:typed_data';

import 'package:camera_plugin/camera_plugin.dart' as camera_plugin;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // The image bytes captured by the camera.
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
  }

  // Wrap the captureImage call in a Future to avoid blocking the UI thread.
  Future<void> _captureImage() async {
    final Uint8List? _imageBytes = await camera_plugin.captureImage();
    if (_imageBytes == null) {
      return;
    }
    setState(() {
      imageBytes = _imageBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final bool result = camera_plugin.initializeCamera();
                    if (!result) {
                      print('Failed to initialize camera');
                    }
                  },
                  child: const Text('Initialize Camera'),
                ),
                ElevatedButton(
                  onPressed: imageBytes == null ? _captureImage : null,
                  child: const Text('Capture Image'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
