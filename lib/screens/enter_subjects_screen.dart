import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:whaletasks/screens/task_screen.dart';

class EnterSubjectsScreen extends StatefulWidget {
  const EnterSubjectsScreen({super.key});

  @override
  _EnterSubjectsScreenState createState() => _EnterSubjectsScreenState();
}

class _EnterSubjectsScreenState extends State<EnterSubjectsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  List<String> _subjects = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Your Subjects')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {
                      _subjects.add(_subjectController.text);
                      _subjectController.clear();
                    });
                  }
                },
                child: const Text('Add Subject'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_subjects[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null && _subjects.isNotEmpty) {
                    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

                    // Recuperar los datos actuales del usuario
                    final snapshot = await userRef.once();
                    
                    // Manejar casos donde no hay datos (snapshot.snapshot.value == null)
                    Map<String, dynamic> currentUserData = {};
                    if (snapshot.snapshot.value != null) {
                      // Convertir el LinkedMap a Map<String, dynamic>
                      currentUserData = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
                    }

                    // Si ya existe el campo 'subjects', agregar las nuevas materias
                    if (currentUserData.containsKey('subjects')) {
                      List<dynamic> currentSubjects = List.from(currentUserData['subjects'] ?? []);
                      currentSubjects.addAll(_subjects); // Agregar las nuevas materias
                      currentUserData['subjects'] = currentSubjects; // Actualizar el campo 'subjects'
                    } else {
                      // Si no existe el campo 'subjects', crearlo
                      currentUserData['subjects'] = _subjects;
                    }

                    // Actualizar solo el campo 'subjects' sin sobrescribir los demás
                    await userRef.update({
                      'subjects': currentUserData['subjects'],
                    });

                    // Redirigir a la pantalla principal o siguiente
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const TaskScreen()),
                    );
                  }
                },
                child: const Text('Save Subjects'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
