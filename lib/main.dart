import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'face_camera_screen.dart';
import 'entry_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FaceCamera.initialize();
  runApp(const EmpathosApp());
}

class EmpathosApp extends StatelessWidget {
  const EmpathosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Empathos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00796B),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const EntryScreen(),
        '/login': (context) => const Scaffold(
          body: Center(child: Text("Login screen coming soon")),
        ),
        '/signup': (context) => const Scaffold(
          body: Center(child: Text("Signup screen coming soon")),
        ),
        '/facecam': (context) => const FaceCameraScreen(),
        '/forgot': (context) => const Scaffold(
          body: Center(child: Text("Forgot Password coming soon")),
        ),
        '/help': (context) => const Scaffold(
          body: Center(child: Text("Help screen coming soon")),
        ),
      },
    );
  }
}
