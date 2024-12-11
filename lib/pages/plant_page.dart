import 'package:flutter/material.dart';
import 'package:plant_tracker/databases/database_helper.dart';
import 'package:plant_tracker/databases/plant.dart';
import 'package:plant_tracker/pages/plant_growth_page.dart'; // Import the progress page
import 'package:plant_tracker/pages/plant_detail_page.dart'; // Import the new PlantDetailPage
import 'package:plant_tracker/utils/notification_services.dart';

class PlantPage extends StatefulWidget {
  @override
  _PlantPageState createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Plant> plants = [];

  @override
  void initState() {
    super.initState();
    _fetchPlants();
  }

  Future<void> _fetchPlants() async {
    plants = await dbHelper.readAllPlants();
    print('Fetched ${plants.length} plants from the database.');
    setState(() {});
  }

  void _showAddPlantForm() {
    final _formKey = GlobalKey<FormState>();
    String? name;
    List<TimeOfDay> wateringTimes = []; // List to hold watering times
    bool stillProgress = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Plant"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: "Plant Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a plant name';
                      }
                      return null;
                    },
                    onSaved: (value) => name = value,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
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
                  // Display selected watering times
                  Text("Selected Watering Times:"),
                  ...wateringTimes.map((time) {
                    return Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}');
                  }).toList(),
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _addPlant(name!, wateringTimes, stillProgress);
                  Navigator.of(context).pop(); // Close dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPlant(
      String name, List<TimeOfDay> wateringTimes, bool stillProgress) async {
    final newPlant = Plant(
      name: name,
      wateringTimes: wateringTimes,
      stillProgress: stillProgress,
      growthStartDate: DateTime.now(),
    );

    // Insert the new plant into the database
    Plant plant_new = await dbHelper.createPlant(newPlant);
    await NotificationService.showPlantNotification(
        context: context, plant: plant_new);
    _fetchPlants(); // Refresh the list of plants
  }

  Future<void> _deletePlant(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this plant?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await dbHelper.deletePlant(id);
      _fetchPlants(); // Refresh the list after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plant Tracker"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddPlantForm, // Function to open the add plant form
          ),
          IconButton(
            icon: Icon(Icons.add_chart), // Icon to represent plant progress
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlantProgressPage()),
              );
            }, // Navigate to the Plant Growth Page
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen[50]!, Colors.green[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return Card(
              elevation: 4, // Adds shadow for a raised effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  plant.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Still in Progress: ${plant.stillProgress ? 'Yes' : 'No'}"),
                    Text(
                        "Watering Times: ${plant.wateringTimes.map((time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}').join(', ')}"),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePlant(plant.id!), // Delete plant
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantDetailPage(plantId: plant.id!),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
