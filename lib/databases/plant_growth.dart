class PlantGrowth {
  final int? id; // Nullable for autoincrement
  final int plantId; // Foreign key linking to Plant
  final DateTime growthDate; // Date of this growth record
  final String image; // Image file path
  final String notes; // Notes recorded for this growth entry
  final int dayCount; // Automatically calculated day count

  PlantGrowth({
    this.id,
    required this.plantId,
    required this.growthDate, // This can represent the date of this growth
    required this.image,
    required this.notes,
  }) : dayCount = _calculateDayCount(growthDate); // Calculate day count

  static int _calculateDayCount(DateTime growthDate) {
    final now = DateTime.now();
    int dayCount = now.difference(growthDate).inDays;
    return dayCount + 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantId': plantId,
      'growthDate': growthDate.toIso8601String(), // Store growth date as string
      'image': image,
      'notes': notes,
      'dayCount': dayCount, // Store day count, useful for retrieval
    };
  }

  factory PlantGrowth.fromMap(Map<String, dynamic> map) {
    return PlantGrowth(
      id: map['id'],
      plantId: map['plantId'],
      growthDate: DateTime.parse(map['growthDate']),
      image: map['image'],
      notes: map['notes'],
    );
  }

  PlantGrowth copy({int? id}) => PlantGrowth(
        id: id ?? this.id,
        plantId: plantId,
        growthDate: growthDate,
        image: image,
        notes: notes,
      );
}
