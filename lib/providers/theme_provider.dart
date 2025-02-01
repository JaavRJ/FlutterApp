import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ThemeProvider extends ChangeNotifier {
  Color _themeColor = Colors.blue; // Color inicial

  Color get themeColor => _themeColor;

  // Función para cambiar el color del tema
  Future<void> changeThemeColor(Color color) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

      // Actualizar el color del tema en Firebase
      await userRef.update({
        'themeColor': color.value, // Guardar el valor del color (hexadecimal)
      });

      _themeColor = color;
      notifyListeners(); // Notificar a los oyentes (para que se redibuje la UI)
    }
  }

  // Cargar el color del tema desde Firebase
Future<void> loadThemeColor() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
    final snapshot = await userRef.get(); // Usamos `get()` en vez de `once()`, que es más actual

    // Verificamos si snapshot tiene datos y si existe el campo 'themeColor'
    if (snapshot.exists && snapshot.value != null) {
      Map<String, dynamic> userData = snapshot.value as Map<String, dynamic>;

      // Verificamos si el campo 'themeColor' existe en los datos del usuario
      if (userData.containsKey('themeColor')) {
        final int colorValue = userData['themeColor'];
        _themeColor = Color(colorValue); // Convertir el valor hexadecimal a Color
        notifyListeners(); // Notificar a los listeners para actualizar la UI
      }
    }
  }
}
}