import 'package:flutter/material.dart';
import 'package:plant_tracker/databases/database_helper.dart';
import 'package:plant_tracker/databases/plant.dart';
import 'package:plant_tracker/databases/plant_growth.dart';
import 'package:plant_tracker/pages/plant_growth_detail_page.dart';
import 'dart:io';

class PlantDetailPage extends StatefulWidget {
  final int plantId;

  PlantDetailPage({required this.plantId});

  @override
  _PlantDetailPageState createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  Plant? plant;
  List<PlantGrowth> growthList = [];

  @override
  void initState() {
    super.initState();
    _fetchPlantDetails();
    _fetchGrowthProgress();
  }

  Future<void> _fetchPlantDetails() async {
    plant = await dbHelper.readPlant(widget.plantId);
    setState(() {});
  }

  Future<void> _fetchGrowthProgress() async {
    growthList = await dbHelper.readAllPlantGrowths(widget.plantId);
    setState(() {});
  }

  void _showUpdatePlantForm() {
    final _formKey = GlobalKey<FormState>();
    String? name = plant?.name;
    List<TimeOfDay> wateringTimes = plant?.wateringTimes ?? [];
    bool stillProgress = plant?.stillProgress ?? true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Plant"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(labelText: "Plant Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a plant name';
                      }
                      return null;
                    },
                    onSaved: (value) => name = value,
                  ),
                  // Watering Times section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Watering Times:"),
                      ...wateringTimes.map((time) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${time.hour}:${time.minute.toString().padLeft(2, '0')}'),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  wateringTimes
                                      .remove(time); // Remove selected time
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay
                                .now(), // This should be capturing the current time correctly
                          );
                          if (time != null) {
                            setState(() {
                              wateringTimes
                                  .add(time); // Add selected time to the list
                            });
                          }
                        },
                        child: Text("Add Watering Time"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Still in Progress"),
                      Checkbox(
                        value: stillProgress,
                        onChanged: (value) {
                          setState(() {
                            stillProgress = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
            TextButton(
              child: Text("Update"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _updatePlant(name!, wateringTimes, stillProgress);
                  Navigator.of(context).pop(); // Close dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePlant(
      String name, List<TimeOfDay> wateringTimes, bool stillProgress) async {
    final updatedPlant = Plant(
      id: plant?.id,
      name: name,
      wateringTimes: wateringTimes,
      stillProgress: stillProgress,
      growthStartDate: plant?.growthStartDate ??
          DateTime.now(), // Keep original growth start date
    );

    await dbHelper.updatePlant(updatedPlant);
    _fetchPlantDetails(); // Refresh the plant details
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plant Details"),
        backgroundColor: Colors.green,
      ),
      body: plant == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Display Plant Details in a Card
                  Card(
                    margin: EdgeInsets.all(16.0),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant!.name,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Still in Progress: ${plant!.stillProgress ? 'Yes' : 'No'}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Growth Start Date: ${plant!.growthStartDate.toLocal().toString().split(' ')[0]}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Watering Times: ${plant!.wateringTimes.map((time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}').join(', ')}",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:
                                _showUpdatePlantForm, // Call the update form
                            child: Text("Update Plant"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 2),
                  // Divider for Growth Records
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Growth Records",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Display Growth Records
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
                    itemCount: growthList.length,
                    itemBuilder: (context, index) {
                      final growth = growthList[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text("Day ${growth.dayCount}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProgressDetailPage(growthRecord: growth),
                              ),
                            );
                          },
                          trailing: growth.image.isNotEmpty
                              ? ClipOval(
                                  child: Image.file(
                                    File(growth.image),
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
