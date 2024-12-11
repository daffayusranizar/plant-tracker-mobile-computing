import 'package:flutter/material.dart';
import 'dart:io';

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;

  FullScreenImagePage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pop(); // Close the full-screen mode when tapped
          },
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain, // Ensure the image stays within the screen
          ),
        ),
      ),
    );
  }
}
