import 'package:flutter/material.dart';
import 'package:plant_tracker/databases/database_helper.dart';
import 'package:plant_tracker/databases/plant.dart';
import 'package:plant_tracker/databases/plant_growth.dart';
import 'package:plant_tracker/pages/camera_page.dart';
import 'dart:io'; // Import for File class

class PlantProgressPage extends StatefulWidget {
  @override
  _PlantProgressPageState createState() => _PlantProgressPageState();
}

class _PlantProgressPageState extends State<PlantProgressPage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  List<Plant> plants = [];
  int? selectedPlantId;
  String image = ""; // Holding the path of the image
  String notes = "";

  @override
  void initState() {
    super.initState();
    _fetchPlants(); // Fetch plants when the page initializes
  }

  Future<void> _fetchPlants() async {
    plants = await dbHelper.readAllPlants();
    setState(() {});
  }

  Future<void> _addPlantGrowth() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form fields
      final newGrowth = PlantGrowth(
        plantId: selectedPlantId!,
        growthDate: DateTime.now(), // Set the growth date to now
        image: image, // The path of the captured image
        notes: notes,
      );
      await dbHelper.createPlantGrowth(newGrowth);
      Navigator.pop(context); // Close the page after adding
    }
  }

  Future<void> _openCamera() async {
    // Navigate to the CameraPage
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage()),
    );
    // If the result is not null, update the image path
    if (result != null && result is String) {
      setState(() {
        image = result; // Update the image with the captured path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Plant Progress"),
        backgroundColor: Colors.green,
      ),
      body: plants.isEmpty // Check if plants are loaded
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.lightGreen[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(labelText: 'Select Plant'),
                      value: selectedPlantId,
                      items: plants.map((plant) {
                        return DropdownMenuItem<int>(
                          value: plant.id,
                          child: Text(plant.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPlantId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a plant' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Notes"),
                      onSaved: (value) => notes = value ?? '',
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _openCamera, // Open camera to take a picture
                      child: Text("Open Camera"),
                    ),
                    SizedBox(height: 20),
                    if (image.isNotEmpty) // Only show if image path is present
                      Column(
                        children: [
                          Text("Preview Image:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(image),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addPlantGrowth,
                      child: Text("Add Progress"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
