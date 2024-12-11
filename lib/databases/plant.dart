import 'package:flutter/material.dart';

class Plant {
  final int? id; // Nullable for autoincrement
  final String name;
  final List<TimeOfDay> wateringTimes; // List of specific watering times
  final bool stillProgress;
  final DateTime growthStartDate; // Growth start date

  Plant({
    this.id,
    required this.name,
    required this.wateringTimes,
    required this.stillProgress,
    required this.growthStartDate, // Initialize growth start date
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'wateringTimes': wateringTimes
          .map((time) => '${time.hour}:${time.minute}')
          .toList()
          .join(','), // Store watering times as a comma-separated string
      'stillProgress': stillProgress ? 1 : 0,
      'growthStartDate':
          growthStartDate.toIso8601String(), // Store growth start date
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    List<String> times = (map['wateringTimes'] as String).split(',');
    List<TimeOfDay> wateringTimes = times.map((time) {
      final hourMinute = time.split(':');
      return TimeOfDay(
          hour: int.parse(hourMinute[0]), minute: int.parse(hourMinute[1]));
    }).toList();

    return Plant(
      id: map['id'],
      name: map['name'] ?? 'Unnamed Plant',
      wateringTimes: wateringTimes,
      stillProgress: map['stillProgress'] == 1,
      growthStartDate: DateTime.parse(map['growthStartDate']), // Parse date
    );
  }

  Plant copy({int? id}) => Plant(
        id: id ?? this.id,
        name: name,
        wateringTimes: wateringTimes,
        stillProgress: stillProgress,
        growthStartDate: growthStartDate,
      );
}
