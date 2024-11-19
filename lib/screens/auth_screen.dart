import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../screens/task_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatelessWidget {
  // Inicializa GoogleSignIn con el clientId
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '111458068547-rf6cvdbf7ferf59jh2joq7gqb5gneh1j.apps.googleusercontent.com',
  );

  AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                _signInWithGoogle(context, false);
              },
              child: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _signInWithGoogle(context, true);
              },
              child: const Text('Register with Google'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context, bool isRegister) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Inicia sesión o regístrate con las credenciales de Google
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        // Verifica si es un nuevo usuario
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isNewUser && isRegister) {
          // Realiza acciones adicionales si es un nuevo usuario
          await _initializeNewUser(userCredential.user);
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TaskScreen()),
        );
      }
    } catch (e) {
      print("Error during Google Sign-In/Sign-Up: $e");
    }
  }

  Future<void> _initializeNewUser(User? user) async {
    if (user != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      await userRef.set({
        'email': user.email,
        'name': user.displayName,
        'createdAt': DateTime.now().toIso8601String(),
        'uid': user.uid,
        'username': user.photoURL
      });
    }
  }
}
