import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './screens/auth_screen.dart';
import './providers/task_provider.dart';
import './firebase_options.dart'; // Importa tu archivo firebase_options.dart

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configura las notificaciones
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    runApp(
      ChangeNotifierProvider(
        create: (context) => TaskProvider()..loadThemeColor(), // Cargar el color del tema aquí
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        final themeColor = Provider.of<TaskProvider>(context).themeColor;
    return MaterialApp(
      title: 'WhaleTasks',
      theme: ThemeData(
        primaryColor: themeColor,
        primarySwatch: Colors.green,
      ),
      home: AuthScreen(),
    );
  }
}
