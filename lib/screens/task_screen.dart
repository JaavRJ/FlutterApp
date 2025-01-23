import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Importa el paquete speed_dial
import 'add_task_screen.dart';
import 'add_doodle_screen.dart';
import '../widgets/plant_status.dart';
import '../widgets/task_list.dart';
import 'auth_screen.dart';
import 'calendar_screen.dart'; // Importar la pantalla del calendario
import 'enter_subjects_screen.dart'; // Importar la pantalla de ingreso de materias

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Llamar a la función que verifica si el usuario es nuevo
    _checkIfNewUser(context);

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
                PlantStatus(),
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

  // Verificar si el usuario es nuevo y redirigirlo a la pantalla de ingreso de materias
  Future<void> _checkIfNewUser(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}/subjects');
    final snapshot = await userRef.once();
  
    if (snapshot.snapshot.value == null) {
      // El usuario no tiene materias, lo redirigimos a la pantalla para ingresarlas
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EnterSubjectsScreen()),
      );
    }
  }
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
