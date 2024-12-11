import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Required for directory access

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription> cameras = [];
  CameraController? controller;
  Future<void>? _initControllerFuture;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(
      cameras[0], // Get the first camera
      ResolutionPreset.high,
    );
    _initControllerFuture = controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose(); // Cleanup the controller when the widget is disposed
    super.dispose();
  }

  Future<void> takePicture() async {
    try {
      await _initControllerFuture; // Ensure the camera is initialized
      final XFile image = await controller!
          .takePicture(); // Capture image without specifying a path

      // Retrieve the path from the XFile object
      final imagePath = image.path;

      // Consider moving the image file if you want it in a permanent directory
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      final newImage = await File(imagePath).copy(path);

      // Return the new image path to the previous page
      Navigator.pop(context, newImage.path);
    } catch (e) {
      print('Error taking picture: $e');
      Navigator.pop(
          context); // Handle any error and return to the previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: FutureBuilder<void>(
        future: _initControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(controller!), // Show camera preview
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0), // Add some padding
                  child: ElevatedButton(
                    onPressed: takePicture, // Capture image on button press
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(), // Make it circular
                      padding: EdgeInsets.all(20), // Adjust the size
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 30, // Adjust the icon size
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
                child:
                    CircularProgressIndicator()); // While loading, show progress indicator
          }
        },
      ),
    );
  }
}
