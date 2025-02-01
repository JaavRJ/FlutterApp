import 'dart:convert';
import 'package:flutter/material.dart';
import '../screens/task_detail_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/models.dart'; // Asegúrate de usar la ruta correcta para el modelo Task
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>  with AutomaticKeepAliveClientMixin<CalendarScreen> {
  Map<DateTime, List<Task>> _tasksByDate = {};
  DateTime _focusedDay = DateTime.now();
  late DatabaseReference tasksRef;

  @override
  void initState() {
    super.initState();
    _initializeTasks();
  }

  void _initializeTasks() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      tasksRef = FirebaseDatabase.instance.ref('tasks/$userId');
      tasksRef.onValue.listen((event) {
        final tasksData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (tasksData != null) {
          final Map<DateTime, List<Task>> loadedTasks = {};

          tasksData.forEach((key, value) {
            final task = Task.fromMap(key, value as Map<dynamic, dynamic>);
            final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);

            if (loadedTasks[taskDate] == null) {
              loadedTasks[taskDate] = [task];
            } else {
              loadedTasks[taskDate]!.add(task);
            }
          });

          setState(() {
            _tasksByDate = loadedTasks;
          });
        }
      });
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasksByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // Función para asignar colores según la prioridad
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': // Alta prioridad
        return Colors.red;
      case 'Medium': // Media prioridad
        return Colors.orange;
      case 'Low': // Baja prioridad
        return Colors.blue;
      default: // Prioridad por defecto
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            eventLoader: _getTasksForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              
            },
            // Modifica la apariencia de los eventos
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final task = events[index] as Task;
                      return Container(
                        margin: const EdgeInsets.all(2.0),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getPriorityColor(task.priority),
                        ),
                      );
                    },
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _getTasksForDay(_focusedDay).length,
              itemBuilder: (context, index) {
                final task = _getTasksForDay(_focusedDay)[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.subject),
                  trailing: Icon(
                    task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.isCompleted ? Colors.green : null,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true; // Mantiene el estado de la vista
}
