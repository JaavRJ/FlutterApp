import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import '../../model/models.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  late quill.QuillController _descriptionController;
  DateTime _dueDate = DateTime.now();
  String? _subject; // Ahora será nullable
  String _priority = 'Low';
  int _currentStep = 0;
  List<String> _subjects = []; // Lista de materias del usuario

  @override
  void initState() {
    super.initState();
    _descriptionController = quill.QuillController.basic();
    _loadSubjects(); // Cargar las materias desde Firebase
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Método para cargar las materias del usuario desde Firebase
  Future<void> _loadSubjects() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}/subjects');
    final snapshot = await userRef.get();

    if (snapshot.value != null) {
      final data = snapshot.value;
      debugPrint('Raw subjects data from Firebase: $data'); // Para depuración

      setState(() {
        if (data is List) {
          _subjects = List<String>.from(data);
        } else if (data is Map) {
          _subjects = data.values.map((e) => e.toString()).toList();
        }

        if (_subjects.isNotEmpty) {
          _subject = _subjects.first;
        }
      });
    } else {
      debugPrint('No subjects found in Firebase.');
      setState(() {
        _subjects = [];
        _subject = null;
      });
    }
  }
}


  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );

      if (selectedTime != null) {
        setState(() {
          _dueDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              if (_title.isEmpty) {
                debugPrint('Title is empty');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title cannot be empty')),
                );
                return;
              }

              if (_subject == null || _subject!.isEmpty) {
                debugPrint('Subject is empty');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subject cannot be empty')),
                );
                return;
              }

              final String descriptionJson = jsonEncode(
                _descriptionController.document.toDelta().toJson(),
              );

              final newTask = Task(
                id: FirebaseDatabase.instance.ref().child('tasks').push().key ?? '',
                title: _title,
                description: descriptionJson,
                dueDate: _dueDate,
                isCompleted: false,
                subject: _subject!,
                priority: _priority,
              );

              debugPrint('Saving task: ${newTask.toMap()}');

              FirebaseDatabase.instance
                  .ref('tasks/${user!.uid}')
                  .child(newTask.id)
                  .set(newTask.toMap())
                  .then((_) {
                    debugPrint('Task saved successfully');
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    debugPrint('Error saving task: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to save task. Please try again.'),
                      ),
                    );
                  });
            } else {
              debugPrint('Form validation failed');
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Task Details'),
            isActive: _currentStep >= 0,
            content: Form(
              key: _formKey, // Asociamos el GlobalKey aquí
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _title = value;
                    },
                    onSaved: (value) {
                      _title = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Due Date: ${DateFormat('yyyy-MM-dd HH:mm').format(_dueDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDueDate(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Description'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: quill.QuillEditor.basic(
                    controller: _descriptionController,
                  ),
                ),
                const SizedBox(height: 10),
                quill.QuillToolbar.simple(controller: _descriptionController),
              ],
            ),
          ),
          Step(
            title: const Text('Additional Details'),
            isActive: _currentStep >= 2,
            content: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _subject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: _subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _subject = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a subject';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Low', 'Medium', 'High'].map((priority) {
                      return DropdownMenuItem<String>(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
