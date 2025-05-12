import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyADx8IJzb8RwHpsQu1rNeYcNMPgGVq3wr8",
        appId: "1:66464723328:web:77d967571c385620cc1165",
        messagingSenderId: "66464723328",
        projectId: "shipment-e5768",
        databaseURL: "https://shipment-e5768-default-rtdb.asia-southeast1.firebasedatabase.app"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home: HomePage(),

    );
  }
}
