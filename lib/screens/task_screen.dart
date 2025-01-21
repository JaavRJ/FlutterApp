import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Importa el paquete speed_dial
import 'add_task_screen.dart';
import 'add_doodle_screen.dart';
import '../widgets/plant_status.dart';
import '../widgets/task_list.dart';
import 'auth_screen.dart';
import 'calendar_screen.dart'; // Importar la pantalla del calendario
class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WhaleTasks'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tareas'),
              Tab(text: 'Calendario'),
              Tab(text: 'Planta'),

            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                );
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            Column(
              children: [
                Expanded(child: TaskList()),
               PlantStatus(), //aqui va el ottro
              ],
            ),
            CalendarScreen(),
            PlantStatus(),

          ],
        ),
          floatingActionButton: SpeedDial(
            animatedIcon: AnimatedIcons.add_event,
            backgroundColor: const Color.fromRGBO(178, 172, 231, 1),
            children: [
              SpeedDialChild(
                child: const Icon(Icons.add),
                label: 'Agregar Tarea',
                onTap: () => _addTask(context),
              ),
              SpeedDialChild(
                child: const Icon(Icons.draw),
                label: 'Agregar Doodle',
                onTap: () => _addDoodle(context),
              ),
            ],
          ),
      ),
    );
  }

  void _addTask(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const AddTaskScreen(),
    ));
  } 
  
  void _addDoodle(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const AddDoodleScreen(),
    ));
  }
}
