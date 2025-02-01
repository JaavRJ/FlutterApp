import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import '../model/models.dart'; 
import '../screens/task_detail_screen.dart'; 
import '../providers/task_provider.dart'; 

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> with AutomaticKeepAliveClientMixin<TaskList> {
  late DatabaseReference tasksRef;
  List<Task> _tasks = [];
  late StreamSubscription<DatabaseEvent> _tasksSubscription; // Cambia aquí

  @override
  void initState() {
    super.initState();
    _initializeTasks();
  }

  void _initializeTasks() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      tasksRef = FirebaseDatabase.instance.ref('tasks/$userId');
      _tasksSubscription = tasksRef.onValue.listen((event) {
        final tasksData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (tasksData != null) {
          final List<Task> loadedTasks = [];

          tasksData.forEach((key, value) {
            final task = Task.fromMap(key, value as Map<dynamic, dynamic>);
            loadedTasks.add(task);
          });

          // Ordena las tareas por fecha de vencimiento
          loadedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

          setState(() {
            _tasks = loadedTasks; // Actualiza la lista de tareas
          });

          _setTasks(context, _tasks); // Actualiza el proveedor
        }
      });
    }
  }

  @override
  void dispose() {
    _tasksSubscription.cancel(); // Asegúrate de cancelar la suscripción
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  super.build(context); // Para mantener el estado con AutomaticKeepAliveClientMixin

  return Scaffold(
    appBar: AppBar(
      title: const Text('Tasks'),
    ),
    body: _tasks.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0), // Bordes redondeados
                    ),
                    elevation: 4, // Sombra para la tarjeta
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(
                              title: task.title,
                              description: quill.Document.fromJson(
                                List<Map<String, dynamic>>.from(
                                  jsonDecode(task.description) as List<dynamic>,
                                ),
                              ),
                              dueDate: task.dueDate,
                              subject: task.subject,
                              taskId: task.id,
                              priority: task.priority,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Indicador de prioridad como un círculo
                            Container(
                              padding: const EdgeInsets.only(top: 50),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(task.priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Título de la tarea
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Fecha y materia
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Dead Line: ${DateFormat('MM-dd HH:mm').format(task.dueDate)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        task.subject,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Botón de completado
                            IconButton(
                              icon: Icon(
                                task.isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: task.isCompleted ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => _completeTask(context, task.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
  );
}


  Future<void> _completeTask(BuildContext context, String taskId) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    try {
      await taskProvider.completeTask(taskId);
    } catch (e) {
      print('Error completing task: $e'); // Imprime el error si ocurre
    }
  }

  Future<void> _setTasks(BuildContext context, List<Task> tasks) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.setTasks(tasks);
  }

    // Función para asignar colores según la prioridad
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color.fromARGB(255, 244, 174, 181)!; // Rojo pastel
      case 'Medium':
        return const Color.fromARGB(255, 254, 216, 158)!; // Naranja pastel
      case 'Low':
        return const Color.fromARGB(255, 169, 208, 240)!; // Azul pastel
      default:
        return Colors.grey[100]!; // Gris pastel por defecto
    }
  }

  @override
  bool get wantKeepAlive => false; // Mantiene el estado de la vista

  
}
