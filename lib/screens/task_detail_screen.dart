import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'dart:convert'; // Importar la librería para manejar JSON
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final String title;
  final quill.Document description;
  final DateTime dueDate;
  final String subject;
  final String priority; // Nuevo campo para la prioridad


  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.subject,
    required this.priority,
  });

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late quill.QuillController _descriptionController;
  late String _title;
  late String _subject;
  late String _priority;

  @override
  void initState() {
    super.initState();
    _descriptionController = quill.QuillController(
      document: widget.description,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _title = widget.title;
    _subject = widget.subject;
    _priority = widget.priority;
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance
          .ref('tasks/${user.uid}/${widget.taskId}');

      await ref.update({
        'title': _title,
        'description': jsonEncode(  // Usar jsonEncode para convertir a JSON
            _descriptionController.document.toDelta().toJson()), 
        'subject': _subject,
        'priority': _priority,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges, // Llamar al método para guardar los cambios
          ),
        ],
      ),
      body: SingleChildScrollView( // Envuelve todo el contenido en un SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _subject,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                ),
                onChanged: (value) {
                  setState(() {
                    _subject = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                'Due Date: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.dueDate)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: quill.QuillEditor.basic(
                  controller: _descriptionController,
                ),
              ),
              const SizedBox(height: 10),
              quill.QuillToolbar.simple(controller: _descriptionController),
              const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
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
            ],
          ),
        ),
      ),
    );
  }
}
