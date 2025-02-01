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
  late StreamSubscription<DatabaseEvent> _tasksSubscription;

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

          loadedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

          setState(() {
            _tasks = loadedTasks;
          });

          _setTasks(context, _tasks);
        }
      });
    }
  }

  @override
  void dispose() {
    _tasksSubscription.cancel();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  super.build(context);

  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday));
  final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
  final startOfNextWeek = startOfWeek.add(const Duration(days: 7));

  final lastWeekTasks = _tasks.where((task) => task.dueDate.isAfter(startOfLastWeek) && task.dueDate.isBefore(startOfWeek)).toList();
  final thisWeekTasks = _tasks.where((task) => task.dueDate.isAfter(startOfWeek) && task.dueDate.isBefore(startOfNextWeek)).toList();
  final nextWeekTasks = _tasks.where((task) => task.dueDate.isAfter(startOfNextWeek)).toList();

  return Scaffold(
    body: _tasks.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0), 
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView( // Agregado para el scroll
                  child: constraints.maxWidth > 600
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTaskColumn('Last Week', lastWeekTasks)),
                            Expanded(child: _buildTaskColumn('This Week', thisWeekTasks)),
                            Expanded(child: _buildTaskColumn('Next Weeks', nextWeekTasks)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildTaskColumn('Last Week', lastWeekTasks),
                            _buildTaskColumn('This Week', thisWeekTasks),
                            _buildTaskColumn('Next Weeks', nextWeekTasks),
                          ],
                        ),
                );
              },
            ),
          ),
  );
}


  Widget _buildTaskColumn(String title, List<Task> tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
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
                            padding: const EdgeInsets.only(top: 70),
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
                                    fontSize: 13,
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
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      task.subject,
                                      style: const TextStyle(
                                        fontSize: 10,
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
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color.fromARGB(255, 244, 174, 181); // Rojo pastel
      case 'Medium':
        return const Color.fromARGB(255, 254, 216, 158); // Naranja pastel
      case 'Low':
        return const Color.fromARGB(255, 169, 208, 240); // Azul pastel
      default:
        return Colors.grey[100]!; // Gris pastel por defecto
    }
  }

  Future<void> _completeTask(BuildContext context, String taskId) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    try {
      await taskProvider.completeTask(taskId);
    } catch (e) {
      print('Error completing task: $e');
    }
  }

  Future<void> _setTasks(BuildContext context, List<Task> tasks) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.setTasks(tasks);
  }

  @override
  bool get wantKeepAlive => false;
}
