import 'dart:convert';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  bool isCompleted;
  final String subject;
  final String priority; // Nuevo campo para prioridad

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.subject,
    required this.priority, // Valor por defecto
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'subject': subject,
      'priority': priority, // Agregar prioridad

    };
  }

 factory Task.fromMap(String id, Map<dynamic, dynamic> map) {
  print('ID: $id');
  print('Map: $map');

  return Task(
    id: id,
    title: map['title'] ?? 'No Title',
    description: map['description'] ?? 'No Description',
    dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime(1970),
    isCompleted: map['isCompleted'] ?? false,
    subject: map['subject'] ?? 'No Subject',
    priority: map['priority'] ?? 'Low', // Agregar prioridad

  );
}

}


class Plant {
  int healthLevel;
  int waterLevel;
  DateTime lastWatered;
  int rewardPoints;

  Plant({
    this.healthLevel = 100,
    this.waterLevel = 100,
    required this.lastWatered,
    this.rewardPoints = 0,
  });

  // Convertir el objeto Plant a un Map para almacenarlo en Firebase
  Map<String, dynamic> toMap() {
    return {
      'healthLevel': healthLevel,
      'waterLevel': waterLevel,
      'lastWatered': lastWatered.toIso8601String(), // Convertir a string
      'rewardPoints': rewardPoints,
    };
  }

  // Crear un objeto Plant a partir de un Map de Firebase
  factory Plant.fromMap(Map<dynamic, dynamic> map) {
    return Plant(
      healthLevel: map['healthLevel'] ?? 100,
      waterLevel: map['waterLevel'] ?? 100,
      lastWatered: DateTime.parse(map['lastWatered'] ?? DateTime.now().toIso8601String()),
      rewardPoints: map['rewardPoints'] ?? 0,
    );
  }

  // Convertir el objeto Plant a un formato JSON
  String toJson() => jsonEncode(toMap());

  // Crear un objeto Plant a partir de un JSON
  factory Plant.fromJson(String source) => Plant.fromMap(jsonDecode(source));
}
