import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/UserPages/AvailableApartments.dart';

import 'package:frontend/admin_pages/AdminApprovePage.dart';
import 'package:frontend/admin_pages/ApartmentDetail.dart';
import 'package:frontend/admin_pages/add_apartment.dart';
import 'package:frontend/admin_pages/admin_apartment_view.dart';
import 'package:frontend/admin_pages/admin_dashboard.dart';
import 'package:frontend/admin_pages/apartments_list.dart';

import 'firebase_options.dart';
import 'login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Supabase before running the app

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Apartment System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
     home: LoginScreen()

    );
  }
}
