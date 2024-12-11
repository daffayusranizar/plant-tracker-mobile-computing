import 'package:flutter/material.dart';
import 'package:plant_tracker/databases/database_helper.dart';
import 'package:plant_tracker/databases/plant.dart';
import 'package:plant_tracker/databases/plant_growth.dart';
import 'package:plant_tracker/pages/plant_growth_detail_page.dart';
import 'dart:io';

class PlantProgressListPage extends StatefulWidget {
  @override
  _PlantProgressListPageState createState() => _PlantProgressListPageState();
}

class _PlantProgressListPageState extends State<PlantProgressListPage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Plant> plants = [];
  List<PlantGrowth> growthList = [];
  int? selectedPlantId;

  @override
  void initState() {
    super.initState();
    _fetchPlants(); // Fetch plants when the page initializes
  }

  Future<void> _fetchPlants() async {
    plants = await dbHelper.readAllPlants();
    setState(() {});
  }

  Future<void> _fetchGrowthProgress(int plantId) async {
    growthList = await dbHelper.readAllPlantGrowths(plantId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plant Growth Progress"),
        backgroundColor: Colors.green, // Change app bar color
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen[100]!, Colors.green[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Plant',
                  labelStyle: TextStyle(color: Colors.black87),
                  filled: true, // Use filled color for the dropdown
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black38),
                  ),
                ),
                value: selectedPlantId,
                items: plants.map((plant) {
                  return DropdownMenuItem<int>(
                    value: plant.id,
                    child: Text(plant.name,
                        style: TextStyle(color: Colors.black87)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPlantId = value;
                    _fetchGrowthProgress(
                        value!); // Fetch growth progress on select
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: growthList.length,
                itemBuilder: (context, index) {
                  final growth = growthList[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to ProgressDetailPage when growth item is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProgressDetailPage(growthRecord: growth),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4, // Adds elevation for depth
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Text("Day: ${growth.dayCount}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Notes: ${growth.notes}"),
                        leading: growth.image.isNotEmpty
                            ? ClipOval(
                                child: Image.file(
                                  File(growth.image),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.image,
                                size: 70), // Placeholder icon if no image
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
