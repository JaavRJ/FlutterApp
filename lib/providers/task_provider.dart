import 'package:flutter/material.dart';
import '../model/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TaskProvider with ChangeNotifier {
  
  List<Task> _tasks = [];
  final Plant _plant = Plant(healthLevel: 100, waterLevel: 100, rewardPoints: 0, lastWatered: DateTime.now());
    Color? _themeColor;


  List<Task> get tasks => _tasks;
  Plant get plant => _plant;

  void setTasks(List<Task> tasks) {
    _tasks = tasks;
    notifyListeners();
  }

  void setTheme(Color color) {
    _themeColor = color;
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }



  
    Color get themeColor => _themeColor ?? const Color.fromARGB(255, 248, 196, 140);

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



  // Función para cambiar el color del tema
  Future<void> changeThemeColor(Color color) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

      // Actualizar el color del tema en Firebase
      await userRef.update({
        'themeColor': color.value, // Guardar el valor del color (hexadecimal)
      });

      _themeColor = color;
      print(_themeColor);
      notifyListeners(); // Notificar a los oyentes (para que se redibuje la UI)
    }
  }

  // Cargar el color del tema desde Firebase
Future<void> loadThemeColor() async {
  print('Si se llama la función loadTheme');
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
    final snapshot = await userRef.get();

    if (snapshot.exists && snapshot.value != null) {
      // Convertir snapshot.value en un Map<String, dynamic> correctamente
      final Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
      
      if (userData.containsKey('themeColor')) {
        final int colorValue = userData['themeColor'];
        _themeColor = Color(colorValue); // Convertir el valor a Color
        print(colorValue);
        print(_themeColor);
        notifyListeners(); // Notificar a los listeners para actualizar la UI
      }
    }
  }
}}
