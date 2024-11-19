import 'package:flutter/material.dart';
import '../model/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final Plant _plant = Plant(healthLevel: 100, waterLevel: 100, rewardPoints: 0, lastWatered: DateTime.now());

  List<Task> get tasks => _tasks;
  Plant get plant => _plant;

  void setTasks(List<Task> tasks) {
    _tasks = tasks;
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> completeTask(String taskId) async {
    print('si estamos recibiendo el llamado: $taskId');

    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    print('taskindex: $taskIndex');
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      String subject = task.subject;
      print('la que se supone es la tarea: $subject');
      task.isCompleted = !task.isCompleted;
      print(task.isCompleted);
      _tasks[taskIndex] = task; // Asegúrate de actualizar la tarea en la lista
      notifyListeners();

      // Actualizar el estado de la planta si la tarea se completa
      if (task.isCompleted) {
        _plant.healthLevel += 5; // Incremento de salud
        _plant.waterLevel -= 5;  // Decremento de agua
        _plant.rewardPoints += 10; // Incremento de puntos
        _plant.lastWatered = DateTime.now();
        notifyListeners();

        // Actualizar el estado de la planta en Firebase
        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseDatabase.instance
              .ref('plant/$userId')
              .set(_plant.toMap());

          print('pasa esta madre de la plant');  
        }
      }

      // Actualizar el estado de la tarea en Firebase
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        print('Si llega hasta el completed');
        await FirebaseDatabase.instance
            .ref('tasks/$userId/$taskId')
            .update({'isCompleted': task.isCompleted});
      }
    }
  }


  void waterPlant() {
    _plant.waterLevel += 10;
    _plant.healthLevel += 10;
    _plant.rewardPoints += 10;
    _plant.lastWatered = DateTime.now();
    notifyListeners();

    // Actualizar el estado de la planta en Firebase
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseDatabase.instance
          .ref('plant/$userId')
          .set(_plant.toMap());
    }
  }
}
