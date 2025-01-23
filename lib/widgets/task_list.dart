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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareitas'),
      ),
      body: _tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Container(
                  color: _getPriorityColor(task.priority),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      'Fecha Limite: ${DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate)}\nMateria: ${task.subject}',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                        color: task.isCompleted ? Colors.green : null,
                      ),
                      onPressed: () => _completeTask(context, task.id),
                    ),
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
                  ),
                );
              },
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
        return Colors.red[100]!; // Rojo pastel
      case 'Medium':
        return Colors.orange[100]!; // Naranja pastel
      case 'Low':
        return Colors.blue[100]!; // Azul pastel
      default:
        return Colors.grey[100]!; // Gris pastel por defecto
    }
  }

  @override
  bool get wantKeepAlive => false; // Mantiene el estado de la vista

  
}
