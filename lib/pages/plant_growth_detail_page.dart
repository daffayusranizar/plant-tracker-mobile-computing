import 'package:flutter/material.dart';
import 'package:plant_tracker/databases/plant_growth.dart';
import 'dart:io';
import 'package:plant_tracker/pages/full_screen_image_page.dart';

class ProgressDetailPage extends StatelessWidget {
  final PlantGrowth growthRecord;

  ProgressDetailPage({required this.growthRecord});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Growth Progress Detail"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Day: ${growthRecord.dayCount}",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // Display image with click effect for full screen
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullScreenImagePage(imagePath: growthRecord.image),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(growthRecord.image),
                  height: 200, // Adjust height as necessary
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            // Put notes below the image
            Text(
              "Notes:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              growthRecord.notes,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
