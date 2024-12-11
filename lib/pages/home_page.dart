import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:plant_tracker/databases/database_helper.dart';
import 'package:plant_tracker/databases/plant_growth.dart';
import 'package:plant_tracker/databases/plant.dart';
import 'package:plant_tracker/pages/all_plant_growth_page.dart';
import 'package:plant_tracker/pages/plant_detail_page.dart';
import 'package:plant_tracker/pages/plant_growth_detail_page.dart';
import 'package:plant_tracker/pages/plant_growth_page.dart';
import 'package:plant_tracker/pages/plant_page.dart';
import 'dart:io';
import 'package:plant_tracker/utils/notification_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Plant> newestPlants = [];
  List<PlantGrowth> recentPlantGrowths = [];

  @override
  void initState() {
    super.initState();
    NotificationService.init(); // Initialize notification service
    _fetchNewestPlants();
    _fetchRecentPlantGrowths();
  }

  Future<void> _fetchNewestPlants() async {
    newestPlants = await dbHelper.readAllPlants();
    newestPlants.sort((a, b) => b.id!.compareTo(a.id!));
    if (newestPlants.length > 5) {
      newestPlants = newestPlants.take(5).toList();
    }
    setState(() {});
  }

  Future<void> _fetchRecentPlantGrowths() async {
    recentPlantGrowths = [];
    final plants = await dbHelper.readAllPlants();
    if (plants.isNotEmpty) {
      for (var plant in plants) {
        final growths = await dbHelper.readAllPlantGrowths(plant.id!);
        recentPlantGrowths.addAll(growths);
        print(
            'Fetched ${growths.length} growth records for plant ID ${plant.id}');
      }
      recentPlantGrowths.sort((a, b) => b.id!.compareTo(a.id!));
      if (recentPlantGrowths.length > 5) {
        recentPlantGrowths = recentPlantGrowths.take(5).toList();
      }
    }
    print('Total recent growth records fetched: ${recentPlantGrowths.length}');
    setState(() {});
  }

  void _addPlantProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlantProgressPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Tracker',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
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
        child: Column(
          children: [
            // Carousel for plant growth progress
            SizedBox(height: 20),
            Text('Recent Progress',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            recentPlantGrowths.isEmpty
                ? Container(
                    height: 200,
                    child: Center(child: Text('No recent progress available.')),
                  )
                : CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      viewportFraction: 0.8,
                    ),
                    items: recentPlantGrowths.map((growth) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to ProgressDetailPage on tap
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProgressDetailPage(growthRecord: growth),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 3), // Changes position of shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Day Count: ${growth.dayCount}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                if (growth.image
                                    .isNotEmpty) // Show image if available
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(growth.image),
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            SizedBox(height: 20),
            // Display 5 newest plants
            Text('Newest Plants',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: newestPlants.length,
                itemBuilder: (context, index) {
                  final plant = newestPlants[index];
                  return Card(
                    child: ListTile(
                      title: Text(plant.name),
                      subtitle: Text(
                        "Watering Times: ${plant.wateringTimes.map((time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}').join(', ')}",
                      ), // Show watering times instead of frequency
                      onTap: () {
                        // Navigate to PlantDetailPage when tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlantDetailPage(plantId: plant.id!),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Plants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Progress',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlantPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlantProgressListPage()),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlantProgress,
        child: Icon(Icons.add), // Icon for adding progress
        backgroundColor: Colors.green,
      ),
    );
  }
}
