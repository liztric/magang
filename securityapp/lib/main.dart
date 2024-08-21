import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';  // Tambahkan package logger

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var logger = Logger();  // Inisialisasi logger

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions( //BAGIAN PENTING
        apiKey: 'AIzaSyBEErAozZWn2zCbpnhODxTPV_EIO9aojbU',
        appId: '1:503196066200:android:97ddc2d9798c286a648bed',
        messagingSenderId: '503196066200',
        projectId: 'esolusindosecurity',
        databaseURL: 'https://esolusindosecurity-default-rtdb.firebaseio.com',
        storageBucket: 'esolusindosecurity.appspot.com',
      ),
    );
    runApp(const MyApp());
  } catch (e) {
    logger.e("Failed to initialize Firebase: ${e.toString()}");  // Gunakan logger
    runApp(MyAppNotConnected(errorMessage: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

// MyAppNotConnected class with super parameters
class MyAppNotConnected extends StatelessWidget {
  final String errorMessage;

  const MyAppNotConnected({super.key, required this.errorMessage});  // Gunakan super parameters

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Connection Error'),
        ),
        body: Center(
          child: Text('Failed to initialize Firebase: $errorMessage'),
        ),
      ),
    );
  }
}
