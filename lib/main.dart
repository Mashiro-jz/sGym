import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/config/injection_container.dart' as di;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aGym',
      home: Scaffold(body: Center(child: Text("Witaj w aGym!"))),
    );
  }
}
