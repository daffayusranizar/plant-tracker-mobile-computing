import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'plant.dart'; // Import your Plant model
import 'plant_growth.dart'; // If necessary, import your PlantGrowth model
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('plant_care_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        wateringTimes TEXT NOT NULL, -- Store watering times as a comma-separated string
        stillProgress INTEGER NOT NULL,
        growthStartDate TEXT NOT NULL -- Store as string for the date
      )
    ''');

    await db.execute('''
      CREATE TABLE plant_growth (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plantId INTEGER NOT NULL,
        growthDate TEXT NOT NULL, -- Store growth date as string
        image TEXT NOT NULL,
        notes TEXT NOT NULL,
        dayCount INTEGER NOT NULL, -- Store day count
        FOREIGN KEY (plantId) REFERENCES plants (id) ON DELETE CASCADE
      )
    ''');
  }

  // Plant CRUD operations
  Future<Plant> createPlant(Plant plant) async {
    final db = await instance.database;
    final id = await db.insert('plants', plant.toMap());
    return plant.copy(id: id); // Create a new plant object with the new ID
  }

  Future<List<Plant>> readAllPlants() async {
    final db = await instance.database;
    final result = await db.query('plants');
    return result.map((json) => Plant.fromMap(json)).toList();
  }

  Future<Plant?> readPlant(int id) async {
    final db = await instance.database;
    final result =
        await db.query('plants', where: 'id = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty ? Plant.fromMap(result.first) : null;
  }

  Future<int> updatePlant(Plant plant) async {
    final db = await instance.database;
    return db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  Future<int> deletePlant(int id) async {
    final db = await instance.database;
    return await db.delete('plants', where: 'id = ?', whereArgs: [id]);
  }

  // PlantGrowth CRUD operations - if you want to include these
  Future<PlantGrowth> createPlantGrowth(PlantGrowth plantGrowth) async {
    final db = await instance.database;
    final id = await db.insert('plant_growth', plantGrowth.toMap());
    return plantGrowth.copy(id: id);
  }

  Future<List<PlantGrowth>> readAllPlantGrowths(int plantId) async {
    final db = await instance.database;
    final result = await db
        .query('plant_growth', where: 'plantId = ?', whereArgs: [plantId]);
    return result.map((json) => PlantGrowth.fromMap(json)).toList();
  }

  Future<PlantGrowth?> readPlantGrowth(int id) async {
    final db = await instance.database;
    final result = await db.query('plant_growth',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty ? PlantGrowth.fromMap(result.first) : null;
  }

  Future<int> updatePlantGrowth(PlantGrowth plantGrowth) async {
    final db = await instance.database;
    return db.update(
      'plant_growth',
      plantGrowth.toMap(),
      where: 'id = ?',
      whereArgs: [plantGrowth.id],
    );
  }

  Future<int> deletePlantGrowth(int id) async {
    final db = await instance.database;
    return await db.delete('plant_growth', where: 'id = ?', whereArgs: [id]);
  }
}
