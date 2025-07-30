import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ems/WelcomeScreen.dart';
import 'package:ems/LoginScreen.dart';
import 'package:ems/AddNewEmp.dart';

import 'HomeScreen.dart';
import 'SignUpScreen.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed: $e');
    return;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMS System',
      debugShowCheckedModeBanner: false,
      initialRoute: '/home', // Set the initial route
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home' : (context) => const HomeScreen(),
        '/AddnewEmy' : (context) => const AddNewEmployeeScreen(),
      },
    );
  }
}