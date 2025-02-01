import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:whaletasks/providers/task_provider.dart';
import 'package:whaletasks/providers/theme_provider.dart';
import 'package:whaletasks/screens/task_screen.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    try {
      await taskProvider.loadThemeColor();
    } catch (e) {
      print('Error loading theme: $e');
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: context.watch<TaskProvider>().themeColor ?? const Color.fromARGB(255, 248, 196, 140),
      ),
      drawer: _buildDrawer(context), // Drawer agregado aquí
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notifications settings'),
              onTap: () {
                // Agregar lógica para administrar las notificaciones
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('working...'),
              onTap: () {
                // Agregar lógica para cambiar el idioma
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Change App Theme'),
              subtitle: const Text('Choose your preferred colors'),
              onTap: () {
                // Mostrar diálogo para seleccionar el tema
                _showColorPickerDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account Settings'),
              subtitle: const Text('Manage account details'),
              onTap: () {
                // Agregar lógica para administrar la cuenta
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sign Out'),
              onTap: () async {
                // Lógica de cierre de sesión
              },
            ),
          ],
        ),
      ),
    );
  }

  // Función para construir el Drawer con opciones comunes
  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String name = "Guest";
    String email = "guest@example.com";
    String photoURL = "";

    if (user != null) {
      name = user.displayName ?? "Guest"; 
      email = user.email ?? "guest@example.com"; 
      photoURL = user.photoURL ?? "";
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(name), 
            accountEmail: Text(email), 
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
              child: photoURL.isEmpty ? const Icon(Icons.person, color: Colors.black) : null, 
            ),
            decoration: BoxDecoration(
              color: context.watch<TaskProvider>().themeColor ?? const Color.fromARGB(255, 248, 196, 140),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Tasks'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Redirigir a la pantalla de configuración
              
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sign Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo para elegir colores
  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme Color'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ColorOption(
                  color: const Color.fromARGB(255, 124, 182, 230),
                  label: 'Blue',
                  onTap: () => _changeThemeColor(context, const Color.fromARGB(255, 124, 182, 230)),
                ),
                ColorOption(
                  color: const Color.fromARGB(255, 96, 179, 143),
                  label: 'Green',
                  onTap: () => _changeThemeColor(context, const Color.fromARGB(255, 96, 179, 143)),
                ),
                ColorOption(
                  color: const Color.fromARGB(255, 248, 196, 140),
                  label: 'Orange',
                  onTap: () => _changeThemeColor(context,  const Color.fromARGB(255, 248, 196, 140)),
                ),
                ColorOption(
                  color:  const Color.fromARGB(255, 140, 142, 248),
                  label: 'Purple',
                  onTap: () => _changeThemeColor(context, const Color.fromARGB(255, 140, 142, 248)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Cambiar color del tema
  void _changeThemeColor(BuildContext context, Color color) {
    Navigator.pop(context); // Cerrar el diálogo
        Provider.of<TaskProvider>(context, listen: false).changeThemeColor(color);
    // Actualizar el tema de la aplicación
    // Este es un ejemplo, puedes almacenar el color elegido en un estado global o en preferencias
    ThemeData newTheme = ThemeData(primaryColor: color);
    // Aplicar el tema a toda la aplicación
    // Utilizar un Provider o un sistema similar para cambiar el tema de manera global
    // Aquí solo se está aplicando un nuevo color al AppBar, puedes extender esta lógica.
    (context as Element).markNeedsBuild();
  }
}

// Widget para opciones de color
class ColorOption extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;

  const ColorOption({
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }

  
}
