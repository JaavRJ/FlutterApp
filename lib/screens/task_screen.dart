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
          title: const Text(
            'WhaleTasks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1)),
          ),
          elevation: 2,
          backgroundColor: const Color.fromARGB(255, 248, 196, 140), // Moderno color púrpura
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Tasks'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
              Tab(icon: Icon(Icons.eco), text: 'Plant'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Color.fromRGBO(67, 67, 67, 1),),
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
            // Lista de tareas y estado de la planta
            Column(
              children: [
                Expanded(
                  child: TaskList(),
                ),
                SizedBox(height: 16), // Espaciado entre los widgets
                PlantStatus(),
              ],
            ),
            // Pantalla de calendario
            CalendarScreen(),
            // Estado de la planta
            PlantStatus(),
          ],
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: const Color.fromARGB(255, 248, 196, 140), // Color consistente con la barra de app
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.add_task_outlined, color: Color.fromARGB(255, 121, 121, 121)),
              backgroundColor: const Color.fromARGB(255, 243, 252, 244),
              label: 'Add Task',
              labelStyle: const TextStyle(fontSize: 16),
              onTap: () => _addTask(context),
            ),
            SpeedDialChild(
              child: const Icon(Icons.brush, color: Color.fromARGB(255, 121, 121, 121)),
              backgroundColor: const Color.fromARGB(255, 243, 246, 252),
              label: 'Add Doodle',
              labelStyle: const TextStyle(fontSize: 16),
              onTap: () => _addDoodle(context),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF9F9F9), // Fondo claro para contraste
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

  // Navegar a la pantalla de agregar tarea
  void _addTask(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const AddTaskScreen(),
    ));
  }

  // Navegar a la pantalla de agregar doodle
  void _addDoodle(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const AddDoodleScreen(),
    ));
  }
}
